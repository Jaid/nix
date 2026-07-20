{
  config,
  lib,
  pkgs,
  ...
} @ input: let
  cfg = input.config.jaidCustomModules.hive.cpu-ppt-limit;
  ryzenSmuModule = config.boot.kernelPackages.callPackage ({
    fetchFromGitHub,
    kernel,
    lib,
    stdenv,
  }:
    stdenv.mkDerivation {
      pname = "ryzen-smu";
      version = "0.1.7-2026-06-25";
      src = fetchFromGitHub {
        owner = "amkillam";
        repo = "ryzen_smu";
        rev = "1be4fb1cd9d60b5ddefc2a4201a898766a731400";
        hash = "sha256-Tj3MZBDtobXAdF07DmqEnaJWCoJ0Xkbn25jqAIWAfoc=";
      };
      nativeBuildInputs = kernel.moduleBuildDependencies;
      hardeningDisable = ["pic" "format"];
      dontConfigure = true;
      enableParallelBuilding = true;
      makeFlags = [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];
      postPatch = ''
            substituteInPlace drv.c --replace-fail '    g_driver.device = dev;' '    if (g_driver.device) {
            dev_info(&dev->dev, "Skipping additional matching PCI root device");
            return -ENODEV;
        }

        g_driver.device = dev;'
      '';
      installPhase = ''
        runHook preInstall
        install -Dm644 ryzen_smu.ko "$out/lib/modules/${kernel.modDirVersion}/updates/ryzen_smu.ko"
        runHook postInstall
      '';
      meta = {
        homepage = "https://github.com/amkillam/ryzen_smu";
        description = "Ryzen SMU kernel driver with single-device probing";
        license = lib.licenses.gpl2;
        platforms = lib.platforms.linux;
      };
    }) {};
  cpuPptLimit = pkgs.writeShellApplication {
    name = "hive-cpu-ppt-limit";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.kmod pkgs.xxd];
    text = ''
      set -euo pipefail

      readonly action="''${1:-apply}"
      case "$action" in
        apply)
          ppt_watts=${toString cfg.pptWatts}
          modprobe ryzen_smu
          ;;
        reset)
          ppt_watts=${toString cfg.resetPptWatts}
          if ! grep -q '^ryzen_smu ' /proc/modules; then
            exit 0
          fi
          ;;
        *)
          echo "Usage: hive-cpu-ppt-limit {apply|reset}" >&2
          exit 2
          ;;
      esac

      readonly smu_path=/sys/kernel/ryzen_smu_drv
      for _ in {1..30}; do
        if [ -w "$smu_path/smu_args" ] && [ -w "$smu_path/rsmu_cmd" ]; then
          break
        fi
        sleep 1
      done
      if [ ! -w "$smu_path/smu_args" ] || [ ! -w "$smu_path/rsmu_cmd" ]; then
        echo "The Ryzen SMU RSMU interface did not appear." >&2
        exit 1
      fi

      readonly ppt_milliwatts=$((ppt_watts * 1000))
      printf '%048x' "$ppt_milliwatts" | fold -w 2 | tac | tr -d '\n' | xxd -r -p > "$smu_path/smu_args"
      printf '\x53' > "$smu_path/rsmu_cmd"
      status="$(od -An -tu4 -N4 "$smu_path/rsmu_cmd" | tr -d ' ')"
      if [ "$status" != 1 ]; then
        echo "SetPPTLimit failed with SMU status $status." >&2
        exit 1
      fi

      echo "Set the CPU PPT limit to $ppt_watts W."
      if [ "$action" = reset ]; then
        modprobe -r ryzen_smu
      fi
    '';
  };
in {
  options.jaidCustomModules.hive.cpu-ppt-limit.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the Hive CPU package power tracking limit.";
  };
  options.jaidCustomModules.hive.cpu-ppt-limit.pptWatts = lib.mkOption {
    type = lib.types.ints.between 50 280;
    default = 140;
    description = "CPU package power tracking limit in watts.";
  };
  options.jaidCustomModules.hive.cpu-ppt-limit.resetPptWatts = lib.mkOption {
    type = lib.types.ints.between 50 280;
    default = 280;
    description = "CPU package power tracking limit restored when the service stops.";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ryzenSmuModule];

    systemd.services.hive-cpu-ppt-limit = {
      description = "Apply the Hive CPU PPT limit";
      wantedBy = ["multi-user.target"];
      after = ["systemd-modules-load.service"];
      before = ["docker.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${cpuPptLimit}/bin/hive-cpu-ppt-limit apply";
        ExecStop = "${cpuPptLimit}/bin/hive-cpu-ppt-limit reset";
      };
    };
  };
}

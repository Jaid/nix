{config, pkgs, ...}: let
  # The B760MZ-E PRO exposes an ITE IT8625E Super I/O controller. Linux’s in-tree it87 driver still doesn’t support it, so we inject this fork to override the stock driver
  it87Module = config.boot.kernelPackages.callPackage ({fetchFromGitHub, kernel, lib, stdenv}:
    stdenv.mkDerivation rec {
      pname = "it87";
      version = "2026-04-16-20f2f2f";
      src = fetchFromGitHub {
        owner = "frankcrawford";
        repo = "it87";
        rev = "20f2f2f4c92c14fcdd26f60d050e693ad2c30bf8";
        hash = "sha256-o2riPbm75Bez4/SrGV7hB3mlqdxxrwRPdre+3W5y/I0=";
      };
      nativeBuildInputs = kernel.moduleBuildDependencies;
      hardeningDisable = ["pic" "format"];
      dontConfigure = true;
      enableParallelBuilding = true;
      makeFlags = [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "DRIVER_VERSION=${version}"
      ];
      installPhase = ''
        runHook preInstall
        install -Dm644 it87.ko "$out/lib/modules/${kernel.modDirVersion}/updates/it87.ko"
        runHook postInstall
      '';
      meta = {
        homepage = "https://github.com/frankcrawford/it87";
        description = "Out-of-tree ITE Super I/O hardware monitoring and fan control driver";
        license = lib.licenses.gpl2Plus;
        platforms = lib.platforms.linux;
      };
    }) {};
  nasFanControl = pkgs.writeShellApplication {
    name = "nas-fan-control";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      find_hwmon_by_name() {
        local wanted hwmon
        for wanted in "$@"; do
          for hwmon in /sys/class/hwmon/hwmon*; do
            [ -r "$hwmon/name" ] || continue
            if [ "$(< "$hwmon/name")" = "$wanted" ]; then
              printf '%s\n' "$hwmon"
              return 0
            fi
          done
        done
        return 1
      }

      get_cpu_temp_input() {
        local coretemp label it87
        coretemp="$(find_hwmon_by_name coretemp || true)"
        if [ -n "$coretemp" ]; then
          for label in "$coretemp"/temp*_label; do
            [ -r "$label" ] || continue
            if [ "$(< "$label")" = "Package id 0" ]; then
              printf '%s\n' "''${label%_label}_input"
              return 0
            fi
          done
          if [ -r "$coretemp/temp1_input" ]; then
            printf '%s\n' "$coretemp/temp1_input"
            return 0
          fi
        fi

        it87="$(find_hwmon_by_name it8625 it87 || true)"
        if [ -n "$it87" ] && [ -r "$it87/temp1_input" ]; then
          printf '%s\n' "$it87/temp1_input"
          return 0
        fi

        return 1
      }

      set_pwm_duty() {
        local target_duty="$1"
        local current_rpm
        current_rpm="$(< "$fan_input")"

        if [ "$target_duty" -ge 255 ]; then
          echo 0 > "$pwm_enable"
          return
        fi

        # A stopped fan often needs a brief kick at full duty to start
        # reliably again after spending time at 0%.
        if [ "$target_duty" -gt 0 ] && [ "$current_rpm" -lt 200 ]; then
          echo 0 > "$pwm_enable"
          sleep 1
        fi

        echo 1 > "$pwm_enable"
        echo "$target_duty" > "$pwm"
      }

      cleanup() {
        if [ -n "''${pwm_enable:-}" ] && [ -w "$pwm_enable" ]; then
          echo 0 > "$pwm_enable" || true
        fi
      }

      trap cleanup EXIT

      it87_hwmon=""
      cpu_temp_input=""
      pwm=""
      pwm_enable=""
      fan_input=""

      attempt=0
      while [ "$attempt" -lt 120 ]; do
        it87_hwmon="$(find_hwmon_by_name it8625 it87 || true)"
        cpu_temp_input="$(get_cpu_temp_input || true)"
        if [ -n "$it87_hwmon" ] && [ -n "$cpu_temp_input" ] && [ -w "$it87_hwmon/pwm1_enable" ] && [ -w "$it87_hwmon/pwm1" ] && [ -r "$it87_hwmon/fan1_input" ]; then
          pwm="$it87_hwmon/pwm1"
          pwm_enable="$it87_hwmon/pwm1_enable"
          fan_input="$it87_hwmon/fan1_input"
          break
        fi
        attempt=$((attempt + 1))
        sleep 1
      done

      : "''${cpu_temp_input:?failed to locate the CPU package temperature input}"
      : "''${pwm:?failed to locate pwm1 on the it87 hwmon device}"
      : "''${pwm_enable:?failed to locate pwm1_enable on the it87 hwmon device}"
      : "''${fan_input:?failed to locate fan1_input on the it87 hwmon device}"

      last_duty=""
      while true; do
        temp_mc="$(< "$cpu_temp_input")"

        if [ "$temp_mc" -lt 50000 ]; then
          target_duty=0
          target_label="0%"
        elif [ "$temp_mc" -lt 70000 ]; then
          target_duty=51
          target_label="20%"
        elif [ "$temp_mc" -lt 80000 ]; then
          target_duty=128
          target_label="50%"
        else
          target_duty=255
          target_label="100%"
        fi

        if [ "$target_duty" != "$last_duty" ]; then
          set_pwm_duty "$target_duty"
          echo "Set NAS fan duty to $target_label at ''${temp_mc} mC (fan1=$(< "$fan_input") rpm)."
          last_duty="$target_duty"
        fi

        sleep 2
      done
    '';
  };
in {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid"];
  boot.kernelModules = ["kvm-intel" "it87"];
  boot.kernelParams = ["boot.shell_on_fail"];
  boot.extraModulePackages = [it87Module];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1
  '';
  # Only pwm1 currently reports a live tach signal on this machine, so we
  # drive that header from the CPU package temperature with the requested
  # stepped profile.
  systemd.services.nas-fan-control = {
    description = "Control NAS fan duty from CPU temperature";
    wantedBy = ["multi-user.target"];
    wants = ["systemd-modules-load.service"];
    after = ["systemd-modules-load.service"];
    serviceConfig = {
      ExecStart = "${nasFanControl}/bin/nas-fan-control";
      Restart = "always";
      RestartSec = 2;
    };
  };
  jaidCustomModules.lan-dns.enable = true;
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/boot";
    options = ["fmask=0077" "dmask=0077"];
  };
  fileSystems."/mnt/old" = {
    fsType = "ext4";
    device = "/dev/disk/by-id/nvme-CT4000P3PSSD8_2323E6DF08C8-part3";
    options = ["defaults" "nofail" "x-mount.mkdir"];
  };
  fileSystems."/mnt/storage" = {
    fsType = "btrfs";
    device = "/dev/disk/by-label/storage";
    options = ["defaults" "nofail" "x-mount.mkdir" "compress=zstd:6" "nossd" "noatime" "nodiratime" "space_cache=v2" "degraded" "commit=120"];
  };
  hardware.bluetooth.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
}

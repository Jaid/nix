{
  lib,
  pkgs,
  ...
} @ input: let
  cfg = input.config.jaidCustomModules.hive.amdgpu-core-clock-offset;
  undervoltEnabled = lib.attrByPath ["jaidCustomModules" "hive" "amdgpu-undervolt" "enable"] false input.config;
  vramMaxClockEnabled = lib.attrByPath ["jaidCustomModules" "hive" "amdgpu-vram-max-clock" "enable"] false input.config;
  amdgpuCoreClockOffset = pkgs.writeShellApplication {
    name = "hive-amdgpu-core-clock-offset";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      readonly offset_mhz=${toString cfg.offsetMHz}
      readonly expected_gpu_count=${toString cfg.expectedGpuCount}

      for _ in {1..60}; do
        pp_od_files=(/sys/class/drm/card*/device/pp_od_clk_voltage)
        if [ "''${#pp_od_files[@]}" -eq "$expected_gpu_count" ]; then
          break
        fi
        sleep 1
      done
      if [ "''${#pp_od_files[@]}" -ne "$expected_gpu_count" ]; then
        echo "Expected $expected_gpu_count AMDGPU overdrive controls, found ''${#pp_od_files[@]}." >&2
        exit 1
      fi

      for pp_od_file in "''${pp_od_files[@]}"; do
        device="''${pp_od_file%/pp_od_clk_voltage}"
        card="''${device%/device}"
        card="''${card##*/}"
        runtime_pm="$(<"$device/power/control")"
        echo on > "$device/power/control"

        if ! {
          echo "s $offset_mhz" > "$pp_od_file"
          echo c > "$pp_od_file"

          applied_offset="$(grep -A 1 '^OD_SCLK_OFFSET:$' "$pp_od_file" | tail -n 1)"
          [ "$applied_offset" = "''${offset_mhz}Mhz" ]
        }; then
          echo "$runtime_pm" > "$device/power/control"
          echo "Failed to apply or verify the core clock offset for $card." >&2
          exit 1
        fi
        echo "$runtime_pm" > "$device/power/control"

        echo "Set the core clock offset to $offset_mhz MHz for $card."
      done
    '';
  };
in {
  options.jaidCustomModules.hive.amdgpu-core-clock-offset.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the Hive AMD GPU core clock offset service.";
  };
  options.jaidCustomModules.hive.amdgpu-core-clock-offset.offsetMHz = lib.mkOption {
    type = lib.types.ints.between (-500) 200;
    default = 0;
    description = "Core clock offset in MHz for every AMD GPU with an overdrive sysfs control.";
  };
  options.jaidCustomModules.hive.amdgpu-core-clock-offset.expectedGpuCount = lib.mkOption {
    type = lib.types.ints.positive;
    default = 4;
    description = "Number of AMD GPU overdrive controls that must appear before setting the core clock offset.";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = lib.mkIf (!(undervoltEnabled || vramMaxClockEnabled)) ["amdgpu.ppfeaturemask=0xffffffff"];

    systemd.services.hive-amdgpu-core-clock-offset = {
      description = "Set the Hive AMD GPU core clock offset";
      wantedBy = ["multi-user.target"];
      wants = ["systemd-udev-settle.service"];
      after = [
        "systemd-udev-settle.service"
        "hive-amdgpu-undervolt.service"
        "hive-amdgpu-vram-max-clock.service"
      ];
      before = ["docker.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${amdgpuCoreClockOffset}/bin/hive-amdgpu-core-clock-offset";
      };
    };
  };
}

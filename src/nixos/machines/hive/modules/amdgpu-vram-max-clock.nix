{
  lib,
  pkgs,
  ...
} @ input: let
  cfg = input.config.jaidCustomModules.hive.amdgpu-vram-max-clock;
  undervoltEnabled = lib.attrByPath ["jaidCustomModules" "hive" "amdgpu-undervolt" "enable"] false input.config;
  amdgpuVramMaxClock = pkgs.writeShellApplication {
    name = "hive-amdgpu-vram-max-clock";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      readonly max_clock_mhz=${toString cfg.maxClockMHz}
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
          echo "m 1 $max_clock_mhz" > "$pp_od_file"
          echo c > "$pp_od_file"

          applied_max_clock="$(grep -A 2 '^OD_MCLK:$' "$pp_od_file" | tail -n 1)"
          [ "$applied_max_clock" = "1: ''${max_clock_mhz}MHz" ]
        }; then
          echo "$runtime_pm" > "$device/power/control"
          echo "Failed to apply or verify the maximum VRAM clock for $card." >&2
          exit 1
        fi
        echo "$runtime_pm" > "$device/power/control"

        echo "Set the maximum VRAM clock to $max_clock_mhz MHz for $card."
      done
    '';
  };
in {
  options.jaidCustomModules.hive.amdgpu-vram-max-clock.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the Hive AMD GPU maximum VRAM clock service.";
  };
  options.jaidCustomModules.hive.amdgpu-vram-max-clock.maxClockMHz = lib.mkOption {
    type = lib.types.ints.between 97 1500;
    default = 1259;
    description = "Maximum VRAM clock in MHz for every AMD GPU with an overdrive sysfs control.";
  };
  options.jaidCustomModules.hive.amdgpu-vram-max-clock.expectedGpuCount = lib.mkOption {
    type = lib.types.ints.positive;
    default = 4;
    description = "Number of AMD GPU overdrive controls that must appear before setting the maximum VRAM clock.";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = lib.mkIf (!undervoltEnabled) ["amdgpu.ppfeaturemask=0xffffffff"];

    systemd.services.hive-amdgpu-vram-max-clock = {
      description = "Set the Hive AMD GPU maximum VRAM clock";
      wantedBy = ["multi-user.target"];
      wants = ["systemd-udev-settle.service"];
      after = ["systemd-udev-settle.service" "hive-amdgpu-undervolt.service"];
      before = ["docker.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${amdgpuVramMaxClock}/bin/hive-amdgpu-vram-max-clock";
      };
    };
  };
}

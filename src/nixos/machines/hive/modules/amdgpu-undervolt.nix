{
  lib,
  pkgs,
  ...
} @ input: let
  cfg = input.config.jaidCustomModules.hive.amdgpu-undervolt;
  amdgpuUndervolt = pkgs.writeShellApplication {
    name = "hive-amdgpu-undervolt";
    runtimeInputs = [pkgs.coreutils pkgs.gnugrep];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      readonly undervolt_offset=${toString cfg.vddgfxOffset}
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
          echo "vo $undervolt_offset" > "$pp_od_file"
          echo c > "$pp_od_file"

          applied_offset="$(grep -A 1 '^OD_VDDGFX_OFFSET:$' "$pp_od_file" | tail -n 1)"
          [ "$applied_offset" = "''${undervolt_offset}mV" ]
        }; then
          echo "$runtime_pm" > "$device/power/control"
          echo "Failed to apply or verify the VDDGFX offset for $card." >&2
          exit 1
        fi
        echo "$runtime_pm" > "$device/power/control"

        echo "Applied VDDGFX $undervolt_offset mV offset to $card."
      done
    '';
  };
in {
  options.jaidCustomModules.hive.amdgpu-undervolt.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the Hive AMD GPU VDDGFX undervolt service.";
  };
  options.jaidCustomModules.hive.amdgpu-undervolt.vddgfxOffset = lib.mkOption {
    type = lib.types.ints.between (-200) 0;
    default = -100;
    description = "VDDGFX voltage offset in mV for every AMD GPU with an overdrive sysfs control.";
  };
  options.jaidCustomModules.hive.amdgpu-undervolt.expectedGpuCount = lib.mkOption {
    type = lib.types.ints.positive;
    default = 4;
    description = "Number of AMD GPU overdrive controls that must appear before applying the offset.";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];

    systemd.services.hive-amdgpu-undervolt = {
      description = "Apply Hive AMD GPU VDDGFX undervolt";
      wantedBy = ["multi-user.target"];
      wants = ["systemd-udev-settle.service"];
      after = ["systemd-udev-settle.service"];
      before = ["docker.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${amdgpuUndervolt}/bin/hive-amdgpu-undervolt";
      };
    };
  };
}

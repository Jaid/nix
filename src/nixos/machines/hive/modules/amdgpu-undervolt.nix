{lib, pkgs, ...} @ input: let
  cfg = input.config.jaidCustomModules.hive.amdgpu-undervolt;
  amdgpuUndervolt = pkgs.writeShellApplication {
    name = "hive-amdgpu-undervolt";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      readonly undervolt_offset=${toString cfg.vddgfxOffset}
      pp_od_files=(/sys/class/drm/card*/device/pp_od_clk_voltage)
      if [ "''${#pp_od_files[@]}" -eq 0 ]; then
        echo "No AMDGPU overdrive controls found."
        exit 1
      fi

      for pp_od_file in "''${pp_od_files[@]}"; do
        device="''${pp_od_file%/pp_od_clk_voltage}"
        card="''${device%/device}"
        card="''${card##*/}"
        performance_level="$device/power_dpm_force_performance_level"

        if [ -w "$performance_level" ]; then
          echo manual > "$performance_level"
        fi

        echo "vo $undervolt_offset" > "$pp_od_file"
        echo c > "$pp_od_file"

        if [ -w "$performance_level" ]; then
          echo auto > "$performance_level"
        fi

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
    type = lib.types.int;
    default = -100;
    description = "VDDGFX voltage offset in mV for every AMD GPU with an overdrive sysfs control.";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.vddgfxOffset <= 0;
        message = "jaidCustomModules.hive.amdgpu-undervolt.vddgfxOffset must be at most 0 mV.";
      }
      {
        assertion = cfg.vddgfxOffset >= -200;
        message = "jaidCustomModules.hive.amdgpu-undervolt.vddgfxOffset must stay at or above -200 mV.";
      }
    ];

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

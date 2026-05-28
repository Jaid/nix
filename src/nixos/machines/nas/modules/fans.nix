{lib, pkgs, ...} @ input: let
  cfg = input.config.jaidCustomModules.nas.fans;
  thresholdValues = lib.concatStringsSep " " (map toString cfg.thresholds);
  strengthValues = lib.concatStringsSep " " (map toString cfg.strengths);
  hottestStrengthIndex = builtins.length cfg.strengths - 1;
  isStrictlyAscending = list:
    if builtins.length list < 2 then
      true
    else
      lib.all (index: builtins.elemAt list index < builtins.elemAt list (index + 1)) (lib.range 0 (builtins.length list - 2));
  isNondecreasing = list:
    if builtins.length list < 2 then
      true
    else
      lib.all (index: builtins.elemAt list index <= builtins.elemAt list (index + 1)) (lib.range 0 (builtins.length list - 2));
  nasFanControl = pkgs.writeShellApplication {
    name = "nas-fan-control";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      readonly -a thresholds=(${thresholdValues})
      readonly -a strengths=(${strengthValues})
      readonly hottest_strength_index=${toString hottestStrengthIndex}

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
        target_percent=""

        for index in "''${!thresholds[@]}"; do
          if [ "$temp_mc" -lt "$((thresholds[index] * 1000))" ]; then
            target_percent="''${strengths[index]}"
            break
          fi
        done

        if [ -z "$target_percent" ]; then
          target_percent="''${strengths[hottest_strength_index]}"
        fi

        target_label="$target_percent%"
        if [ "$target_percent" -ge 100 ]; then
          target_duty=255
        else
          target_duty=$((target_percent * 255 / 100))
        fi

        if [ "$target_duty" != "$last_duty" ]; then
          set_pwm_duty "$target_duty"
          echo "Set NAS fan duty to $target_label at ''${temp_mc} mC (fan1=$(< "$fan_input") rpm)."
          last_duty="$target_duty"
        fi

        sleep ${toString cfg.pollIntervalSeconds}
      done
    '';
  };
in {
  options.jaidCustomModules.nas.fans.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the custom stepped NAS fan profile";
  };
  options.jaidCustomModules.nas.fans.thresholds = lib.mkOption {
    type = lib.types.listOf lib.types.int;
    default = [50 70];
    description = "CPU package temperature thresholds in ℃. Every threshold starts a new bracket.";
  };
  options.jaidCustomModules.nas.fans.strengths = lib.mkOption {
    type = lib.types.listOf lib.types.int;
    default = [0 50 100];
    description = "Fan strengths in percent for the temperature brackets. This must contain exactly one more entry than thresholds.";
  };
  options.jaidCustomModules.nas.fans.pollIntervalSeconds = lib.mkOption {
    type = lib.types.int;
    default = 2;
    description = "How often the NAS fan controller reevaluates the CPU package temperature";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = input.config.jaidCustomModules.nas.it8625e.enable;
        message = "jaidCustomModules.nas.fans.enable requires jaidCustomModules.nas.it8625e.enable.";
      }
      {
        assertion = lib.all (threshold: threshold >= 0) cfg.thresholds;
        message = "All jaidCustomModules.nas.fans.thresholds values must stay at or above 0 ℃.";
      }
      {
        assertion = isStrictlyAscending cfg.thresholds;
        message = "jaidCustomModules.nas.fans.thresholds must be strictly ascending.";
      }
      {
        assertion = builtins.length cfg.strengths == builtins.length cfg.thresholds + 1;
        message = "jaidCustomModules.nas.fans.strengths must contain exactly one more entry than jaidCustomModules.nas.fans.thresholds.";
      }
      {
        assertion = lib.all (strength: strength >= 0 && strength <= 100) cfg.strengths;
        message = "All jaidCustomModules.nas.fans.strengths values must stay within 0–100.";
      }
      {
        assertion = isNondecreasing cfg.strengths;
        message = "jaidCustomModules.nas.fans.strengths must not decrease as temperatures rise.";
      }
      {
        assertion = cfg.pollIntervalSeconds > 0;
        message = "jaidCustomModules.nas.fans.pollIntervalSeconds must be greater than 0.";
      }
    ];

    # Only pwm1 currently reports a live tach signal on this machine, so we
    # drive that header from the CPU package temperature through the configured
    # threshold brackets.
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
  };
}

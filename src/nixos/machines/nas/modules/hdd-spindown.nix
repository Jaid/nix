{
  lib,
  pkgs,
  ...
} @ input: let
  cfg = input.config.jaidCustomModules.nas.hddSpindown;
  deviceArguments = lib.concatMapStringsSep " " (device: "-a ${lib.escapeShellArg device} -i ${toString cfg.idleSeconds}") cfg.devices;
in {
  options.jaidCustomModules.nas.hddSpindown = {
    enable = lib.mkEnableOption "automatic NAS HDD spin-down";
    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Persistent device paths of HDDs that should spin down when idle";
    };
    idleSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1800;
      description = "How many seconds without block I/O must pass before an HDD spins down";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.devices != [];
        message = "jaidCustomModules.nas.hddSpindown.devices must contain at least one HDD.";
      }
      {
        assertion = lib.all (device: lib.hasPrefix "/dev/disk/by-id/" device) cfg.devices;
        message = "All jaidCustomModules.nas.hddSpindown.devices entries must use persistent /dev/disk/by-id paths.";
      }
    ];
    systemd.services.nas-hdd-spindown = {
      description = "Spin down idle NAS HDDs";
      wantedBy = ["multi-user.target"];
      after = ["local-fs.target"];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.hd-idle} -i 0 -c ata -s 1 ${deviceArguments}";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}

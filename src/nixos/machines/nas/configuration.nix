{
  config,
  lib,
  pkgs,
  ...
}: let
  hasStorageMount = lib.hasAttrByPath ["/mnt/storage"] config.fileSystems;
in {
  imports = [
    ../.base/server/configuration.nix
  ];
  environment.systemPackages = [
    pkgs.btrfs-progs
  ];
  services.getty.autologinUser = "jaid";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  virtualisation.docker.logDriver.syslog.port = 1514;
  services.nfs.server = lib.mkIf hasStorageMount {
    enable = true;
    exports = "/mnt/storage 10.0.0.0/24(rw)";
  };
  services.nfs.settings.nfsd = lib.mkIf hasStorageMount {
    vers3 = false;
    "vers4.0" = false;
  };
  systemd.services.nfs-server = lib.mkIf hasStorageMount {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    unitConfig.ConditionPathIsMountPoint = "/mnt/storage";
  };
  systemd.services.nfs-mountd = lib.mkIf hasStorageMount {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    unitConfig.ConditionPathIsMountPoint = "/mnt/storage";
  };
}

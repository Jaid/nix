{config, lib, pkgs, pkgsUnstable, ...}: let
  hasStorageMount = lib.hasAttrByPath ["/mnt/storage"] config.fileSystems;
in {
  imports = [
    ../../software/docker.nix
    ../../software/vscode-server.nix
  ];
  environment.systemPackages = [
    pkgs.btrfs-progs
    pkgs.nixd
    pkgs.alejandra
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  services.getty.autologinUser = "jaid";
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.firewall.enable = false;
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

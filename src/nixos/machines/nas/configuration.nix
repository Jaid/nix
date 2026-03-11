{config, lib, pkgs, pkgsUnstable, ...}: {
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
  config = lib.mkIf (lib.hasAttrByPath ["/mnt/storage"] config.fileSystems) {
    services.nfs.server = {
      enable = true;
      exports = "/mnt/storage 10.0.0.0/24(rw)";
    };
    services.nfs.settings.nfsd = {
      vers3 = false;
      "vers4.0" = false;
    };
    systemd.services.nfs-server = {
      after = ["mnt-storage.mount"];
      requires = ["mnt-storage.mount"];
      unitConfig.ConditionPathIsMountPoint = "/mnt/storage";
    };
    systemd.services.nfs-mountd = {
      after = ["mnt-storage.mount"];
      requires = ["mnt-storage.mount"];
      unitConfig.ConditionPathIsMountPoint = "/mnt/storage";
    };
  };
}

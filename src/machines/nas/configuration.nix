{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    btop
    dysk
    gdu
    bat
    btrfs-progs
    eza
    fd
    sd
    nixd alejandra
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "nas";
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  # environment.etc."sudoers.d/group-jaid".source = ./resources/nopasswd.txt;
  system.stateVersion = "24.11";
}

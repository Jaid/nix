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
    nixd
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "nas";
  system.stateVersion = "24.11";
}

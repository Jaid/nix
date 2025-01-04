{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../../nixos/no-ipv6.nix
    ../../../nixos/software/gnome.nix
    ../../../nixos/software/desktop-apps.nix
    ../../../nix/packages/ghostty.nix
    ../../../nix/packages/thorium.nix
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  virtualisation.vmware.guest = {
    enable = true;
  };
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "vm";
}

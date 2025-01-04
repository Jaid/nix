{pkgs, ...}: {
  imports = [
    ../../../nixos/no-ipv6.nix
    ../../../nixos/software/gnome.nix
    ../../../nix/packages/ghostty.nix
  ];
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "vm";
}

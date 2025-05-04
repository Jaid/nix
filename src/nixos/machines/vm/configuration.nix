{pkgs, ...}: {
  imports = [
    ../../../nixos/software/gnome.nix
  ];
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

{pkgs, pkgsLatest, ...}: {
  imports = [
    ./software/cli-goodies.nix
  ];
  environment.systemPackages = [
    pkgs.bash
    pkgs.git
  ];
  services.openssh = {
    enable = true;
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  documentation.nixos.enable = false;
}

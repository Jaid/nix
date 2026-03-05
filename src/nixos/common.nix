{pkgs, pkgsLatest, ...}: {
  imports = [
    ./software/cli-goodies.nix
  ];
  environment.systemPackages = [
    pkgs.bash
    pkgs.sd
    pkgsLatest.bun
  ];
  services.openssh = {
    enable = true;
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  documentation.nixos.enable = false;
}

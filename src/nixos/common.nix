{pkgs, ...}: {
  imports = [
    ./software/cli-goodies.nix
    ./nix.nix
  ];
  environment.systemPackages = [
    pkgs.curl
    pkgs.wget
    pkgs.fastfetch
    pkgs.git
    pkgs.fd
    pkgs.sd
    pkgs.bash
  ];
  services.openssh = {
    enable = true;
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  documentation.nixos.enable = false;
  networking.firewall.enable = false;
}

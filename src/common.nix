{pkgs, ...}: {
  imports = [
    ./software/cli-goodies.nix
    ./nix.nix
  ];
  environment.systemPackages = with pkgs; [
    curl
    wget
    fastfetch
    git
    fd
    sd
    bash
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

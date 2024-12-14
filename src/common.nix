{ pkgs, ... }: {
  imports = [
    ./software/cli-goodies.nix
  ];
  environment.systemPackages = with pkgs; [
    curl
    wget
    fastfetch
    git
    fd
    sd
  ];
  services.openssh = {
    enable = true;
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  documentation.nixos.enable = false;
  networking.firewall.enable = false;
}

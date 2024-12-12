{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    curl
    wget
    nano
    fastfetch
    git
    gdu
  ];
  services.openssh = {
    enable = true;
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  documentation.nixos.enable = false;
  networking.firewall.enable = false;
}

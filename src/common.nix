{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    curl
    fastfetch
    git
    powershell
    uv
    nodejs_22
    gdu
  ];
  services.openssh = {
    enable = true;
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.firewall.enable = false;
}

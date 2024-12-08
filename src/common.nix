{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    curl
    docker
    fastfetch
    git
    powershell
    uv
    nodejs_22
    gdu
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  services.openssh = {
    enable = true;
  };
}

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.docker
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
}

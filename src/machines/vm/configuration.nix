{ config, pkgs, ... }:
{
  # imports = [
  #   ./hardware-configuration.nix
  # ];
  networking.hostName = "nas";
  networking.interfaces.enp2s0.useDHCP = true;
  services.openssh.enable = true;
  time.timeZone = "Europe/Berlin";
  environment.systemPackages = with pkgs; [
    git
    fastfetch
    powershell
    docker
    docker-compose
  ];
  virtualisation.docker.enable = true;
  users.users.jaid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.bash;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}

{ config, lib, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.hostName = "nas";
  time.timeZone = "Europe/Berlin";
  network.firewall.enable = false;
  system.stateVersion = "24.11";
}

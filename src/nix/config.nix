{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "24.11";
}

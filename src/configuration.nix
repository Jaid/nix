{ config, lib, pkgs, ... }: {
  let repo = builtins.fetchGit {
    url = "https://github.com/jaid/nix";
  };
  imports = [
    ./hardware-configuration.nix
    "${repo}/src/jaid.nix"
  ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };
  system.stateVersion = "24.11";
}

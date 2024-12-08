{ config, lib, pkgs, ... }: {
  imports =
    let repo = builtins.fetchGit {
      url = "https://github.com/jaid/nix";
      ref = "main";
    }; in [
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
  environment.systemPackages = with pkgs; [
    git
  ];
}

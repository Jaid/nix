{ config, lib, pkgs, ... }: {
  imports =
    let repo = builtins.fetchGit {
      url = "https://github.com/jaid/nix";
      ref = "main";
    }; in [
      "${repo}/src/jaid.nix"
      "${repo}/src/en-de.nix"
      "${repo}/src/common.nix"
    ];
  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };
  system.stateVersion = "24.11";
  environment.systemPackages = with pkgs; [
    git
  ];
}

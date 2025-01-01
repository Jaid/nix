{pkgs, ...}: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
  };
}

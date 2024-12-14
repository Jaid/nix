{ pkgs, ... }: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      stateVersion = "24.11";
    };
  };
}

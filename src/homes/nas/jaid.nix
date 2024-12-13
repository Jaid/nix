{ pkgs, ... }: {
  home-manager.users.jaid = {
    home = {
      file.".env2".text = "FOO=bar";
      stateVersion = "24.11";
    };
  };
}

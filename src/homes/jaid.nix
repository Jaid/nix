{ pkgs, ... }: {
  home-manager.users.jaid = {
    home = {
      username = "jaid";
      homeDirectory = "/home/jaid";
      packages = with pkgs; [
        nano
        gdu
      ];
      file.".env".text = "FOO=bar";
      stateVersion = "24.11";
    };
    programs.home-manager = {
      enable = true;
    };
    programs.git = {
      enable = true;
      userName = "joe";
      userEmail = "joe@example.org";
    };
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };
  }
}

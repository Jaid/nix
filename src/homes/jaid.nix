{ pkgs, ... }: {
  home-manager.users.jaid = {
    home = {
      username = "jaid";
      homeDirectory = "/home/jaid";
      packages = with pkgs; [
        nano
        gdu
      ];
      stateVersion = "24.11";
    };
    programs.home-manager = {
      enable = true;
    };
    programs.git = {
      enable = true;
      extraConfig = {
        user.name = "Jaid";
        user.username = "jaid";
        user.email = "6216144+Jaid@users.noreply.github.com";
        user.signingKey = "~/.ssh/id_gitSign.pub";
        github.user = "Jaid";
      };
    };
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };
  };
}

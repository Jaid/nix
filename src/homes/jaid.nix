{ pkgs, ... }: {
  home-manager.users.jaid = {
    home = {
      username = "jaid";
      homeDirectory = "/home/jaid";
      packages = with pkgs; [
        nano
        gdu
        eza
      ];
      file."~/.gitmessage".source = ./.resources/.gitmessage;
      stateVersion = "24.11";
    };
    programs.home-manager = {
      enable = true;
    };
    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core.eol = "lf";
        core.autocrlf = false;
        push.default = "current";
        core.editor = pkgs.nano;
        diff.algorithm = "patience";
      };
      includes = [
        {
          condition = "gitdir:~/git";
          contents = {
            user.name = "Jaid";
            user.username = "jaid";
            user.email = "6216144+Jaid@users.noreply.github.com";
            user.signingKey = "~/.ssh/id_gitSign.pub";
            commit.gpgSign = true;
            commit.template = "~/.gitmessage";
          };
        }
      ];
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

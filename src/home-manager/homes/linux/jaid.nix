{pkgs, ...}: {
  home-manager.users.jaid = {
    home = {
      username = "jaid";
      homeDirectory = "/home/jaid";
      packages = with pkgs; [
        nano
        gdu
        eza
      ];
      file.".gitmessage".source = ./.resources/.gitmessage;
      file.".config/oh-my-posh/jaid.omp.yml".source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/Jaid/oh-my-posh-config/refs/heads/main/src/jaid.omp.yml";
        sha256 = "1dyy5naispj1hycpcsmbdzl3y92vi3da1bqig9c5ii36jy1wkgzx";
      };
      file.".config/powershell/profile.ps1".source = ./.resources/profile.ps1;
      #file.".config/fish/profile.fish".source = ./.resources/profile.fish;
    };
    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          charset = "utf-8";
          end_of_line = "lf";
          indent_size = 2;
          indent_style = "space";
          insert_final_newline = true;
          trim_trailing_whitespace = true;
        };
        "*.{md,hbs,txt}" = {
          trim_trailing_whitespace = false;
        };
      };
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
        core.editor = "nano";
        diff.algorithm = "patience";
        core.longpaths = true;
        gpg.format = "ssh";
      };
      includes = [
        {
          condition = "gitdir:/home/jaid/git/";
          contents = {
            user.name = "Jaid";
            user.username = "jaid";
            user.email = "6216144+Jaid@users.noreply.github.com";
            user.signingKey = "/home/jaid/.ssh/id_gitSign.pub";
            commit.gpgSign = true;
            commit.template = "/home/jaid/.gitmessage";
            github.user = "jaid";
            core.sshCommand = "ssh -i /home/jaid/.ssh/id_github";
          };
        }
      ];
    };
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };
  };
  home-manager.backupFileExtension = "bak";
}

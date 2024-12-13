{ pkgs, ... }: {
  home-manager.users.jaid = {
    home = {
      username = "jaid";
      homeDirectory = "/home/jaid";
      packages = with pkgs; [
        nano
        gdu
        eza
        bat
        gifski
      ];
      file.".gitmessage".source = ./.resources/.gitmessage;
      file."config/oh-my-posh/jaid.omp.yml".text = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/Jaid/oh-my-posh-config/refs/heads/main/src/jaid.omp.yml";
        sha256 = "02mw9zv7ny0lin4l2v05zmkqbdd7wszdwvc00qaw1hrp53zgxrwk";
      };
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
        core.editor = "nano";
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

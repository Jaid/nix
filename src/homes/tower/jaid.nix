{pkgs, ...}: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      # file.".config/monitors.xml".source = ./.resources/monitors.xml;
      /*file."git/.gitconfig".text = ''
        [user]
        name = Jaid
        username = jaid
        email = 6216144+Jaid@users.noreply.github.com
        signingKey = /home/jaid/.ssh/id_gitSign.pub
        [github]
        user = jaid
        [core]
        sshCommand = ssh -i /home/jaid/.ssh/id_github
      '';*/
      #file."git/tsconfig.json".source = ./.resources/tsconfig.json;
      #file."git/.yarnrc.yml".source = ./.resources/.yarnrc.yml;
      #file."git/.browserslistrc".source = ./.resources/.browserslistrc;
    };
  };
}

{
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      sessionPath = [
        "/home/jaid/x"
        "/home/jaid/git/.foreign/scripts/bin"
        "/home/jaid/git/node_modules/.bin"
        "/home/jaid/git/node-scripts/temp/.shim"
        "/home/jaid/git/node-scripts/temp/.wrapper"
      ];
      # file.".config/monitors.xml".source = ./.resources/monitors.xml;
      /*
        file."git/.gitconfig".text = ''
        [user]
        name = Jaid
        username = jaid
        email = 6216144+Jaid@users.noreply.github.com
        signingKey = /home/jaid/.ssh/id_gitSign.pub
        [github]
        user = jaid
        [core]
        sshCommand = ssh -i /home/jaid/.ssh/id_github
      '';
      */
      file."git/tsconfig.json".source = ./.resources/tsconfig.json;
      file."git/.yarnrc.yml".source = ./.resources/.yarnrc.yml;
      file."git/.browserslistrc".source = ./.resources/.browserslistrc;
    };
  };
}

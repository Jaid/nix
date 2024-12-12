{ pkgs, ... }: {
  home.packages = [];
  programs.git = {
    enable = true;
    userEmail = "joe@example.org";
    userName = "joe";
  };
  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = false;
  };
  file.".env".text = "FOO=bar";
  home.stateVersion = "24.11";
}

{ pkgs, ... }: {
  home.packages = [];
  programs.git = {
    enable = true;
    userEmail = "joe@example.org";
    userName = "joe";
  };
  home.stateVersion = "24.11";
}

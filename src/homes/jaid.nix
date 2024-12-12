{ pkgs, ... }: {
  home.packages = [pkgs.httpie];
  home.stateVersion = "24.11";
}

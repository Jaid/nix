{pkgs, ...}: {
  imports = [
    ../server/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      packages = [
        pkgs.bat
        pkgs.btop
        pkgs.zstd
      ];
    };
  };
  home-manager.users.jaid.home.stateVersion = "25.11";
}

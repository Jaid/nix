{ pkgs, ... }: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      packages = with pkgs; [

      ];
      file.".config/monitors.xml".source = ./.resources/monitors.xml;
    };
  };
}

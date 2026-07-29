{
  hasJaidUser ? false,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  systemPathWithoutInteractiveBash = {pkgs, ...} @ args:
    import (modulesPath + "/config/system-path.nix") (
      args
      // {
        pkgs =
          pkgs
          // {
            bashInteractive = pkgs.bashNonInteractive;
          };
      }
    );
in {
  disabledModules = [
    (modulesPath + "/config/system-path.nix")
  ];
  imports = [
    systemPathWithoutInteractiveBash
  ];
  config = lib.mkMerge [
    {
      programs.bash.enable = false;
      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bashNonInteractive}/bin/bash"
      ];
    }
    (lib.mkIf hasJaidUser {
      programs.fish.enable = true;
      environment.systemPackages = [
        pkgs.fish
        pkgs.oh-my-posh
      ];
      users.users.jaid.shell = pkgs.fish;
      systemd.tmpfiles.rules = [
        "L+ /bin/fish - - - - ${pkgs.fish}/bin/fish"
      ];
    })
  ];
}

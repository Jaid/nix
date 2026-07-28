{
  hasJaidUser ? false,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            lib.getName pkgs.bash
            == "bash"
            && lib.getName pkgs.bashInteractive == "bash";
          message = "fish.nix requires bash and bashInteractive to resolve to the non-interactive Bash build";
        }
      ];
      programs.bash.enable = false;
      environment.systemPackages = [
        pkgs.bash
      ];
      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
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

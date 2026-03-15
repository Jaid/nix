{
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {lib, ...}: let
    homeDirectory = "/home/jaid";
  in {
    home.activation.createDockerFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir --parents ${lib.escapeShellArg "${homeDirectory}/docker"}
    '';
    file.".config/fish/functions/fish_greeting.fish".text = ""
  };
}

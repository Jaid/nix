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
    home.file.".config/fish/functions/fish_greeting.fish".text = "";
    home.file.".config/fastfetch/config.jsonc".text = builtins.toJSON {
      "$schema" = "https://raw.githubusercontent.com/fastfetch-cli/fastfetch/master/doc/json_schema.json";
      modules = [
        "title"
        "separator"
        "host"
        "bios"
        "os"
        "kernel"
        "initsystem"
        "packages"
        "shell"
        "cpu"
        "gpu"
        "memory"
        "swap"
        # {
        #   type = "disk";
        #   folders = [
        #     "/"
        #     "/mnt/data"
        #     "/mnt/storage"
        #   ];
        #   hideFS = ["autofs"];
        # }
        "disk"
        "localip"
        "locale"
        "break"
        "colors"
      ];
      display = {
        disableLinewrap = true;
        pipe = false;
        size = {
          binaryPrefix = "si";
        };
      };
    };
  };
}

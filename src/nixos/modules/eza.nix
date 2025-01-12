{pkgs, ...} @ input: {
  options.jaidCustomModules.eza.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable eza";
  };
  config = pkgs.lib.mkIf (input.config.jaidCustomModules.eza.enable) {
    environment.systemPackages = [
      pkgs.eza
    ];
    programs.fish.shellAliases = pkgs.lib.mkIf (input.config.programs.fish.enable) {
      l = "eza --all --group-directories-first --long --icons";
    };
  };
}

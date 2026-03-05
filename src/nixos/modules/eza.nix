{pkgs, lib, ...} @ input: {
  options.jaidCustomModules.eza.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable eza";
  };
  config = lib.mkIf (input.config.jaidCustomModules.eza.enable) {
    environment.systemPackages = [
      pkgs.eza
    ];
    programs.fish.shellAliases = lib.mkIf (input.config.programs.fish.enable) {
      l = "eza --all --group-directories-first --long --icons";
    };
  };
}

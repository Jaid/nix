{pkgs, ...} @ input: {
  options.jaidCustomModules.eza.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable eza; adds eza to the system packages";
  };
  config = pkgs.lib.mkIf (input.config.jaidCustomModules.eza.enable) {
    environment.systemPackages = [
      pkgs.eza
    ];
    programs.fish = pkgs.lib.mkIf (input.config.programs.fish.enable) {
      shellAliases = {
        l = "eza --all --group-directories-first --long --icons";
      };
    };
  };
}

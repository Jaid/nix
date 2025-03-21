{pkgs, ...} @ input: {
  options.jaidCustomModules.xnview.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable XNView MP";
  };
  config = pkgs.lib.mkIf (input.config.jaidCustomModules.xnview.enable) {
    environment.systemPackages = [
      (pkgs.callPackage ../../nix/packages/xnview.nix {})
    ];
  };
}

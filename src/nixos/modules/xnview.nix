{pkgs, lib, ...} @ input: {
  options.jaidCustomModules.xnview.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable XNView MP";
  };
  config = lib.mkIf (input.config.jaidCustomModules.xnview.enable) {
    environment.systemPackages = [
      (pkgs.callPackage ../../nix/packages/xnview.nix {})
    ];
  };
}

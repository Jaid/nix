{pkgs, lib, ...} @ input: {
  options.jaidCustomModules.qemu.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable QEMU and libvirt (this is for virtualization hosts, not guests)";
  };
  config = lib.mkIf (input.config.jaidCustomModules.qemu.enable) {
    environment.systemPackages = [
      pkgs.libvirt
      pkgs.qemu
    ];
    virtualisation.libvirtd.enable = true;
    users.users.jaid.extraGroups = ["libvirt"];
  };
}

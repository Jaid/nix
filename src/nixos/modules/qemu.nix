{pkgs, ...} @ input: {
  options.qemu.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable QEMU and libvirt (this is for virtualization hosts, not guests)";
  };
  config = pkgs.lib.mkIf (input.config.qemu.enable) {
    environment.systemPackages = [
      pkgs.libvirt
      pkgs.qemu
    ];
    virtualisation.libvirtd.enable = true;
    users.users.jaid.extraGroups = ["libvirt"];
  };
}

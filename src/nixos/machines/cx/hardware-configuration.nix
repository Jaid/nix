{lib, ...}: {
  boot.initrd.availableKernelModules = ["ahci" "nvme" "xhci_pci" "virtio_blk" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.kernelParams = ["boot.shell_on_fail"];
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  networking.useDHCP = lib.mkDefault true;
  # Hetzner Cloud only offers IPv6 statically, so this has to follow the server’s /64 whenever it gets recreated
  networking.interfaces.enp1s0.ipv6.addresses = [
    {
      address = "2a01:4f8:c016:949f::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };
  system.stateVersion = "26.05";
}

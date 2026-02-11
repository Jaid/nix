{lib, ...}: {
  boot.initrd.availableKernelModules = ["ahci" "nvme" "xhci_pci" "virtio_blk" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.kernelParams = ["boot.shell_on_fail"];
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}

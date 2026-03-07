{
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
  boot.kernelModules = ["kvm-amd"];
  boot.kernelParams = ["boot.shell_on_fail" "amd_iommu=on"];
  jaidCustomModules = {
    performance.unhinged = true;
    performance.cpuVendor = "amd";
  };
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/boot";
    options = ["fmask=0077" "dmask=0077"];
  };
  fileSystems."/mnt/data" = {
    fsType = "btrfs";
    device = "/dev/disk/by-label/data";
    options = ["defaults" "x-mount.mkdir" "compress=zstd:6" "ssd" "noatime" "nodiratime" "space_cache=v2" "discard=async"];
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];
  hardware.bluetooth.enable = false;
  # networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.11";
}

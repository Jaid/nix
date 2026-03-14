{
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
  boot.kernelModules = ["kvm-amd"];
  boot.kernelParams = ["boot.shell_on_fail" "amd_iommu=on"];
  jaidCustomModules = {
  # performance.unhinged = true;
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
    options = ["defaults" "nofail" "x-mount.mkdir" "compress=zstd:6" "ssd" "noatime" "nodiratime" "space_cache=v2" "discard=async"];
  };
  fileSystems."/mnt/storage" = {
    fsType = "nfs";
    device = "10.0.0.22:/mnt/storage";
    options = ["defaults" "nofail" "x-mount.mkdir" "x-systemd.automount" "x-systemd.idle-timeout=3600" "rw"];
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];
  hardware.bluetooth.enable = false;
  networking.interfaces.enp104s0.wakeOnLan.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.11";
}

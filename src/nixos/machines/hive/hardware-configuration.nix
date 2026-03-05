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
  hardware.bluetooth.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  system.stateVersion = "25.11";
}

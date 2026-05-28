{...}: {
  imports = [
    ./modules/it8625e.nix
    ./modules/fans.nix
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid"];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["boot.shell_on_fail"];
  jaidCustomModules.nas = {
    fans = {
      enable = true;
      thresholds = [55 70];
      strengths = [0 50 100];
      linger = 100;
    };
    it8625e.enable = true;
  };
  jaidCustomModules.lan-dns.enable = true;
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/boot";
    options = ["fmask=0077" "dmask=0077"];
  };
  fileSystems."/mnt/old" = {
    fsType = "ext4";
    device = "/dev/disk/by-id/nvme-CT4000P3PSSD8_2323E6DF08C8-part3";
    options = ["defaults" "nofail" "x-mount.mkdir"];
  };
  fileSystems."/mnt/storage" = {
    fsType = "btrfs";
    device = "/dev/disk/by-label/storage";
    options = ["defaults" "nofail" "x-mount.mkdir" "compress=zstd:6" "nossd" "noatime" "nodiratime" "space_cache=v2" "degraded" "commit=120"];
  };
  hardware.bluetooth.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
}

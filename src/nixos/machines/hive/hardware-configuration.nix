{...}: {
  imports = [
    ./modules/amdgpu-core-clock-offset.nix
    ./modules/amdgpu-undervolt.nix
    ./modules/amdgpu-vram-max-clock.nix
    ./modules/cpu-ppt-limit.nix
  ];
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
  boot.kernelModules = ["kvm-amd"];
  boot.kernelParams = ["boot.shell_on_fail" "amd_iommu=on"];
  jaidCustomModules = {
    lan-dns.enable = true;
    performance.unhinged = true;
    performance.cpuVendor = "amd";
    hive.amdgpu-core-clock-offset = {
      enable = true;
      offsetMHz = -200;
    };
    hive.amdgpu-undervolt = {
      enable = true;
      vddgfxOffset = -75;
    };
    hive.amdgpu-vram-max-clock = {
      enable = true;
      maxClockMHz = 1350;
    };
    hive.cpu-ppt-limit = {
      enable = true;
      pptWatts = 140;
    };
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
    options = ["defaults" "nofail" "x-mount.mkdir" "ssd" "relatime" "space_cache=v2" "discard=async" "nodatacow"];
  };
  fileSystems."/mnt/storage" = {
    fsType = "nfs";
    device = "10.0.0.22:/mnt/storage";
    options = ["defaults" "nofail" "x-mount.mkdir" "x-systemd.automount" "x-systemd.idle-timeout=3600" "rw" "fsc"];
  };
  services.cachefilesd = {
    enable = true;
    cacheDir = "/mnt/data/fsc";
    extraConfig = ''
      tag hive-storage
      brun 12%
      bcull 8%
      bstop 4%
      frun 12%
      fcull 8%
      fstop 4%
      culltable 15
    '';
  };
  systemd.services.cachefilesd = {
    requires = ["mnt-data.mount"];
    after = ["mnt-data.mount"];
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

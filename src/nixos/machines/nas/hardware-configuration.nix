{...}: {
  imports = [
    ./modules/it8625e.nix
    ./modules/fans.nix
    ./modules/hdd-spindown.nix
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
    hddSpindown = {
      enable = true;
      devices = [
        "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_81X0A022FWTG"
        "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_91K0A17GFWTG"
        "/dev/disk/by-id/ata-TOSHIBA_MG08ACA16TE_Y250A0WKFVGG"
      ];
      idleSeconds = 1800;
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
    options = [
      "defaults"
      "nofail"
      "x-mount.mkdir"
      "x-systemd.before=docker.service"
      "compress=zstd:6"
      "nossd"
      "noatime"
      "nodiratime"
      "space_cache=v2"
      "degraded"
      "commit=120"
    ];
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:4:1.0", ATTR{index}=="0", SYMLINK+="shuppet"
    SUBSYSTEM=="video4linux", ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:2:1.0", ATTR{index}=="0", SYMLINK+="duskull"
    SUBSYSTEM=="video4linux", ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:5.1:1.0", ATTR{index}=="0", SYMLINK+="houndstone"
  '';
  hardware.bluetooth.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
}

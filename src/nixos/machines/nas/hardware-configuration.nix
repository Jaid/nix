{lib, ...}: let
  cameras = [
    {
      alias = "duskull";
      usbPath = "4.2";
      kind = "uvc"; # ELP UVC IMX415 (USU)
    }
    {
      alias = "yamask";
      usbPath = "4.3";
      kind = "uvc"; # ELP UVC IMX415 (SPCA2688)
    }
    {
      alias = "shuppet";
      usbPath = "6.3";
      kind = "uvc"; # ELP UVC IMX678
    }
    {
      alias = "houndstone";
      usbPath = "6.4";
      kind = "uvc"; # ELP UVC IMX415 (USU)
    }
  ];
  cameraUdevRule = {
    alias,
    usbPath,
    ...
  }: ''
    SUBSYSTEM=="video4linux", ENV{ID_PATH}=="pci-0000:00:14.0-usb-0:${usbPath}:1.0", ATTR{index}=="0", SYMLINK+="${alias}"
  '';
in {
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
      "nofail"
      "x-mount.mkdir"
      "x-systemd.before=docker.service"
      "compress=zstd:6"
      "noatime"
      "nodiratime"
      "commit=120"
    ];
  };
  services.udev.extraRules = lib.concatMapStringsSep "\n" cameraUdevRule (lib.filter (camera: camera.kind == "uvc") cameras);
  hardware = {
    bluetooth.enable = false;
    enableRedistributableFirmware = true;
  };
  networking.interfaces.enp3s0.wakeOnLan.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
}

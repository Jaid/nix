{
  config,
  lib,
  ...
}: {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
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
  fileSystems."/mnt/windows" = {
    fsType = "ntfs";
    device = "/dev/disk/by-label/windows";
    options = ["defaults" "ro" "x-mount.mkdir"];
  };
  fileSystems."/mnt/storage" = {
    device = "//10.0.0.22/storage";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "x-mount.mkdir"
      "credentials=/home/jaid/credentials.txt"
      "uid=1000"
      "gid=1000"
      "vers=3"
      "file_mode=0755"
      "dir_mode=0755"
    ];
  };
  fileSystems."/mnt/nas" = {
    device = "//10.0.0.22/home";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "x-mount.mkdir"
      "credentials=/home/jaid/credentials.txt"
      "uid=1000"
      "gid=1000"
      "vers=3"
      "file_mode=0755"
      "dir_mode=0755"
    ];
  };
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

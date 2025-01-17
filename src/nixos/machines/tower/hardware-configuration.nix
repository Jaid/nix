# Hardware:
# - GIGABYTE B550 AORUS Elite
# - AMD Ryzen 9 3900X
# - Nvidia GeForce RTX 4070 (12 gb)
# - 2× G.Skill Trident Z Neo DIMM (16 gb, DDR4-3600, CL 16-19-19-39)
# - Acer XF240Hbmjdpr (1920×1080, 144 hz, 8 bit, 24″)
# - Wacom Cintiq Pro 13 (1920×1080, 60 hz, 8 bit, 13″)
# - InnoCN 32C1U (3840×2160, 60 hz, 10 bit HDR, 31.5″)
# - Crucial CT4000P3PSSD8 (4 tb, NVMe 1.4)
# - Corsair Gaming K63 (DE layout)
# - Roccat Burst Pro Air
{
  config,
  lib,
  ...
}: {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];
  jaidCustomModules = {
    gnome-wayland.nvidia = true;
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

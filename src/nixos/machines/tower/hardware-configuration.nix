{
  config,
  lib,
  ...
} @ inputs: {
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];
  boot.kernelModules = ["kvm-amd"];
  boot.kernelParams = [
    "boot.shell_on_fail"
  ];
  jaidCustomModules = {
    gnome-wayland.nvidia = true;
    performance.unhinged = true;
    performance.cpuVendor = "amd";
  };
  hardware.sane.enable = true;
  services.avahi.enable = true;
  users.users.jaid.extraGroups = ["lp" "scanner"];
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/boot";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  fileSystems."/mnt/windows" = {
    fsType = "ntfs";
    device = "/dev/disk/by-label/windows";
    options = [
      "defaults"
      "nofail"
      "x-mount.mkdir"
    ];
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
  hardware.bluetooth.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.udev.extraHwdb = ''
  evdev:uniq:0F034032AF3AA0E05B96B4A3F5001BC3:*
    KEYBOARD_KEY_c00ea=reserved
    KEYBOARD_KEY_7001d=y
    KEYBOARD_KEY_7001c=z
  '';
}

{ config, lib, pkgs, modulesPath, ... }: {
  boot.initrd.availableKernelModules = ["ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "xhci_pci" "sd_mod" "sr_mod"];
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
  networking.useDHCP = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}

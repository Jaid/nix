{ config, lib, pkgs, modulesPath, ... }: {
  imports = [];
  boot.initrd.availableKernelModules = ["ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "xhci_pci" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-uuid/bd601be5-46e2-48ad-bc20-2d5fced0b574";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-uuid/ECF1-3DD6";
    options = ["fmask=0022" "dmask=0022"];
  };
  swapDevices = [];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

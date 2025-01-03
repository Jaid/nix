{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];
  boot.initrd.availableKernelModules = ["ata_piix" "floppy" "sd_mod" "sr_mod"];
  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/root";
  };
  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/boot";
    options = ["fmask=0077" "dmask=0077"];
  };
  services.xserver.resolutions = lib.mkDefault [
    {
      x = 1920;
      y = 1080;
    }
  ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

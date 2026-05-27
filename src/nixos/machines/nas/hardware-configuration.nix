{config, ...}: let
  # The B760MZ-E PRO exposes an ITE IT8625E Super I/O controller. Linux’s in-tree it87 driver still doesn’t support it, so we inject this fork to override the stock driver
  it87Module = config.boot.kernelPackages.callPackage ({fetchFromGitHub, kernel, lib, stdenv}:
    stdenv.mkDerivation rec {
      pname = "it87";
      version = "2026-04-16-20f2f2f";
      src = fetchFromGitHub {
        owner = "frankcrawford";
        repo = "it87";
        rev = "20f2f2f4c92c14fcdd26f60d050e693ad2c30bf8";
        hash = "sha256-o2riPbm75Bez4/SrGV7hB3mlqdxxrwRPdre+3W5y/I0=";
      };
      nativeBuildInputs = kernel.moduleBuildDependencies;
      hardeningDisable = ["pic" "format"];
      dontConfigure = true;
      enableParallelBuilding = true;
      makeFlags = [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "DRIVER_VERSION=${version}"
      ];
      installPhase = ''
        runHook preInstall
        install -Dm644 it87.ko "$out/lib/modules/${kernel.modDirVersion}/updates/it87.ko"
        runHook postInstall
      '';
      meta = {
        homepage = "https://github.com/frankcrawford/it87";
        description = "Out-of-tree ITE Super I/O hardware monitoring and fan control driver";
        license = lib.licenses.gpl2Plus;
        platforms = lib.platforms.linux;
      };
    }) {};
in {
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid"];
  boot.kernelModules = ["kvm-intel" "it87"];
  boot.kernelParams = ["boot.shell_on_fail"];
  boot.extraModulePackages = [it87Module];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1
  '';
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

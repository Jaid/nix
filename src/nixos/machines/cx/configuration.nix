{pkgs, ...}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    pkgs.alejandra
    pkgs.nixd
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

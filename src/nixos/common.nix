{pkgsLatest, ...}: {
  imports = [
    ./software/cli-goodies.nix
  ];
  boot.loader.systemd-boot.configurationLimit = 8;
  environment.systemPackages = [
    pkgsLatest.git
  ];
  services.openssh = {
    enable = true;
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  documentation.nixos.enable = false;
}

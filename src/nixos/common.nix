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
  systemd.services.home-manager-jaid = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  documentation.nixos.enable = false;
}

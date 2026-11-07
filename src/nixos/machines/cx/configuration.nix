{pkgs, ...}: {
  imports = [
    ../.base/server/configuration.nix
  ];
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };
  users.users.jaid = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCPZ0ZiP841mcBLmSEU4c8zHkkYzpkBUlNPe6vJTCJz vps"
    ];
  };
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  networking.firewall.enable = true; # publicly reachable, unlike the LAN servers
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

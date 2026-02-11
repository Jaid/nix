{pkgs, ...}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };
  environment.systemPackages = [
    pkgs.alejandra
    pkgs.nixd
  ];
  users.users.jaid = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCPZ0ZiP841mcBLmSEU4c8zHkkYzpkBUlNPe6vJTCJz vps"
    ];
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

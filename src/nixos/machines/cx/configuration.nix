{pkgs, ...}: {
  imports = [
    ../../software/docker.nix
    ../../software/vscode-server.nix
  ];
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
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

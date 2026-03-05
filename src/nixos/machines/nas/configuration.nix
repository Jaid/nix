{pkgs, pkgsUnstable, ...}: {
  imports = [
    ../../software/docker.nix
    ../../software/vscode-server.nix
  ];
  environment.systemPackages = [
    pkgs.btrfs-progs
    pkgs.nixd
    pkgs.alejandra
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  services.getty.autologinUser = "jaid";
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.firewall.enable = false;
}

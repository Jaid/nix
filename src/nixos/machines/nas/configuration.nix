{pkgs, pkgsUnstable, ...}: {
  imports = [
    ../../software/docker.nix
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
  services.vscode-server.enable = true;
  services.vscode-server.enableFHS = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
}

{pkgs, ...}: {
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
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
}

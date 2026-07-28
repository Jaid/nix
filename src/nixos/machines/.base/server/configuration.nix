{pkgs, ...}: {
  imports = [
    ../../../modules/fish.nix
    ../../../software/docker.nix
    ../../../software/vscode-server.nix
  ];
  environment.systemPackages = [
    pkgs.nixd
    pkgs.alejandra
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  networking.firewall.enable = false;
}

{lib, pkgs, ...}: {
  imports = [
    ../../../modules/fish.nix
    ../../../software/docker.nix
    ../../../software/vscode-server.nix
  ];
  environment.systemPackages = [
    pkgs.nixd
    pkgs.alejandra
  ];
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  networking.firewall.enable = lib.mkDefault false;
}

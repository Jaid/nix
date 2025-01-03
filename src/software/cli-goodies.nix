{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.git
    pkgs.gh
    pkgs.fd
    pkgs.sd
    pkgs.eza
    pkgs.dysk
    pkgs.btop
    pkgs.gdu
    pkgs.bat
    pkgs.curl
    pkgs.wget
    pkgs.jq
    pkgs.inotify-tools
  ];
}

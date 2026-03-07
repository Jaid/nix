{pkgs, pkgsLatest, ...}: {
  environment.systemPackages = [
    pkgs.bat
    pkgs.btop
    pkgs.curl
    pkgs.dysk
    pkgs.eza
    pkgs.fastfetch
    pkgs.fd
    pkgs.gdu
    pkgs.gh
    pkgs.inotify-tools
    pkgs.jaq
    pkgs.nodejs_latest
    pkgs.sd
    pkgs.tmux
    pkgs.uv
    pkgs.wget
    pkgsLatest.bun
  ];
}

{pkgs, pkgsLatest, ...}: {
  environment.systemPackages = [
    pkgs.bat
    pkgs.curl
    pkgs.dysk
    pkgs.eza
    pkgs.fd
    pkgs.gdu
    pkgs.gh
    pkgs.inotify-tools
    pkgs.jaq
    pkgs.sd
    pkgs.tmux
    pkgs.wget
    pkgsLatest.btop
    pkgsLatest.bun
    pkgsLatest.fastfetch
    pkgsLatest.nodejs_latest
    pkgsLatest.uv
  ];
}

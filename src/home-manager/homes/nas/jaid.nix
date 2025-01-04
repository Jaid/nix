{pkgs, ...}: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      packages = [
        pkgs.bat
        pkgs.gifski
        pkgs.yt-dlp
        pkgs.gallery-dl
        pkgs.android-tools
        pkgs.btop
        pkgs.ffmpeg-headless
        pkgs.streamlink
        pkgs.libjxl
        pkgs.ollama
        pkgs.scrcpy
        pkgs.zstd
        pkgs.imagemagick
      ];
    };
  };
}

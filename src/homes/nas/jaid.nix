{ pkgs, ... }: {
  imports = [
    ../linux/jaid.nix
  ];
  home-manager.users.jaid = {
    home = {
      packages = with pkgs; [
        bat
        gifski
        yt-dlp
        gallery-dl
        android-tools
        btop
        ffmpeg-headless
        streamlink
        libjxl
        ollama
        scrcpy
        zstd
        imagemagick
      ];
      stateVersion = "24.11";
    };
  };
}

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
        naps2
        zstd
      ];
      stateVersion = "24.11";
    };
  };
}

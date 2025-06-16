{pkgs, ...} @ inputs: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
    pkgs.ghostty
    pkgs.brave
    pkgs.bun
    pkgs.krita
    pkgs.mpv-unwrapped
    pkgs.nodejs_latest
    pkgs.streamlink
    pkgs.thunderbird
    pkgs.vscode
    pkgs.yt-dlp
    pkgs.zstd
    pkgs.ffmpeg-full
    pkgs.kdePackages.kdenlive
    pkgs.alejandra
    pkgs.atuin
    pkgs.btop
    pkgs.gifski
    pkgs.gmic
    pkgs.grc
    pkgs.libjxl
    pkgs.libwebp
    pkgs.nixd
    pkgs.nvtopPackages.nvidia
    pkgs.optipng
    pkgs.parted
    pkgs.pngquant
    pkgs.scrcpy
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.yarn-berry
    #pkgs.docker
    pkgs.docker-compose
  ];
  virtualisation.docker.enable = true;
  users.users.jaid.extraGroups = ["docker"];
  services.gnome.gnome-remote-desktop.enable = true;
  jaidCustomModules = {
    xnview.enable = true;
    qemu.enable = true;
    gnome-wayland = {
      enable = true;
      sunshine = true;
    };
    eza.enable = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_6_14;
  home-manager.backupFileExtension = "bak";
}

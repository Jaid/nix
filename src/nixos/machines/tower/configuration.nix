{pkgs, ...} @ inputs: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
    # (pkgs.callPackage ../../../nix/packages/llama-cpp.nix {
    #   pkgs = inputs.pkgsUnstablePersonal;
    # })
    inputs.pkgsLatestPersonal.ghostty
    inputs.pkgsUnstable.brave
    inputs.pkgsUnstable.bun
    inputs.pkgsUnstable.krita
    inputs.pkgsUnstable.mpv-unwrapped
    inputs.pkgsUnstable.nodejs_latest
    inputs.pkgsUnstable.streamlink
    inputs.pkgsUnstable.thunderbird
    inputs.pkgsUnstable.vscode
    inputs.pkgsUnstable.yt-dlp
    inputs.pkgsUnstable.zstd
    inputs.pkgsUnstable.ffmpeg-full
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
    pkgs.docker
    pkgs.docker-compose
  ];
  jaidCustomModules = {
    xnview.enable = true;
    qemu.enable = true;
    gnome-wayland.enable = true;
    eza.enable = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  networking.hostName = "tower";
  home-manager.backupFileExtension = "bak";
  services.power-profiles-daemon.enable = false;
  services.dleyna-server.enable = false;
  services.dleyna-renderer.enable = false;
}

{pkgs, ...} @ inputs: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  programs.steam.enable = true;
  programs.steam.package = inputs.pkgsUnstable.steam.override {
    extraPkgs = pkgs: [pkgs.bumblebee pkgs.glxinfo];
  };
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
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
    inputs.pkgsUnstable.kdePackages.kdenlive
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
  jaidCustomModules = {
    xnview.enable = true;
    qemu.enable = true;
    gnome-wayland.enable = true;
    eza.enable = true;
  };
  services.power-profiles-daemon.enable = false;
  services.dleyna-server.enable = false;
  services.dleyna-renderer.enable = false;
  services.gnome.tinysparql.enable = false;
  services.gnome.localsearch.enable = false;
  services.gnome.gnome-online-accounts.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  home-manager.backupFileExtension = "bak";
}

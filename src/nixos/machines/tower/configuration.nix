{pkgs, ...} @ inputs: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
    (pkgs.callPackage ../../../nix/packages/llama-cpp.nix {
      pkgs = inputs.pkgsUnstablePersonal;
    })
    inputs.pkgsLatestPersonal.ghostty
    pkgs.parted
    pkgs.nvtopPackages.nvidia
    pkgs.grc
    pkgs.nixd
    pkgs.alejandra
    inputs.pkgsUnstable.nodejs_latest
    inputs.pkgsUnstable.bun
    pkgs.yarn-berry
    pkgs.parted
    pkgs.mpv-unwrapped
    pkgs.krita
    pkgs.vscode
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.btop
    pkgs.thunderbird
    pkgs.pngquant
    pkgs.streamlink
    pkgs.deno
    pkgs.gmic
    pkgs.scrcpy
    pkgs.yt-dlp
    pkgs.zstd
    pkgs.gifski
    pkgs.gnirehtet
    pkgs.upx
    pkgs.optipng
    pkgs.libwebp
    pkgs.libjxl
    pkgs.atuin
  ];
  jaidCustomModules = {
    ipv6.enable = false;
    xnview.enable = true;
    qemu.enable = true;
    gnome-wayland.enable = true;
    eza.enable = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  networking.hostName = "tower";
  home-manager.backupFileExtension = "bak";
}

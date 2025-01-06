{pkgs, ...} @ inputs: {
  imports = [
    ../../../nixos/software/gnome.nix
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    (pkgs.callPackage ../../../nix/packages/thorium.nix {})
    (pkgs.callPackage ../../../nix/packages/llama-cpp.nix {
      pkgs = inputs.pkgsLatestPersonal;
    })
    inputs.pkgsLatestPersonal.ghostty
    pkgs.parted
    pkgs.nvtopPackages.nvidia
    pkgs.grc
    pkgs.nixd
    pkgs.alejandra
    pkgs.nodejs_latest
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
  ];
  config.ipv6.enable = false;
  config.xnview.enable = true;
  config.qemu.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "tower";
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  home-manager.backupFileExtension = "bak";
}

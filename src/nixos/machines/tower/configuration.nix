{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../../nixos/no-ipv6.nix
    ../../../nixos/software/gnome.nix
    ../../../nixos/software/desktop-apps.nix
    ../../../nix/packages/ghostty.nix
    ../../../nix/packages/thorium.nix
    ../../../nix/packages/llama-cpp.nix
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = [
    pkgs.parted
    pkgs.nvtopPackages.nvidia
    pkgs.grc
    pkgs.nixd
    pkgs.alejandra
    pkgs.libvirt
    pkgs.qemu
    pkgs.nodejs_latest
    pkgs.yarn-berry
    pkgs.parted
    pkgs.mpv-unwrapped
    pkgs.krita
    pkgs.vscode
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.btop
    pkgs.wl-clipboard
    pkgs.thunderbird
    pkgs.powershell
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
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "tower";
  virtualisation.libvirtd.enable = true;
  users.users.jaid.extraGroups = ["libvirt"];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  home-manager.backupFileExtension = "bak";
  home-manager.users.jaid.home = {
    sessionPath = [
      "/home/jaid/x"
      "/home/jaid/git/.foreign/scripts/bin"
      "/home/jaid/git/node_modules/.bin"
      "/home/jaid/git/node-scripts/temp/.shim"
      "/home/jaid/git/node-scripts/temp/.wrapper"
    ];
  };
}

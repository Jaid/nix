{
  pkgs,
  lib,
  ...
} @ input: {
  options.gnome-wayland.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable Gnome/Wayland desktop";
  };
  options.gnome-wayland.nvidia = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable Nvidia support for Gnome/Wayland desktop";
  };
  config = pkgs.lib.mkIf (input.config.gnome-wayland.enable) {
    environment.systemPackages = [
      pkgs.dconf-editor
      pkgs.gnome-tweaks
      pkgs.gnomeExtensions.pano
      pkgs.gnomeExtensions.user-themes
      pkgs.gnomeExtensions.just-perfection
      pkgs.nautilus
      pkgs.wl-clipboard
    ];
    services.xserver.excludePackages = [
      pkgs.xterm
    ];
    environment.gnome.excludePackages = [
      pkgs.gnome-tour
    ];
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "jaid";
      };
    };
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = builtins.readFile ./gnome-settings.ini;
      };
    };
    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
    };
    services.xserver.videoDrivers = lib.mkIf input.config.gnome-wayland.nvidia ["nvidia"];
    hardware.nvidia = lib.mkIf input.config.gnome-wayland.nvidia {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = false;
    };
    services.gnome.core-utilities.enable = false;
    users.users.jaid.extraGroups = ["networkmanager" "video"];
    fonts = {
      packages = [
        input.pkgsLatest.nerd-fonts.fira-mono
        input.pkgsLatest.nerd-fonts.ubuntu
        input.pkgsLatest.nerd-fonts.ubuntu-mono
        input.pkgsLatest.nerd-fonts.jetbrains-mono
        input.pkgsLatest.nerd-fonts.symbols-only
        input.pkgsPersonal.shantell-sans
        input.pkgsPersonal.geologica
        pkgs.inter
        pkgs.roboto-flex
        pkgs.iosevka
        pkgs.quicksand
        pkgs.pretendard
        pkgs.noto-fonts
        pkgs.rubik
        pkgs.lexend
        pkgs.montserrat
      ];
      fontconfig = {
        hinting.style = "full";
        antialias = true;
        defaultFonts = {
          monospace = ["JetBrainsMono Nerd Font Mono Semi-Bold 10"];
        };
      };
    };
  };
}

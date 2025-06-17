{
  pkgs,
  lib,
  ...
} @ input: {
  options.jaidCustomModules.gnome-wayland.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable Gnome/Wayland desktop";
  };
  options.jaidCustomModules.gnome-wayland.nvidia = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enable Nvidia support for Gnome/Wayland desktop";
  };
  options.jaidCustomModules.gnome-wayland.sunshine = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = true;
    description = "Enable Sunshine remote desktop server";
  };
  config = pkgs.lib.mkIf (input.config.jaidCustomModules.gnome-wayland.enable) {
    environment.systemPackages = [
      pkgs.dconf-editor
      pkgs.gnome-tweaks
      pkgs.gnomeExtensions.pano
      pkgs.gnomeExtensions.user-themes
      pkgs.gnomeExtensions.just-perfection
      pkgs.gnomeExtensions.gtile
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
    services.xserver.videoDrivers = lib.mkIf input.config.jaidCustomModules.gnome-wayland.nvidia ["nvidia"];
    hardware.nvidia = lib.mkIf input.config.jaidCustomModules.gnome-wayland.nvidia {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
     # package = input.config.boot.kernelPackages.nvidiaPackages.stable;
    };
    services.gnome.core-apps.enable = false;
    services.gnome.tinysparql.enable = false;
    services.gnome.localsearch.enable = false;
    services.gnome.gnome-online-accounts.enable = false;
    services.power-profiles-daemon.enable = false;
    services.dleyna.enable = false;
    users.users.jaid.extraGroups = ["networkmanager" "video"];
    services.sunshine = lib.mkIf input.config.jaidCustomModules.gnome-wayland.sunshine {
      enable = true;
      capSysAdmin = true;
      package = input.pkgsPersonal.sunshine;
    };
    fonts = {
      packages = [
        pkgs.nerd-fonts.fira-mono
        pkgs.nerd-fonts.ubuntu
        pkgs.nerd-fonts.ubuntu-mono
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.symbols-only
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

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
      enable = true;
      modesetting = true;
      open = true;
      nvidiaSettings = false;
    };
    boot.kernelParams = lib.mkIf input.config.gnome-wayland.nvidia ["nvidia-drm.modeset=1"];
    services.gnome.core-utilities.enable = false;
    users.users.jaid.extraGroups = ["networkmanager" "video"];
    fonts = {
      packages = [
        pkgs.nerdfonts
        {
          fonts = [
            "15kkgx6i4f7zn6fdaw2dqqw3hcpl3pi4cy4g5jx67af8qlhqarrb"
            "01j0rkgrix7mdp9fx0y8zzk1kh40yfcp932p0r5y666aq4mq5y3c"
            "088vi947kavk1pkvbl68kv7nz84yvfkj725n2zn7ypq354kkm92n"
          ];
        }
        pkgs.inter-nerdfont
        pkgs.inter
        pkgs.source-sans-pro
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

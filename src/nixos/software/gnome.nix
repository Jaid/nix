{pkgs, ...}: {
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
      extraGSettingsOverrides = builtins.readFile ./.resources/gnome-settings.ini;
    };
  };
  services.gnome.core-utilities.enable = false;
  users.users.jaid.extraGroups = ["networkmanager"];
  fonts = {
    packages = [
      pkgs.nerdfonts
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
}

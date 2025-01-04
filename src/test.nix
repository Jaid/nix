{
  pkgs,
  pkgsUnstable,
  ...
}: {
  environment.systemPackages = [
    pkgs.kitty
    #waybar
    /*
      (hyprland.override {
      enableXWayland = false;
      legacyRenderer = false;
      withSystemd = true;
    })
    */
    #mako
    pkgs.firefox
    pkgs.ungoogled-chromium
  ];
  fonts.packages = [
    pkgs.nerdfonts
    pkgs.inter-nerdfont
    pkgs.inter
    pkgs.jetbrains-mono
  ];
  /*
    programs.hyprland = {
    enable = true;
    xwayland.enable = false;
  };
  */
  fonts.fontconfig = {
    hinting.style = "full";
    antialias = true;
    defaultFonts = {
      monospace = ["JetBrains Mono"];
    };
  };
  environment.sessionVariables = {
    #NIXOS_OZONE_WL = "1";
    #XDG_SESSION_TYPE = "wayland";
    #MOZ_ENABLE_WAYLAND = "1";
    #QT_QPA_PLATFORM = "wayland";
    #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}

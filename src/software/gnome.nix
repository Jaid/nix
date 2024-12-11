{ pkgs, ... }: {
  imports = [
    ./desktop-apps.nix
  ];
  environment.systemPackages = [
    pkgs.dconf-editor
    pkgs.gnome-tweaks
    pkgs.gnomeExtensions.tilingnome
    pkgs.gnomeExtensions.freon
    pkgs.gnomeExtensions.pano
  ];
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "jaid";
    };
  };
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.interface]
        clock-show-date=false
        clock-show-seconds=true
        color-scheme='prefer-dark'
        [org.gnome.desktop.session]
        idle-delay=uint32 0
        [org.gnome.mutter]
        dynamic-workspaces=false
        [org.gnome.desktop.background]
        picture-options='none'
        primary-color='#000000'
        [org.gnome.shell.weather]
        locations=[<(uint32 2, <('Hannover', 'EDDV', false, [(0.91571608669745586, 0.16900604341702005)], @a(dd) [])>)>]
        [org.gnome.shell]
        enabled-extensions=['user-theme@gnome-shell-extensions.gcampax.github.com', 'system-monitor@gnome-shell-extensions.gcampax.github.com']
        [org/gnome/GWeather4]
        temperature-unit='centigrade'
      '';
    };
  };
  environment.gnome.excludePackages = [
    pkgs.gnome-photos
    pkgs.gnome-tour
  ];
  users.users.jaid = {
    extraGroups = [
      "networkmanager"
    ];
  };
}

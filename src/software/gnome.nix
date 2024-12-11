{ pkgs, ... }: {
  imports = [
    ./desktop-apps.nix
  ];
  environment.systemPackages = with pkgs; [
    dconf-editor
    gnome-tweaks
    gnomeExtensions.tilingnome
    gnomeExtensions.freon
    gnomeExtensions.pano
  ];
  environment.gnome.excludePackages = with pkgs; [
    geary
    gedit
    gnome-backgrounds
    gnome-calculator
    gnome-calendar
    # gnome-camera - Not the actual name
    gnome-characters
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-photos
    gnome-tour
    gnome-user-docs
    gnome-weather
    yelp
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
  users.users.jaid = {
    extraGroups = [
      "networkmanager"
    ];
  };
}

{ pkgs, ... }: {
  imports = [
    ./desktop-apps.nix
  ];
  environment.systemPackages = with pkgs; [
    dconf-editor
    gnome-tweaks
    gnomeExtensions.tilingnome
    gnomeExtensions.freon lm_sensors
    gnomeExtensions.pano
  ];
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];
  environment.gnome.excludePackages = with pkgs; [
    # gnome-camera - Not the actual name
    eog
    epiphany
    geary
    gedit
    gnome-backgrounds
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-contacts
    gnome-font-viewer
    gnome-maps
    gnome-music
    gnome-photos
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-weather
    libreoffice
    modemmanager
    plymouth
    snapshot
    yelp
    simple-scan
    totem
    gnome-clocks
    baobab
    evince
    file-roller
    loupe
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
        enabled-extensions=['user-theme@gnome-shell-extensions.gcampax.github.com', 'tilingnome@rliang.github.com', 'freon@UshakovVasilii_Github.yahoo.com', 'pano@elhan.io']
        favorite-apps=['org.gnome.Nautilus.desktop', 'code.desktop']
        [org/gnome/GWeather4]
        temperature-unit='centigrade'
        [org/gnome/shell/extensions/pano]
        exclusion-list=@as []
        history-length=20
        send-notification-on-copy=false
      '';
    };
  };
  users.users.jaid = {
    extraGroups = [
      "networkmanager"
    ];
  };
}

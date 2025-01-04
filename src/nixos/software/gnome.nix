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
      extraGSettingsOverrides = ''
        [org.gnome.desktop.interface]
        clock-show-date=true
        clock-show-weekday=true
        clock-show-seconds=true
        color-scheme='prefer-dark'
        font-antialiasing='rgba'
        font-name='Source Sans 3 Semi-Bold 10'
        gtk-enable-primary-paste=false
        [org.gnome.desktop.session]
        idle-delay=uint32 0
        [org.gnome.mutter]
        dynamic-workspaces=true
        edge-tiling=false
        [org.gnome.desktop.background]
        picture-options='none'
        primary-color='#000000'
        [org.gnome.shell]
        enabled-extensions=['user-theme@gnome-shell-extensions.gcampax.github.com', 'pano@elhan.io', 'system-monitor@gnome-shell-extensions.gcampax.github.com', 'just-perfection-desktop@just-perfection']
        favorite-apps=['org.gnome.Nautilus.desktop', 'code.desktop', 'kitty.desktop']
        last-selected-power-profile='performance'
        remember-mount-password=true
        [org.gnome.shell.extensions.system-monitor]
        show-swap=false
        [org.gnome.GWeather4]
        temperature-unit='centigrade'
        [org.gnome.shell.extensions.pano]
        exclusion-list=@as []
        history-length=20
        send-notification-on-copy=false
        global-shortcut=['<Super>v']
        [org.gnome.desktop.wm.keybindings]
        begin-move=@as []
        begin-resize=@as []
        move-to-monitor-down=@as []
        move-to-monitor-left=@as []
        move-to-monitor-right=@as []
        move-to-monitor-up=@as []
        panel-run-dialog=@as []
        switch-input-source=@as []
        switch-input-source-backward=@as []
        toggle-maximized=@as []
        [org.gnome.mutter.wayland.keybindings]
        restore-shortcuts=@as []
        [org.gnome.settings-daemon.plugins.media-keys]
        help=@as []
        home=['<Super>e']
        logout=@as []
        magnifier=@as []
        magnifier-zoom-in=@as []
        magnifier-zoom-out=@as []
        screenreader=@as []
        [org.gnome.shell.keybindings]
        focus-active-notification=@as []
        toggle-message-tray=@as []
        toggle-quick-settings=@as []
        [org.gnome.desktop.a11y.applications]
        screen-magnifier-enabled=false
        [ca.desrt.dconf-editor]
        show-warning=false
        [org.gnome.desktop.input-sources]
        sources=[('xkb', 'de+nodeadkeys'), ('xkb', 'us')]
        [org.gnome.desktop.wm.preferences]
        focus-mode='sloppy'
        [org.gnome.nautilus.preferences]
        default-folder-viewer='list-view'
        date-time-format='detailed'
        show-delete-permanently=true
        search-filter-time-type='last_modified'
        [org.gnome.settings-daemon.plugins.power]
        sleep-inactive-ac-type='nothing'
        power-button-action='interactive'
        [org.gnome.tweaks]
        ahow-extensions-notice=false
        [org.gtk.gtk4.settings.file-chooser]
        show-hidden=true
        [org.gtk.settings.file-chooser]
        show-hidden=true
        [org.gnome.nautilus.icon-view]
        default-zoom-level='small'
        [org.gnome.nautilus.list-view]
        default-visible-columns=['name', 'size', 'date_created', 'date_modified'];
        default-zoom-level='small'
        [org.gnome.shell.extensions.just-perfection]
        accessibility-menu=false
        activities-button=false
        alt-tab-small-icon-size=0
        alt-tab-window-preview-size=0
        animation=3
        background-menu=false
        clock-menu=true
        clock-menu-position=2
        clock-menu-position-offset=0
        controls-manager-spacing-size=0
        dash=true
        dash-icon-size=32
        keyboard-layout=false
        panel=false
        panel-in-overview=true
        panel-size=0
        quick-settings=true
        quick-settings-dark-mode=false
        ripple-box=false
        theme=true
        weather=false
        workspace-background-corner-size=0
        workspace-switcher-should-show=false
        world-clock=false
        workspace-popup=false
        [org.gnome.shell.extensions.user-theme]'';
    };
  };
  services.gnome.core-utilities.enable = false;
  users.users.jaid = {
    extraGroups = [
      "networkmanager"
    ];
  };
}

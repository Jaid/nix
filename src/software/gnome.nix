{ pkgs, ... }: {
  environment.systemPackages = [
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
        clock-show-date=true
        [org.gnome.desktop.background]
        picture-options='none'
        primary-color='#000000'
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

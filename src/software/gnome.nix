{ pkgs, ... }: {
  environment.systemPackages = [
  ];
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin.enable = true;
    };
    desktopManager.gnome.enable = true;
  };
  environment.gnome.excludePackages = [
    pkgs.gnome-photos
  ];
}

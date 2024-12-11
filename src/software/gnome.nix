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
    desktopManager.gnome.enable = true;
  };
  environment.gnome.excludePackages = [
    pkgs.gnome-photos
  ];
  users.users.jaid = {
    extraGroups = [
      "networkmanager"
    ];
  }
}

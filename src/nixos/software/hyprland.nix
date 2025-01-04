{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.waybar
    pkgs.mako
    pkgs.hyprland
  ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}

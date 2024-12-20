{pkgs}: {
  environment.systemPackages = with pkgs; [
    waybar
    mako
    hyprland
  ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  hardware = {
    opengl.enable = true;
  };
}

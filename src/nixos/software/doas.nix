{pkgs, ...}: {
  environment.systemPackages = [
  ];
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    wheelNeedsPassword = false;
  };
}

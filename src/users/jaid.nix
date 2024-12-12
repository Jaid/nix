{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.powershell
    pkgs.oh-my-posh
  ];
  users.users.jaid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialHashedPassword = "$6$0xCcUG.hybOHcJWc$WhpMJatUVL7IdeQiG8LUrR9meuLYyA9APO4tL892tqw1txuX46h/i.YpW1AsecGeDal3lFSCLxcFjZiHRiMN51";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Up24BhYxyHEWrYc5EJ5PbPn7hVYGpv1fSCwLURvGq jaid@github/73158609"
    ];
    shell = pkgs.powershell;
  };
  services.openssh = {
    enable = true;
  };
  environment.etc."sudoers.d/jaid".text = "jaid ALL=(ALL) NOPASSWD: ALL";
}

{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    powershell
    fish
    oh-my-posh
  ];
  users.users.jaid = {
    isNormalUser = true;
    uid = 1000;
    group = "jaid";
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialHashedPassword = "$6$0xCcUG.hybOHcJWc$WhpMJatUVL7IdeQiG8LUrR9meuLYyA9APO4tL892tqw1txuX46h/i.YpW1AsecGeDal3lFSCLxcFjZiHRiMN51";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Up24BhYxyHEWrYc5EJ5PbPn7hVYGpv1fSCwLURvGq jaid@github/73158609"
    ];
    shell = pkgs.fish;
  };
  users.groups.jaid.gid = 1000;
  services.openssh = {
    enable = true;
  };
  programs.fish = {
    enable = true;
  };
  #services.getty.autologinUser = "jaid";
}

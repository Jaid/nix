{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.powershell
    pkgs.fish
    pkgs.oh-my-posh
  ];
  users.users.jaid = {
    isNormalUser = true;
    uid = 1000;
    group = "jaid";
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialHashedPassword = "$6$WXuW6lzzPV.3nqm0$W83EcYho0QWn1gcx7rFfNGCned09fSXB57hvxDp5W8qSnYl8H59mSsTvHFOGLv/l/J7awpq4ZkGuvi2LygyuD0";
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
    shellAliases = pkgs.lib.mkIf (input.config.programs.fish.enable) {
      l = "eza --all --group-directories-first --long --icons";
    };
  };
  #services.getty.autologinUser = "jaid";
}

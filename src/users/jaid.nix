{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.powershell
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
    initialHashedPassword = "$6$0xCcUG.hybOHcJWc$WhpMJatUVL7IdeQiG8LUrR9meuLYyA9APO4tL892tqw1txuX46h/i.YpW1AsecGeDal3lFSCLxcFjZiHRiMN51";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Up24BhYxyHEWrYc5EJ5PbPn7hVYGpv1fSCwLURvGq jaid@github/73158609"
    ];
    shell = pkgs.powershell;
  };
  users.groups.jaid.gid = 1000;
  services.openssh = {
    enable = true;
  };
  environment.etc."sudoers.d/group-jaid".source = ./resources/nopasswd.txt;
  # systemd.services."getty@tty1".serviceConfig = {
  #   ExecStart = lib.mkOverride 0 [
  #     ""
  #     "-/usr/bin/agetty --autologin jaid --noclear %I $TERM"
  #   ];
  # };
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    restartIfChanged = false;
    serviceConfig.ExecStart = [
      ""
      "-${pkgs.util-linux}/sbin/agetty --autologin jaid --noclear %I $TERM"
    ];
  };
}

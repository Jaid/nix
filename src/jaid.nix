{ pkgs, ... }: {
  users.users.jaid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialHashedPassword = "$6$bk5SDekXN9EAk3T/$IGwHtdQk/AVkH3Fdw48KIiGT4nr.xLvgTle7GibTuQHQGGWgRij5nU/RGMlo3..c9dqCjXLRg/i4JJRM9GcKy1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Up24BhYxyHEWrYc5EJ5PbPn7hVYGpv1fSCwLURvGq jaid@github/73158609"
    ];
    shell = pkgs.powershell;
  };
}

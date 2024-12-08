{ pkgs, ... }: {
  users.users.jaid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialHashedPassword = "$6$bk5SDekXN9EAk3T/$IGwHtdQk/AVkH3Fdw48KIiGT4nr.xLvgTle7GibTuQHQGGWgRij5nU/RGMlo3..c9dqCjXLRg/i4JJRM9GcKy1";
    shell = pkgs.powershell;
  }
}

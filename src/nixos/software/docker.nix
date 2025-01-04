{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.docker
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # https://gist.github.com/Jaid/3d590adcd183762ad7edffa5eff82c26
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-file = "1";
        max-size = "20m";
      };
      features.buildkit = true;
      builder = {
        gc = {
          defaultKeepStorage = "4GB";
          enabled = true;
        };
      };
    };
  };
}

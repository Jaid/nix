{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.docker
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
     # https://gist.github.com/Jaid/3d590adcd183762ad7edffa5eff82c26
    daemon.settings = {
      logDriver = "json-file";
      logOpts = {
        maxFile = "1";
        maxSize = "20m";
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

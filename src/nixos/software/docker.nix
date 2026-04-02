{config, lib, modulesPath, pkgs, pkgsLatest, ...} @ moduleArguments: let
  upstreamDockerModule = import "${modulesPath}/virtualisation/docker.nix";
  upstreamDockerModuleArguments = moduleArguments // {
    utils = import "${modulesPath}/../lib/utils.nix" {
      inherit lib config pkgs;
    };
  };
  syslogOptionType = lib.types.coercedTo lib.types.bool (enabled: {inherit enabled;}) (lib.types.submodule {
    options = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Docker should use the syslog log driver.";
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Host Docker should send syslog logs to.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 1514;
        description = "Port Docker should send syslog logs to.";
      };
    };
  });
  logDriverOptionType = lib.types.coercedTo (lib.types.enum [false]) (_: {
    json = false;
    syslog = false;
  }) (lib.types.submodule {
    options = {
      json = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Docker should keep local logs. When syslog is disabled this uses the json-file log driver, otherwise Docker’s local readback cache.";
      };
      syslog = lib.mkOption {
        type = syslogOptionType;
        default = false;
        description = "Whether Docker should use the syslog log driver. Use the attribute set form to customize the receiver address.";
      };
    };
  });
  wrappedUpstreamDockerModule = let
    upstream = upstreamDockerModule upstreamDockerModuleArguments;
  in
    upstream
    // {
      options = lib.recursiveUpdate upstream.options {
        virtualisation.docker.logDriver = lib.mkOption {
          type = logDriverOptionType;
          default = {};
          description = "Docker log driver configuration. Set this to false to disable container logging via Docker’s log drivers.";
        };
      };
    };
  logDriverConfig = config.virtualisation.docker.logDriver;
  syslogConfig = logDriverConfig.syslog;
  jsonEnabled = logDriverConfig.json;
  syslogEnabled = syslogConfig.enabled;
  selectedLogDriver =
    if syslogEnabled then
      "syslog"
    else if jsonEnabled then
      "json-file"
    else
      "none";
in {
  # Upstream exposes `virtualisation.docker.logDriver` as a leaf string option,
  # so we replace that module and re-import a wrapped copy with a richer type.
  disabledModules = ["virtualisation/docker.nix"];
  imports = [wrappedUpstreamDockerModule];
  config = {
    environment.systemPackages = [
      pkgsLatest.docker
    ];
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      daemon.settings = lib.mkMerge [
        {
          log-driver = lib.mkForce selectedLogDriver;
          features.buildkit = true;
          builder = {
            gc = {
              defaultKeepStorage = "4GB";
              enabled = true;
            };
          };
        }
        (lib.mkIf (selectedLogDriver == "json-file") {
          log-opts = {
            max-file = lib.mkDefault "1";
            max-size = lib.mkDefault "20m";
          };
        })
        (lib.mkIf syslogEnabled {
          log-opts = {
            cache-disabled =
              if jsonEnabled then
                "false"
              else
                "true";
            syslog-address = lib.mkDefault "tcp://${syslogConfig.host}:${builtins.toString syslogConfig.port}";
            syslog-format = lib.mkDefault "rfc5424micro";
            tag = lib.mkDefault "{{.Name}}";
          } // lib.optionalAttrs jsonEnabled {
            cache-max-file = lib.mkDefault "1";
            cache-max-size = lib.mkDefault "20m";
          };
        })
      ];
    };
    users.users.jaid.extraGroups = ["docker"];
  };
}

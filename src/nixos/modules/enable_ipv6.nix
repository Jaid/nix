{pkgs, ...} @ input: {
  options.ipv6.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = true;
    description = "Enable IPv6; disabling it can be useful for machines that are in a network without IPv6 support";
  };
  config = pkgs.lib.mkIf (!input.config.ipv6.enable) {
    networking.enableIPv6 = builtins.trace "IPv6 is disabled" false;
    boot.kernelParams = ["ipv6.disable=1"];
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.eno1.disable_ipv6" = 1;
    };
  };
}

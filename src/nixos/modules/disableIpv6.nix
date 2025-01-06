{pkgs, ...} @ input: {
  options.my-modules.ipv6.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = true;
    description = "Enable IPv6";
  };
  config = pkgs.lib.mkIf (!input.config.my-modules.ipv6.enable) {
    network.enableIPv6 = builtins.trace "A" false;
    boot.kernelParams = ["ipv6.disable=1"];
    boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
    boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;
    boot.kernel.sysctl."net.ipv6.conf.eno1.disable_ipv6" = 1;
  };
}

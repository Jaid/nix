{pkgs, ...} @ input: {
  options.jaidCustomModules.performance.enable = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = true;
    description = "Enable various performance optimizations";
  };
  options.jaidCustomModules.performance.unhinged = pkgs.lib.mkOption {
    type = pkgs.lib.types.bool;
    default = false;
    description = "Enables additional performance optimizations, potentially sacrificing stability, security or hardware lifetime";
  };
  config = pkgs.lib.mkIf (input.config.jaidCustomModules.performance.enable) {
    powerManagement.cpuFreqGovernor = "performance";
    boot.kernelParams = pkgs.lib.mkIf input.config.jaidCustomModules.performance.unhinged ["mitigations=off" "quiet"];
    vm.swappiness = 1;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "kernel.sched_autogroup_enabled" = 0;
    };
  };
}

{lib, ...} @ input: {
  options.jaidCustomModules.performance.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable various performance optimizations";
  };
  options.jaidCustomModules.performance.cpuVendor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum ["amd" "intel"]);
    default = null;
    description = "CPU vendor";
  };
  options.jaidCustomModules.performance.unhinged = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enables additional performance optimizations, potentially sacrificing stability, security or hardware lifetime";
  };
  config = lib.mkIf (input.config.jaidCustomModules.performance.enable) {
    powerManagement.cpuFreqGovernor = "performance";
    boot.kernelParams = lib.mkMerge [
      []
      (lib.mkIf input.config.jaidCustomModules.performance.unhinged ["mitigations=off"])
      (lib.mkIf (input.config.jaidCustomModules.performance.cpuVendor == "amd") ["amd_pstate=active"])
    ];
    boot.kernel.sysctl = {
      "vm.swappiness" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "kernel.sched_autogroup_enabled" = 0;
    };
  };
}

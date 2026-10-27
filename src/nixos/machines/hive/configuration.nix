{pkgsUnstable, ...}: {
  imports = [
    ../.base/server/configuration.nix
  ];
  virtualisation.docker.logDriver.syslog = {
    host = "10.0.0.22";
    port = 1514;
  };
  environment.systemPackages = [
    pkgsUnstable.nvtopPackages.amd
    pkgsUnstable.rocmPackages.rocm-smi
    pkgsUnstable.rocmPackages.rocminfo
    pkgsUnstable.amdgpu_top
  ];
  boot.kernelPackages = pkgsUnstable.linuxPackages_latest;
  boot.kernelParams = [
    "console=ttyS1,115200n8"
    "iommu=pt"
    "amdgpu.lockup_timeout=10000" # a cinematic 4320p frame keeps the GPU busy for about 3 s, which the default 2 s watchdog resets as a hang
  ];
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgsUnstable.rocmPackages.clr
      pkgsUnstable.rocmPackages.clr.icd
    ];
  };
  users.users.jaid = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKCde21Ktjoa7PeH3SFH8x59M4s6qxFA6ocp3DxRpnqE localServer"
    ];
  };
  users.users.jaid.extraGroups = ["video" "render"];
}

{pkgsUnstable, ...}: {
  imports = [
    ../.base/server/configuration.nix
  ];
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

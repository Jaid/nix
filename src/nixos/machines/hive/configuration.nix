{pkgs, ...}: {
  imports = [
    ../../software/docker.nix
    ../../software/vscode-server.nix
  ];
  environment.systemPackages = [
    pkgs.nixd
    pkgs.alejandra
    pkgs.nvtopPackages.amd
    pkgs.rocmPackages.rocm-smi
    pkgs.rocmPackages.rocminfo
    pkgs.tmux
    pkgs.pciutils
    pkgs.usbutils
    pkgs.lm_sensors
    pkgs.parted
    pkgs.python312
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "console=ttyS1,115200n8"
    "iommu=pt"
  ];
  programs.nix-ld.enable = true;
  environment.etc."ssh/sshd_conf.d/allow_stream_local_forwarding.conf".text = "AllowStreamLocalForwarding yes";
  networking.firewall.enable = false;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };
  users.users.jaid = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKCde21Ktjoa7PeH3SFH8x59M4s6qxFA6ocp3DxRpnqE localServer"
    ];
  };
  users.users.jaid.extraGroups = ["video" "render"];
}

{pkgs, ...}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  environment.systemPackages = with pkgs; [
    parted
    nvtopPackages.nvidia
    grc
    nixd
    alejandra
    kitty
    libvirt
    qemu
    nodejs_23
    yarn-berry
    parted
  ];
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "tower";
  virtualisation.libvirtd.enable = true;
  users.users.jaid.extraGroups = ["libvirt"];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  home-manager.backupFileExtension = "bak";
  home-manager.users.jaid.home = {
    sessionPath = [
      "/home/jaid/x"
      "/home/jaid/git/.foreign/scripts/bin"
    ];
  };
}

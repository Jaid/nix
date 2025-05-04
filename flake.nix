{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
  };
  outputs = inputs: let
    makeMachine = {
      id,
      system ? "x86_64-linux",
      cudaComputeCapability ? "8.9",
      cpuArch ? "znver2",
      isVm ? false,
      modules ? [],
    }: let
      nixpkgsAttributes = {
        inherit system;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
      };
      nixpkgsPersonalAttributes = {
        inherit system;
        config = {
          hostPlatform.gcc.arch = cpuArch;
          allowUnfree = true;
          nvidia.acceptLicense = true;
          cudaSupport = true;
          cudnnSupport = true;
          cudaForwardCompat = false;
          cudaEnableForwardCompat = false;
          cudaCapabilities = [cudaComputeCapability];
          rocmSupport = false;
          packageOverrides = pkgs: {
            shantell-sans = pkgs.callPackage ./src/nix/packages/shantell-sans.nix {};
            geologica = pkgs.callPackage ./src/nix/packages/geologica.nix {};
          };
        };
      };
      pkgs = import inputs.nixpkgs nixpkgsAttributes;
      pkgsUnstable = import inputs.nixpkgs-unstable nixpkgsAttributes;
      pkgsLatest = import inputs.nixpkgs-latest nixpkgsAttributes;
      pkgsPersonal = import inputs.nixpkgs nixpkgsPersonalAttributes;
      pkgsUnstablePersonal = import inputs.nixpkgs-unstable nixpkgsPersonalAttributes;
      pkgsLatestPersonal = import inputs.nixpkgs-latest nixpkgsPersonalAttributes;
      specialArgs = {
        inherit pkgs;
        inherit pkgsUnstable;
        inherit pkgsLatest;
        inherit pkgsPersonal;
        inherit pkgsUnstablePersonal;
        inherit pkgsLatestPersonal;
      };
    in
      builtins.trace "Building ${id} (${system}, ${cpuArch}, ${cudaComputeCapability})" inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules =
          modules
          ++ [
            {
              networking.hostName = id;
            }
            inputs.home-manager.nixosModules.home-manager
            ./src/home-manager/homes/linux/jaid.nix
            ./src/home-manager/homes/${id}/jaid.nix
            ./src/nixos/common.nix
            ./src/nixos/locales/en-de.nix
            ./src/nixos/users/jaid.nix
            ./src/nix/config.nix
            ./src/nixos/modules/xnview.nix
            ./src/nixos/modules/qemu.nix
            ./src/nixos/modules/gnome-wayland
            ./src/nixos/modules/eza.nix
            ./src/nixos/modules/performance
            ./src/nixos/machines/${id}/configuration.nix
          ]
          ++ (if isVm then [

          ] else [
            ./src/nixos/machines/${id}/hardware-configuration.nix
          ]);
      };
  in {
    nixosConfigurations.tower = makeMachine {
      id = "tower";
    };
    nixosConfiguration.tower-vm = makeMachine {
      id = "tower-vm";
      isVm = true;
    };
    nixosConfigurations.nas = makeMachine {
      id = "nas";
    };
  };
}

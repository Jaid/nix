{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    llama-cpp.url = "github:ggerganov/llama.cpp";
  };
  outputs = inputs: let
    system = "x86_64-linux";
    cudaComputeCapability = "8.9";
    cpuArch = "znver2";
    nixpkgsAttributes = {
      inherit system;
      config.allowUnfree = true;
    };
    nixpkgsPersonalAttributes = {
      inherit system;
      config = {
        hostPlatform.gcc.arch = cpuArch;
        allowUnfree = true;
        cudaSupport = true;
        cudnnSupport = true;
        cudaForwardCompat = false;
        cudaEnableForwardCompat = false;
        cudaCapabilities = [cudaComputeCapability];
        rocmSupport = false;
        packageOverrides = pkgs: {
          llama-cpp = inputs.llama-cpp.packages.${system}.cuda;
          shantell-sans = (pkgs.callPackage ./src/nix/packages/shantell-sans.nix {});
          geologica = (pkgs.callPackage ./src/nix/packages/geologica.nix {});
        };
      };
    };
    pkgs = import inputs.nixpkgs nixpkgsAttributes;
    pkgsUnstable = import inputs.nixpkgs-unstable nixpkgsAttributes;
    pkgsLatest = import inputs.nixpkgs-latest nixpkgsAttributes;
    pkgsPersonal = import inputs.nixpkgs nixpkgsPersonalAttributes;
    pkgsUnstablePersonal = import inputs.nixpkgs-unstable nixpkgsPersonalAttributes;
    pkgsLatestPersonal = import inputs.nixpkgs-latest nixpkgsPersonalAttributes;
    commonModules = [
      inputs.home-manager.nixosModules.home-manager
      ./src/home-manager/homes/linux/jaid.nix
      ./src/nixos/common.nix
      ./src/nixos/locales/en-de.nix
      ./src/nixos/users/jaid.nix
      ./src/nix/config.nix
      ./src/nixos/modules/xnview.nix
      ./src/nixos/modules/qemu.nix
      ./src/nixos/modules/gnome-wayland
      ./src/nixos/modules/eza.nix
      ./src/nixos/modules/performance
    ];
    specialArgs = {
      inherit pkgs;
      inherit pkgsUnstable;
      inherit pkgsLatest;
      inherit pkgsPersonal;
      inherit pkgsUnstablePersonal;
      inherit pkgsLatestPersonal;
    };
  in {
    nixosConfigurations.tower = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      modules =
        commonModules
        ++ [
          ./src/home-manager/homes/tower/jaid.nix
          ./src/nixos/machines/tower/configuration.nix
          ./src/nixos/machines/tower/hardware-configuration.nix
        ];
    };
  };
}

{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    home-manager.url = "github:nix-community/home-manager?ref=release-25.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = inputs: let
    makeMachine = {
      id,
      system ? "x86_64-linux",
      cudaComputeCapability ? "8.9",
      cpuArch ? "znver2",
      gpuVendor ? "nvidia",
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
          cudaSupport = (gpuVendor == "nvidia");
          cudnnSupport = (gpuVendor == "nvidia");
          cudaForwardCompat = false;
          cudaEnableForwardCompat = false;
          cudaCapabilities = [cudaComputeCapability];
          rocmSupport = (gpuVendor == "amd");
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
        inherit pkgsUnstable;
        inherit pkgsLatest;
        inherit pkgsPersonal;
        inherit pkgsUnstablePersonal;
        inherit pkgsLatestPersonal;
      };
    in
      builtins.trace "Building ${id} (${system}, ${cpuArch}, ${cudaComputeCapability})" inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          [
            inputs.nixpkgs.nixosModules.readOnlyPkgs
            {
              nixpkgs.pkgs = pkgs;
            }
          ]
          ++
          modules
          ++ [
            {
              networking.hostName = id;
              environment.sessionVariables.HOSTNAME = id;
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
    nixosConfigurations = {
      tower = makeMachine {
        id = "tower";
      };
      tower-vm = makeMachine {
        id = "tower-vm";
        isVm = true;
      };
      nas = makeMachine {
        id = "nas";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
      cx = makeMachine {
        id = "cx";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
      hive = makeMachine {
        id = "hive";
        cpuArch = "znver2";
        gpuVendor = "amd";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
    };
  };
}

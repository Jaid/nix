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
    nixpkgsAttributes = {
      inherit system;
      config.allowUnfree = true;
    };
    nixpkgsCudaAttributes =
      {
        config.cudaSupport = true;
        config.cudaCapabilities = ["8.9"];
        config.packageOverrides = pkgs: {
          llama-cpp = inputs.llama-cpp.packages.${system}.cuda;
        };
      }
      // nixpkgsAttributes;
    pkgs = import inputs.nixpkgs nixpkgsAttributes;
    pkgsStable = import inputs.nixpkgs nixpkgsCudaAttributes;
    pkgsUnstable = import inputs.nixpkgs-unstable nixpkgsCudaAttributes;
    pkgsLatest = import inputs.nixpkgs-latest nixpkgsCudaAttributes;
    linuxModules = [
      inputs.home-manager.nixosModules.home-manager
      ./src/home-manager/homes/linux/jaid.nix
      ./src/nixos/common.nix
      ./src/nixos/locales/en-de.nix
      ./src/nixos/users/jaid.nix
      ./src/nix/config.nix
    ];
    specialArgs = {
      inherit pkgs;
      inherit pkgsStable;
      inherit pkgsUnstable;
      inherit pkgsLatest;
    };
  in {
    nixosConfigurations.tower = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      modules =
        linuxModules
        ++ [
          ./src/home-manager/homes/tower/jaid.nix
          ./src/nixos/machines/tower/configuration.nix
          ./src/nixos/machines/tower/hardware-configuration.nix
        ];
    };
    nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      modules =
        linuxModules
        ++ [
          ./src/home-manager/homes/vm/jaid.nix
          ./src/nixos/machines/vm/configuration.nix
          ./src/nixos/machines/vm/hardware-configuration.nix
        ];
    };
  };
}

{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    llama-cpp.url = "github:ggerganov/llama.cpp";
  };
  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    llama-cpp,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    nixpkgsAttributes = {
      inherit system;
      config.allowUnfree = true;
      config.cudaSupport = true;
      config.cudaCapabilities = ["8.9"];
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsStable = import nixpkgs nixpkgsAttributes;
    pkgsUnstable = import nixpkgs-unstable nixpkgsAttributes;
    pkgsLatest = import nixpkgs-latest (nixpkgsAttributes
      // {
        config.packageOverrides = pkgs: {
          llama-cpp = llama-cpp.packages.${system}.cuda;
        };
      });
  in {
    nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ./src/homes/tower/jaid.nix
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/tower/configuration.nix
        ./src/machines/tower/hardware-configuration.nix
        ./src/software/gnome.nix
        ./src/software/desktop-apps.nix
        #./src/packages/llama-cpp.nix
        ./src/packages/ghostty.nix
        ./src/no-ipv6.nix
      ];
      specialArgs = {
        inherit pkgs;
        inherit pkgsStable;
        inherit pkgsUnstable;
        inherit pkgsLatest;
      };
    };
  };
}

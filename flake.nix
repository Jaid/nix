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
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    flake-utils,
    llama-cpp,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    nixpkgsAttributes = {
      inherit system;
      config.allowUnfree = true;
      config.cudaSupport = true;
      config.cudaCapabilities = ["8.9"];
    };
    pkgs = import nixpkgs nixpkgsAttributes;
    pkgsUnstable = import nixpkgs-unstable nixpkgsAttributes;
    pkgsLatest = import nixpkgs-latest (nixpkgsAttributes
      // {
        config.packageOverrides = pkgs: {
          llama-cpp = llama-cpp.packages.${system}.cuda;
        };
      });
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/vm/configuration.nix
        ./src/machines/vm/hardware-configuration.nix
        ./src/homes/vm/jaid.nix
        ./src/software/gnome.nix
        {
          environment.systemPackages = [
            nixpkgs-unstable.legacyPackages.${system}.ghostty
            nixpkgs-unstable.legacyPackages.${system}.firefox
          ];
        }
      ];
      specialArgs = {inherit inputs;};
    };
    nixosConfigurations.qemu = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/qemu/configuration.nix
        ./src/machines/qemu/hardware-configuration.nix
        ./src/homes/qemu/jaid.nix
        ./src/software/gnome.nix
        ./src/software/doas.nix
        ./src/test.nix
      ];
      specialArgs = {inherit inputs;};
    };
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/nas/configuration.nix
        ./src/machines/nas/hardware-configuration.nix
        ./src/software/docker.nix
        ./src/software/vscode-server.nix
        ./src/homes/nas/jaid.nix
      ];
      specialArgs = {inherit inputs;};
    };
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
        {
          environment.systemPackages = [
            pkgsUnstable.ghostty
            (pkgsUnstable.ollama.override {
              acceleration = "cuda";
            })
            (pkgsLatest.llama-cpp.override {
              enableCurl = false;
            })
          ];
        }
        {
          networking.enableIPv6 = false;
          boot.kernelParams = ["ipv6.disable=1"];
          boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
          boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;
          boot.kernel.sysctl."net.ipv6.conf.eno1.disable_ipv6" = 1;
        }
      ];
      specialArgs = {inherit inputs;};
    };
  };
}

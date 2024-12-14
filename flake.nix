{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... } @inputs: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/vm/configuration.nix
        ./src/machines/vm/hardware-configuration.nix
        ./src/homes/vm/jaid.nix
        ./src/software/gnome.nix
        ./src/software/xnview.nix
      ];
      specialArgs = { inherit inputs; };
    };
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
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
        ./src/test.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}

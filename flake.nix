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
  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./src/machines/vm/configuration.nix
        ./src/machines/vm/hardware-configuration.nix
        ./src/software/gnome.nix
        ./src/users/jaid.nix
        ./src/locales/en-de.nix
        ./src/common.nix
      ];
    };
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./src/machines/nas/configuration.nix
        ./src/machines/nas/hardware-configuration.nix
        ./src/users/jaid.nix
        ./src/locales/en-de.nix
        ./src/common.nix
        # ./src/software/docker.nix
        ./src/software/vscode-server.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            # useUserPackages = true;
            users.jaid = import ./src/homes/jaid.nix;
          };
        }
      ];
    };
  };
}

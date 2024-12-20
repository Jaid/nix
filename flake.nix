{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
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
      specialArgs = {inherit inputs;};
    };
    nixosConfigurations.qemu = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/qemu/configuration.nix
        ./src/machines/qemu/hardware-configuration.nix
        ./src/homes/qemu/jaid.nix
        ./src/software/gnome.nix
      ];
      specialArgs = {inherit inputs;};
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
      ];
      specialArgs = {inherit inputs;};
    };
    nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
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
        ./src/test.nix
      ];
      specialArgs = {inherit inputs;};
    };
  };
}

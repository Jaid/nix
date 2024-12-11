{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = { self, nixpkgs }: {
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
  };
}

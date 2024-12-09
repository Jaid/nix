{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # hardware.url = "path:/etc/nixos/hardware-configuration.nix";
  };
  outputs = { self, nixpkgs, hardware }: {
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hardware
        ./src/machines/vm/configuration.nix
      ];
    };
  };
}

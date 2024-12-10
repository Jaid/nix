{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hardware
        ./hardware-configuration.nix
      ];
    };
  };
}

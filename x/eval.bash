nix eval .#nixosConfigurations.${HOSTNAME:-$(hostname)}.config

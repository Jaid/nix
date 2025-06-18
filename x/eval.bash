HOSTNAME=${HOSTNAME:-$(hostname)}
nix eval .#nixosConfigurations.tower.config

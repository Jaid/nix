# Nix setup

## Installation

This can be executed from a GUI-less live system session.

```bash
device=${device:-/dev/sda}
bootDevicePartition=${bootDevicePartition:-${device}1}
rootDevicePartition=${rootDevicePartition:-${device}2}
sudo parted $device -- mklabel gpt
sudo parted $device -- mkpart ESP fat32 1MiB 512MiB
sudo parted $device -- set 1 esp on
sudo parted $device -- mkpart root ext4 512MiB 100%
sudo mkfs.vfat -F32 -n boot $bootDevicePartition
sudo mkfs.ext4 -L root $rootDevicePartition
sudo mount /dev/disk/by-label/root /mnt
sudo mkdir /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
sudo nixos-generate-config --root /mnt
sudo nixos-install --flake github:Jaid/nix#tower --no-write-lock-file --impure
```

## Useful scripts

### Rebuilding the running NixOS system

```bash 
#!/usr/bin/env -S bash -o errexit -o pipefail -o nounset
sudo nixos-rebuild --option auto-optimise-store true --option extra-experimental-features flakes --option extra-experimental-features nix-command --option accept-flake-config true switch --flake "github:Jaid/nix#$(hostname)"
```

### Test system in a QEMU VM

```bash
#!/usr/bin/env -S bash -o errexit -o pipefail -o nounset
target=tower
tempFolder=$(mktemp --directory)
nix build "Jaid/nix#nixosConfigurations.$target.config.system.build.vm" --option auto-optimise-store true --option accept-flake-config true --out-link "$tempFolder/link"
TMPDIR=$tempFolder NIX_DISK_IMAGE=$tempFolder/disk.qcow2 $tempFolder/link/bin/run-$target-vm -m 4G
```

### Show flake metadata

```bash
#!/usr/bin/env -S nix shell --quiet github:NixOS/nixpkgs/nixos-unstable#yq github:NixOS/nixpkgs/nixos-unstable#bat --command bash -o errexit -o pipefail -o nounset
nix flake metadata github:Jaid/nix --json | yq --yaml-output --yaml-output-grammar-version 1.2 | bat --language yaml --pager '' --plain --force-colorization
```

### Check flake

```bash 
#!/usr/bin/env -S bash -o errexit -o pipefail -o nounset
nix flake check github:Jaid/nix --verbose --show-trace
```

### Cleaning

```bash
#!/usr/bin/env -S nix shell --quiet github:NixOS/nixpkgs/nixos-unstable#gdu --command bash -o errexit -o pipefail -o nounset
nix shell --quiet github:NixOS/nixpkgs/nixos-unstable#gdu --command gdu --non-interactive --summarize --si /nix/store
nix store gc
nix shell --quiet github:NixOS/nixpkgs/nixos-unstable#gdu --command gdu --non-interactive --summarize --si /nix/store
```

### Dump current dconf
```bash
#!/usr/bin/env -S nix shell --quiet github:NixOS/nixpkgs/nixos-unstable#dconf github:NixOS/nixpkgs/nixos-unstable#bat --command bash -o errexit -o pipefail -o nounset
dconf dump / | bat --paging never --language ini --decorations never
```

## Links

### Docs

- [nix.dev](https://nix.dev/reference) ([source](https://github.com/NixOS/nix.dev/tree/master/source))
- [Nix manual](https://nix.dev/manual/nix/rolling)
- [NixOS manual](https://nixos.org/manual/nixos/stable)
- [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable)
- [Home-Manager manual](https://nix-community.github.io/home-manager)

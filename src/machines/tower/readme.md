# VM

## Preparition

```bash
sudo parted /dev/sda -- mklabel gpt && sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB && sudo parted /dev/sda -- set 1 esp on && mkpart root ext4 512MiB 100% && sudo mkfs.vfat -F32 -n boot /dev/sda1 && sudo mkfs.ext4 -L root /dev/sda2
```
```bash
sudo mount /dev/disk/by-label/root /mnt
sudo mkdir /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```
```bash
nixos-install --flake github:Jaid/nix/dev#tower --no-write-lock-file --impure
```

## Installation

```bash
nix-collect-garbage -d && nixos-rebuild switch --flake 'github:Jaid/nix/dev#tower' --no-write-lock-file && gdu --non-interactive --summarize /nix/store && lsblk
```

## ISO creation

```bash
git clone https://github.com/Jaid/nix
cd nix
git switch dev
nix run github:nix-community/nixos-generators -- --flake .#tower --format iso
```

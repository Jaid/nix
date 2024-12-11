# VM

## Preparition

```bash
sudo parted "/dev/sd${deviceLetter:-a}" -- mklabel gpt && sudo parted "/dev/sd${deviceLetter:-a}" -- mkpart primary fat32 1MiB 513MiB && sudo parted "/dev/sd${deviceLetter:-a}" -- mkpart primary ext4 513MiB 100% && sudo mkfs.vfat -F32 "/dev/sd${deviceLetter:-a}1" && sudo mkfs.ext4 "/dev/sd${deviceLetter:-a}2" && lsblk
```

## Installation

```bash
nix-collect-garbage -d && nixos-rebuild switch --flake 'github:Jaid/nix/dev#vm' --no-write-lock-file
```

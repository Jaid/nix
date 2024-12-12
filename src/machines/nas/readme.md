# NAS

## Installation
```bash
lsblk --output SERIAL,LABEL,NAME,MOUNTPOINTS,SIZE,FSUSE%,UUID
```
```bash
sudo parted /dev/nvme1n1 -- mklabel gpt && sudo parted /dev/nvme1n1 -- mkpart ESP fat32 1MiB 512MiB && sudo parted /dev/nvme1n1 -- set 1 esp on && mkpart root ext4 512MiB 100% && sudo mkfs.vfat -F32 -n boot /dev/nvme1n1p1 && sudo mkfs.ext4 -L root /dev/nvme1n1p2
```
```bash
sudo mount /dev/disk/by-label/root /mnt
mkdir /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```
```bash
sudo nixos-generate-config --root /mnt
```
```bash
nixos-install --flake github:Jaid/nix/dev#nas --no-write-lock-file --impure
```

## Rebuilding
```bash
nixos-rebuild switch --flake github:Jaid/nix/dev#nas --no-write-lock-file --impure
```

# Nix setup

## Installation

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
sudo nixos-install
sudo nixos-install --flake github:Jaid/nix --no-write-lock-file --impure
```

# Machine: cx

## Hardware

• Hetzner Cloud CX 23 (cx23)
• 2 vCPU (shared)
• 4 gb RAM
• 40 gb local storage
• Location: Nuremberg, Germany (nbg1)
• ISO: nixos-minimal-25.05.803396.8f1b52b04f2c-x86_64-linux.iso

## Installation

CX boots in legacy BIOS (SeaBIOS) by default, so use an MBR layout and GRUB. If Hetzner switches the VM to UEFI mode, stop here and use a GPT + ESP install instead.

```bash
loadkeys de
```

```bash
test -d /sys/firmware/efi && echo "UEFI (unexpected)" || echo "BIOS (expected)"
```

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
```

```bash
device=${device:-/dev/sda}
rootDevicePartition=${rootDevicePartition:-${device}1}
sudo wipefs -a $device
sudo parted --script $device -- mklabel msdos
sudo parted $device -- mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L root $rootDevicePartition
sudo mount /dev/disk/by-label/root /mnt
sudo nixos-generate-config --root /mnt
sudo nixos-install --flake github:Jaid/nix#cx --no-write-lock-file --impure
```

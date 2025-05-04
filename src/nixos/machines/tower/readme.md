# Machine: tower

## Hardware

• GIGABYTE B550 AORUS Elite
• AMD Ryzen 9 3900X
• Nvidia GeForce RTX 4070 (12 gb)
• 2× G.Skill Trident Z Neo DIMM (16 gb, DDR4-3600, CL 16-19-19-39)
• Acer XF240Hbmjdpr (1920×1080, 144 hz, 8 bit, 24″)
• Wacom Cintiq Pro 13 (1920×1080, 60 hz, 8 bit, 13″)
• InnoCN 32C1U (3840×2160, 60 hz, 10 bit HDR, 31.5″)
• Crucial CT4000P3PSSD8 (4 tb, NVMe 1.4)
• no WiFi
• no Bluetooth
Peripherals:
• Corsair Gaming K63 (DE layout)
• Roccat Burst Pro Air
Environment:
• HP LaserJet Pro MFP M28w
• Redmi AX6S (flashed with OpenWrt)

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

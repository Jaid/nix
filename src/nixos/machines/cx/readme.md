# Machine: cx

## Hardware

• Hetzner Cloud CX 23 (cx23)
• 2 vCPU (shared)
• 4 gb RAM
• 40 gb local storage
• Location: Nuremberg, Germany (nbg1)
• ISO: nixos-minimal-25.05.803396.8f1b52b04f2c-x86_64-linux.iso

## Installation (manual)

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
sudo wipefs --all /dev/sda
sudo parted --script /dev/sda -- mklabel msdos
sudo parted /dev/sda -- mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L root /dev/sda1
sudo mount /dev/disk/by-label/root /mnt
sudo nixos-generate-config --root /mnt
sudo nixos-install --flake github:Jaid/nix#cx --no-write-lock-file --impure
```

## Installation (infect)

Run this after first start to convert the system from Ubuntu 24.04 to NixOS.

```bash
curl -fsSL https://raw.githubusercontent.com/Jaid/nix/main/src/nixos/machines/cx/infect-install.bash -o /root/infect-install.bash
chmod +x /root/infect-install.bash
SKIP_CONFIRM=1 /root/infect-install.bash
```

Defaults:

• `DISK=/dev/sda`
• `FLAKE=github:Jaid/nix#cx`
• BIOS/MBR only (script aborts on UEFI)

Examples:

```bash
# install to another disk
DISK=/dev/vda SKIP_CONFIRM=1 /root/infect-install.bash
```

```bash
# install from local checkout instead of GitHub
FLAKE=/root/nix#cx SKIP_CONFIRM=1 /root/infect-install.bash
```

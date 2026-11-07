# Machine: cx

## Hardware

• Hetzner Cloud CX 23 (cx23)
• 2 vCPU (shared)
• 4 gb RAM
• 40 gb local storage
• Location: Falkenstein, Germany (fsn1)
• ISO (manual installation only): NixOS 26.05 minimal (x86_64-linux)

## Network

• Public IPv4 2.31.222.251 via DHCP
• Public IPv6 2a01:4f8:c016:949f::1/64, configured statically in `hardware-configuration.nix` because Hetzner doesn’t hand it out dynamically – update it when the server gets recreated
• Private network “networkMain” 10.10.0.0/16 (cloud subnet 10.10.0.0/24, server 10.10.0.2 via DHCP), deliberately not overlapping with the LAN’s 10.0.0.0/24

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

Run this after first start to convert the system from Hetzner’s Ubuntu image (tested with 26.04) to NixOS.

For unattended provisioning in Hetzner, use `src/nixos/machines/cx/cloud-init.yml` as user-data.
If something fails during automated setup, inspect `/var/log/infect-install.log` and `/var/log/cloud-init-output.log`.

```bash
curl -fsSL https://raw.githubusercontent.com/Jaid/nix/main/src/nixos/machines/cx/infect-install.bash -o /root/infect-install.bash
chmod +x /root/infect-install.bash
SKIP_CONFIRM=1 /root/infect-install.bash
```

Defaults:

• `REPARTITION=0` (default, in-place install on current root partition)
• `FLAKE=github:Jaid/nix#cx`
• BIOS/MBR only (script aborts on UEFI)

Examples:

```bash
# destructive reinstall with repartitioning
REPARTITION=1 DISK=/dev/sda SKIP_CONFIRM=1 /root/infect-install.bash
```

```bash
# install from local checkout instead of GitHub
FLAKE=/root/nix#cx SKIP_CONFIRM=1 /root/infect-install.bash
```

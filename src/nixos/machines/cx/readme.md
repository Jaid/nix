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

## Installation (rescue)

Installing in-place over Hetzner’s Ubuntu doesn’t work, because NixOS can’t take over Ubuntu’s `/etc/systemd/system` and `/etc/udev/rules.d` directories. Instead, boot into the Hetzner rescue system (Server → Rescue → Enable rescue & power cycle, with the “vps” SSH key) and wipe the disk from there.

```bash
ssh -i ~/.ssh/id_vps root@2.31.222.251
```

```bash
curl -fsSL https://raw.githubusercontent.com/Jaid/nix/main/src/nixos/machines/cx/rescue-install.bash -o /root/rescue-install.bash
chmod +x /root/rescue-install.bash
SKIP_CONFIRM=1 /root/rescue-install.bash
reboot
```

Rescue mode is only active for the next boot, so the reboot lands in NixOS. The rescue system’s host key differs from NixOS’s, so drop the old known_hosts entry afterwards with `ssh-keygen -R 2.31.222.251`.

Defaults:

• `DISK=/dev/sda` (gets wiped: msdos + single ext4 partition labeled “root”)
• `FLAKE=github:Jaid/nix#cx`
• BIOS/MBR only (script aborts on UEFI)

```bash
# install a specific commit
FLAKE=github:Jaid/nix/<commit>#cx SKIP_CONFIRM=1 /root/rescue-install.bash
```

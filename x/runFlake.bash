#/usr/bin/env bash
set -o errexit -o nounset -o pipefail
host=vm
storageFile=$HOME/vm/nixos/sda.qcow2
isoFile=$HOME/Downloads/thorium/nixos-minimal-24.11.711349.394571358ce8-x86_64-linux.iso
if [ ! -f $storageFile ]; then
  sudo modprobe nbd
  qemu-img create -f qcow2 $storageFile 16G
  sudo qemu-nbd --connect=/dev/nbd0 $storageFile
  sudo parted /dev/nbd0 -- mklabel gpt
  sudo parted /dev/nbd0 -- mkpart ESP fat32 1MiB 512MiB
  sudo parted /dev/nbd0 -- set 1 esp on
  sudo parted /dev/nbd0 -- mkpart root ext4 512MiB 100%
  sudo mkfs.vfat -F32 -n boot /dev/nbd0p1
  sudo mkfs.ext4 -L root /dev/nbd0p2
  sudo qemu-nbd --disconnect /dev/nbd0
  nix run github:nix-community/nixos-generators -- --flake $HOME/git/nix#qemu --format iso
  qemu-system-x86_64 -enable-kvm -m 4G -smp cores=4 -nic user -drive "file=$storageFile,index=0,media=disk" -vga std -cdrom "$isoFile" -boot d
  exit 0
fi

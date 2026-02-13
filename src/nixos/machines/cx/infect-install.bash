#!/usr/bin/env bash
set -euo pipefail

DISK="${DISK:-/dev/sda}"
FLAKE="${FLAKE:-github:Jaid/nix#cx}"
ROOT_LABEL="${ROOT_LABEL:-root}"
SWAPFILE="${SWAPFILE:-/swapfile-nixos-infect}"

log() {
  printf "\n==> %s\n" "$*"
}

die() {
  printf "\nERROR: %s\n" "$*" >&2
  exit 1
}

if [[ "${EUID}" -ne 0 ]]; then
  die "Run as root"
fi

if [[ ! -b "${DISK}" ]]; then
  die "Disk ${DISK} does not exist"
fi

if [[ -d /sys/firmware/efi ]]; then
  die "UEFI detected. This script is for BIOS/MBR installs only. Use GPT + ESP for UEFI."
fi

if ! command -v apt-get >/dev/null 2>&1; then
  die "apt-get is required (expected Ubuntu 24.04 default image)"
fi

log "Installing prerequisites"
apt-get update
apt-get install -y curl parted e2fsprogs util-linux xz-utils

if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix (daemon mode)"
  sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi

if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [[ -e /etc/profile.d/nix.sh ]]; then
  # shellcheck disable=SC1091
  source /etc/profile.d/nix.sh
fi

command -v nix >/dev/null 2>&1 || die "nix command not found after installation"

export NIX_CONFIG="experimental-features = nix-command flakes"

if [[ -z "${SKIP_CONFIRM:-}" ]]; then
  echo "This will WIPE ${DISK} and install ${FLAKE}."
  read -r -p "Type 'yes' to continue: " reply
  [[ "${reply}" == "yes" ]] || die "Aborted"
fi

cleanup() {
  set +e
  if swapon --show=NAME | grep -q "^${SWAPFILE}$"; then
    swapoff "${SWAPFILE}"
  fi
  rm -f "${SWAPFILE}"
}
trap cleanup EXIT

if [[ ! -f "${SWAPFILE}" ]]; then
  log "Creating temporary swap (${SWAPFILE})"
  fallocate -l 2G "${SWAPFILE}" || dd if=/dev/zero of="${SWAPFILE}" bs=1M count=2048
  chmod 600 "${SWAPFILE}"
  mkswap "${SWAPFILE}"
  swapon "${SWAPFILE}"
fi

log "Partitioning ${DISK} (msdos + single ext4 root partition)"
wipefs --all "${DISK}"
parted --script "${DISK}" -- mklabel msdos
parted --script "${DISK}" -- mkpart primary ext4 1MiB 100%

ROOT_PART="${DISK}1"
if [[ "${DISK}" =~ (nvme|mmcblk) ]]; then
  ROOT_PART="${DISK}p1"
fi

log "Formatting ${ROOT_PART}"
mkfs.ext4 -F -L "${ROOT_LABEL}" "${ROOT_PART}"

log "Mounting target filesystem"
umount -R /mnt 2>/dev/null || true
mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt

log "Generating baseline hardware configuration"
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#nixos-install-tools -c \
  nixos-generate-config --root /mnt

log "Installing NixOS from ${FLAKE}"
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#nixos-install-tools -c \
  nixos-install --root /mnt --flake "${FLAKE}" --no-write-lock-file --impure

log "Done. Reboot when ready."

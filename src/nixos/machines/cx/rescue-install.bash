#!/usr/bin/env bash
set -euo pipefail

# Run this from the Hetzner rescue system. It wipes ${DISK} and installs NixOS onto it.
# Installing in-place over Ubuntu does not work: NixOS needs /etc/systemd/system and /etc/udev/rules.d to be symlinks, Ubuntu leaves real directories there, and the systemd initrd cannot lustrate them away.

DISK="${DISK:-/dev/sda}"
FLAKE="${FLAKE:-github:Jaid/nix#cx}"
ROOT_LABEL="${ROOT_LABEL:-root}"
SWAPFILE="${SWAPFILE:-/mnt/swapfile-nixos-install}"

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
  die "apt-get is required (expected the Debian-based Hetzner rescue system)"
fi

umount -R /mnt 2>/dev/null || true
if lsblk -n -o MOUNTPOINTS "${DISK}" | grep -q .; then
  die "${DISK} is still in use. Boot into the Hetzner rescue system first."
fi

log "Installing prerequisites"
apt-get update
apt-get install -y curl parted e2fsprogs util-linux xz-utils

if ! command -v nix >/dev/null 2>&1; then
  if [[ -d /run/systemd/system ]]; then
    log "Installing Nix (daemon mode)"
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
  else
    log "Installing Nix (single-user mode)"
    sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes
  fi
fi

if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
if [[ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

command -v nix >/dev/null 2>&1 || die "nix command not found after installation"

export NIX_CONFIG="experimental-features = nix-command flakes"

if [[ -z "${SKIP_CONFIRM:-}" ]]; then
  echo "This will WIPE ${DISK} and install ${FLAKE}."
  read -r -p "Type 'yes' to continue: " reply
  [[ "${reply}" == "yes" ]] || die "Aborted"
fi

log "Partitioning ${DISK} (msdos + single ext4 root partition)"
wipefs --all "${DISK}"
parted --script "${DISK}" -- mklabel msdos
parted --script "${DISK}" -- mkpart primary ext4 1MiB 100%

ROOT_PART="${DISK}1"
if [[ "${DISK}" =~ (nvme|mmcblk) ]]; then
  ROOT_PART="${DISK}p1"
fi
udevadm settle

log "Formatting ${ROOT_PART}"
mkfs.ext4 -F -L "${ROOT_LABEL}" "${ROOT_PART}"
udevadm settle

log "Mounting target filesystem"
mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt

cleanup() {
  set +e
  if swapon --show=NAME | grep -q "^${SWAPFILE}$"; then
    swapoff "${SWAPFILE}"
  fi
  rm -f "${SWAPFILE}"
}
trap cleanup EXIT

# the rescue system lives in RAM, so the swap file has to be on the target disk
log "Creating temporary swap (${SWAPFILE})"
fallocate -l 2G "${SWAPFILE}"
chmod 600 "${SWAPFILE}"
mkswap "${SWAPFILE}"
swapon "${SWAPFILE}"

log "Installing NixOS from ${FLAKE}"
nix shell nixpkgs#nixos-install-tools --command \
  nixos-install --root /mnt --flake "${FLAKE}" --no-write-lock-file --no-root-password

log "Done. Disable rescue mode and reboot."

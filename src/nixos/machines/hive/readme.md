```bash
sudo wipefs --all /dev/nvme0n1
sudo wipefs --all /dev/nvme1n1
sudo parted --script /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart root ext4 512MiB 100%
sudo mkfs.vfat -F32 -n boot /dev/nvme0n1p1
sudo mkfs.ext4 -L root /dev/nvme0n1p2
sudo parted --script /dev/nvme1n1 -- mklabel gpt
sudo parted /dev/nvme1n1 -- mkpart swap linux-swap 1MiB 100000MiB
sudo parted /dev/nvme1n1 -- mkpart data btrfs 100000MiB 100%
sudo mkswap -L swap /dev/nvme1n1p1
sudo swapon /dev/nvme1n1p1
sudo mkfs.btrfs -L data /dev/nvme1n1p2
sudo mount /dev/disk/by-label/root /mnt
sudo mkdir /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
sudo nixos-generate-config --root /mnt
sudo nixos-install --flake github:Jaid/nix#hive --no-write-lock-file --impure
```

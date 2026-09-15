//INSTRUCTION TO PARTITION DRIVE\\

fdisk /dev/sda
g -> create partitiontable
n -> new partition

"1" type partitionnumber
"ENTER" partition start
"+1GB" partition end

n -> new partition
"2" type partitionnumber
"ENTER" partition start
"+1GB" partition end

w -> save



sudo mkfs.fat -F32 /dev/sda1
sudo mkfs.ext4 /dev/sda2

sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot



mkdir /mnt/etc/nixos
git clone https://github.com/schlenko/FirstPush.git

rm -r hardware-configuration.nix
sudo nixos-generate-config --root /mnt

sudo nixos-install --flake /mnt/etc/nixos#nixos

sudo nixos-install --flake /mnt/etc/nixos#nixos 2>&1 | tee /mnt/nixos-install.log
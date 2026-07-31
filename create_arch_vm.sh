#!/usr/bin/env bash
set -e

echo "Downloading Arch Linux ISO..."
mkdir -p "$HOME/Downloads"
# wget -qc continues the download if it already exists
wget -qc -O "$HOME/Downloads/archlinux.iso" https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso || wget -O "$HOME/Downloads/archlinux.iso" https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso

echo "Creating VM..."
VBoxManage createvm --name "ArchLinux" --ostype "ArchLinux_64" --register

echo "Configuring VM..."
VBoxManage modifyvm "ArchLinux" --memory 4096 --cpus 2 --vram 128 --graphicscontroller vmsvga --nic1 nat

echo "Creating VDI..."
VBoxManage createmedium disk --filename "$HOME/VirtualBox VMs/ArchLinux/ArchLinux.vdi" --size 30720

echo "Adding Storage Controllers..."
VBoxManage storagectl "ArchLinux" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storagectl "ArchLinux" --name "IDE Controller" --add ide

echo "Attaching VDI and ISO..."
VBoxManage storageattach "ArchLinux" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/ArchLinux/ArchLinux.vdi"
VBoxManage storageattach "ArchLinux" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$HOME/Downloads/archlinux.iso"

echo "Done!"

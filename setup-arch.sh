#!/usr/bin/env bash

# Check if the distro is (based on) Arch Linux
isArch="$(command -v pacman > /dev/null 2>&1 ; echo $?)"

if [ "${isArch}" -ne 0 ];
then
     echo "You do not run an Arch-based Linux distrbution ..."
     exit 1
fi

unset isArch

vmware=1
vbox=0
hyperv=0
gnome=1

sudo pacman -Syyu

if [ ${vmware} -eq 1 ]; 
then
    echo -e "Configuring VMware stuffs..."
    sudo pacman -Sy --needed xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools
    sudo systemctl enable --now vmtoolsd.service
    sudo systemctl enable --now vmware-vmblock-fuse.service
fi

if [ ${vbox} -eq 1 ]; 
then
    echo -e "Configuring VirtualBox stuffs..."
    sudo pacman -Sy --needed virtualbox-guest-utils
    sudo systemctl enable --now vboxservice.service
fi

if [ ${hyperv} -eq 1 ]; 
then
    echo -e "Configuring Hyper-V stuffs..."
    sudo pacman -Sy --needed hyperv
    sudo systemctl enable --now hv_fcopy_daemon.service
    sudo systemctl enable --now hv_kvp_daemon.service
    sudo systemctl enable --now hv_vss_daemon.service

fi

echo -e "Installing fonts..."
sudo pacman -Sy --needed noto-fonts noto-fonts-emoji ttf-liberation ttf-dejavu ttf-roboto ttf-ubuntu-font-family ttf-jetbrains-mono-nerd

echo -e "Installing some needed stuffs..."
sudo pacman -Sy --needed pacman-contrib firefox base-devel git wget vulkan-mesa-layers vulkan-swrast

pacman-configure-chaotic-aur

echo -e "Doing some cool stuffs in /etc/pacman.conf ..."
sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

sudo pacman -Syyu
sudo pacman -Fy

echo -e "Installing some more needed stuffs..."
sudo pacman -Sy --needed yay rate-mirrors

configure-bash
source ~/.bashrc

echo -e "Done...Reboot..."

configure-bash()
{
    echo -e "Configuring bash..."
    wget -q -o ~/.aliases https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/arch/.aliases
    bashrcAppend="$(grep ".aliases" ~/.bashrc > /dev/null 2>&1 ; echo $?)"
    if [ "${bashrcAppend}" -ne 0 ]; 
    then
        wget -q -a ~/.bashrc https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/.bashrc
    fi
}

pacman-configure-chaotic-aur()
{
    if [ "$(find /etc/pacman.d/ -name chaotic-mirrorlist)" == "" ];
    then
        echo -e "Configuring Chaotic-AUR - https://aur.chaotic.cx/docs..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    fi

    chaoticAurAppend="$(grep "chaotic-aur" /etc/pacman.conf > /dev/null 2>&1 ; echo $?)"
    if [ "${chaoticAurAppend}" -ne 0 ]; then
        echo "Appending Chaotic-AUR in pacman.conf..."
        sudo echo -e "\r\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
    fi
}


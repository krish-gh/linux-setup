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
chaoticaur=1

sudo pacman -Syyu
setup-vm
tweak-system

echo -e "Installing some needed stuffs..."
sudo pacman -Sy --needed pacman-contrib firefox base-devel nano git wget vulkan-mesa-layers vulkan-swrast starship

if [ ${chaoticaur} -eq 1 ];then
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

improve-font
configure-bash
setup-gtk

if [ ${gnome} -eq 1 ];then
    setup-gnome

mkdir -p ~/.config/environment.d
wget -q -o ~/.config/environment.d/10-defaults.conf https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/.config/environment.d/10-defaults.conf

echo -e "Done...Reboot..."

setup-vm()
{
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
}

tweak-system()
{
    echo -e "Tweaking some system stuffs..."
    sudo mkdir -p /etc/sysctl.d /etc/systemd/journald.conf.d
    wget -q -o 99-sysctl.conf https://raw.githubusercontent.com/krish-gh/linux-setup/main/system/etc/sysctl.d/99-sysctl.conf
    sudo mv -f 99-sysctl.conf /etc/sysctl.d/
    wget -q -o 00-journal-size.conf https://raw.githubusercontent.com/krish-gh/linux-setup/main/system/etc/systemd/journald.conf.d/00-journal-size.conf
    sudo mv -f 00-journal-size.conf /etc/systemd/journald.conf.d/
    sudo journalctl --rotate --vacuum-size=10M
}

improve-font()
{
    echo -e "Installing fonts..."
    sudo pacman -Sy --needed noto-fonts noto-fonts-emoji ttf-liberation ttf-dejavu ttf-roboto ttf-ubuntu-font-family ttf-jetbrains-mono-nerd
    echo -e "Making font look better..."
    mkdir -p ~/.config/fontconfig/conf.d
    wget -q -o ~/.config/fontconfig/fonts.conf https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/.config/fontconfig/fonts.conf
    wget -q -o ~/.config/fontconfig/conf.d/20-no-embedded.conf https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/.config/fontconfig/conf.d/20-no-embedded.conf
    wget -q -o .Xresources https://raw.githubusercontent.com/krish-gh/linux-setup/main/.Xresources
    sudo pacman -Sy --needed xorg-xrdb
    xrdb -merge ~/.Xresources
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
    sudo sed -i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    sudo fc-cache -fv
    fc-cache -fv
}

configure-bash()
{
    echo -e "Configuring bash..."
    wget -q -o ~/.aliases https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/arch/.aliases
    bashrcAppend="$(grep ".aliases" ~/.bashrc > /dev/null 2>&1 ; echo $?)"
    if [ "${bashrcAppend}" -ne 0 ]; 
    then
        wget -q -a ~/.bashrc https://raw.githubusercontent.com/krish-gh/linux-setup/main/home/.bashrc
    fi
    source ~/.bashrc
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

setup-gnome()
{
    echo -e "Configuring gnome stuffs..."
    sudo pacman -Rnsy snapshot gnome-calculator gnome-clocks gnome-connections gnome-contacts gnome-disk-utility baobab simple-scan gnome-maps gnome-music gnome-tour totem gnome-weather epiphany gnome-user-docs yelp
    sudo pacman -Sy --needed gnome-tweaks kvantum-qt5 qt5-wayland qt5ct qt6ct vlc
    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
    yay -Sy --needed extension-manager
    gnome-extensions install AlphabeticalAppGrid@stuarthayhurst
    gnome-extensions install dash-to-dock@micxgx.gmail.com
    gnome-extensions install appindicatorsupport@rgcjonas.gmail.com
}

setup-gtk()
{
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    echo > ~/.gtkrc-2.0
    echo "[Settings]\r\ngtk-application-prefer-dark-theme=1" > ~/.config/gtk-3.0/settings.ini
    echo "[Settings]\r\ngtk-hint-font-metrics=1" > ~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.local/share/gtksourceview-{4,5}/styles
    wget -q -p ~/.local/share/gtksourceview-4/styles https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
    wget -q -p ~/.local/share/gtksourceview-5/styles https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
}


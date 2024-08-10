#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo pacman -Sy"
UPDATE_CMD="sudo pacman -Syu --noconfirm"
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"

REQUIREMENTS="curl wget unzip xorg-xrdb dconf"
SYSTEM_PACKAGES_TO_INSTALL="vulkan-{mesa-layers,swrast,icd-loader} sof-firmware alsa-firmware fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver vulkan-intel"
VMWARE_PACKAGES_TO_INSTALL="xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-utils"
HYPERV_PACKAGES_TO_INSTALL="hyperv"
FONTS_TO_INSTALL="noto-fonts{,-emoji} ttf-{liberation,dejavu,roboto,ubuntu-font-family,jetbrains-mono-nerd}"
TERM_PACKAGES_TO_INSTALL="bash-completion nano-syntax-highlighting starship fastfetch"
APP_PACKAGES_TO_INSTALL="pacman-contrib firefox{,-i18n-en-gb,-i18n-en-us} gnome-keyring seahorse vlc yay rate-mirrors reflector-simple"
DEV_PACKAGES_TO_INSTALL="git base-devel python-pip shfmt diffutils meld github-cli visual-studio-code-bin"
GTK_PACKAGES_TO_INSTALL="gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="kvantum-qt5 qt{5,6}-wayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} python-nautilus python-pipx"
GNOME_EXT_MGR_PKG="extension-manager"
CINNAMON_PACKAGES_TO_INSTALL="x-apps nemo-emblems nemo-fileroller nemo-preview nemo-python xviewer{,-plugins} mint-{themes,y-icons}"
PACKAGES_TO_REMOVE=""

setup_pacman() {
    echo -e "Doing some cool stuffs in /etc/pacman.conf ..."
    sudo sed -i "/^#Color/c\Color\nILoveCandy
        /^#VerbosePkgLists/c\VerbosePkgLists
        /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    # https://aur.chaotic.cx/docs
    if [[ ! -f /etc/pacman.d/chaotic-mirrorlist ]]; then
        echo -e "Configuring Chaotic-AUR..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    fi

    chaoticAurAppend="$(
        grep "chaotic-aur" /etc/pacman.conf >/dev/null 2>&1
        echo $?
    )"
    if [[ "${chaoticAurAppend}" -ne 0 ]]; then
        echo "Appending Chaotic-AUR in pacman.conf..."
        echo -e | sudo tee -a /etc/pacman.conf
        echo -e "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
        echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    fi

    refresh_package_sources

    echo -e "Installing some stuffs..."
    [[ -f /etc/mkinitcpio.conf ]] && install_pkgs "mkinitcpio-firmware"

    pamacvar='aur'
    if command_exists flatpak; then
        pamacvar='flatpak'
    fi
    install_pkgs "pamac-${pamacvar}"

    # Configure pamac
    sudo sed -i "/RemoveUnrequiredDeps/s/^#//g
        /NoUpdateHideIcon/s/^#//g
        /KeepNumPackages/c\KeepNumPackages = 1
        /RefreshPeriod/c\RefreshPeriod = 0" /etc/pamac.conf

    # misc
    flagstocopy=(code electron chromium chrome microsoft-edge-stable)
    for i in "${flagstocopy[@]}"; do
        copy_file ~/.config/"${i}"-flags.conf "${BASE_REPO_LOCATION}"home/.config/"${i}"-flags.conf
    done
}

echo -e "Done arch.sh..."

#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo pacman -Sy"
UPDATE_CMD="sudo pacman -Syu --noconfirm"
INSTALL_CMD="sudo pacman -S --needed --noconfirm"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"
UNINSTALL_ONLY_CMD="sudo pacman -Rns --noconfirm"

REQUIREMENTS="curl wget unzip xorg-xrdb dconf jq crudini"
SYSTEM_PACKAGES_TO_INSTALL="fwupd vulkan-{mesa-layers,swrast,icd-loader} alsa-{firmware,ucm-conf} sof-firmware fprintd power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver vulkan-intel"
VMWARE_PACKAGES_TO_INSTALL="gtkmm gtkmm3 open-vm-tools"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-utils"
HYPERV_PACKAGES_TO_INSTALL="hyperv"
VIRT_PACKAGES_TO_INSTALL="qemu-guest-agent"
FONTS_TO_INSTALL="noto-fonts{,-emoji} ttf-{liberation,dejavu,droid,roboto,ubuntu-font-family,jetbrains-mono-nerd}"
TERM_PACKAGES_TO_INSTALL="bash-completion nano-syntax-highlighting starship fastfetch"
APP_PACKAGES_TO_INSTALL="pacman-contrib firefox{,-i18n-en-gb,-i18n-en-us} gnome-keyring seahorse vlc onboard yay rate-mirrors reflector-simple"
DEV_PACKAGES_TO_INSTALL="git base-devel python-pip shfmt diffutils meld github-cli visual-studio-code-bin"
GTK_PACKAGES_TO_INSTALL="xdg-desktop-portal-gtk gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="qt{5,6}-wayland"
QT_PATCHES_TO_INSTALL="kvantum-qt5 qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} evolution-data-server python-nautilus python-pipx $QT_PATCHES_TO_INSTALL"
GNOME_EXT_MGR_PKG="extension-manager"
KDE_PACKAGES_TO_INSTALL="plasma-meta gwenview kcalc kfind kwrite okular spectacle"
CINNAMON_PACKAGES_TO_INSTALL="x-apps nemo-emblems nemo-fileroller nemo-preview nemo-python xviewer{,-plugins} mint-{themes,y-icons} $QT_PATCHES_TO_INSTALL"
XFCE_PACKAGES_TO_INSTALL="xfce4 xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-screenshooter xfce4-taskmanager light-locker lightdm-slick-greeter lightdm-settings $QT_PATCHES_TO_INSTALL"
XFCE_MENU_LOGO="distributor-logo-archlinux"
PACKAGES_TO_REMOVE=""

setup_arch() {
    if [[ -f /etc/vconsole.conf ]]; then
        if ! grep -q "FONT=" /etc/vconsole.conf; then
            printf 'FONT is not set in vconsole.conf, updating...\n'
            printf 'FONT="eurlatgr"\n' | sudo tee -a /etc/vconsole.conf >/dev/null
        fi
    fi

    printf 'Doing some cool stuff in /etc/pacman.conf...\n'
    sudo sed -i "/^#Color/c\\Color\\nILoveCandy" /etc/pacman.conf
    sudo sed -i "/^#VerbosePkgLists/c\\VerbosePkgLists" /etc/pacman.conf
    sudo sed -i "/^#ParallelDownloads/c\\ParallelDownloads = 5" /etc/pacman.conf
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    # https://aur.chaotic.cx/docs
    if [[ ! -f /etc/pacman.d/chaotic-mirrorlist ]]; then
        printf 'Configuring Chaotic-AUR...\n'
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com 2>/dev/null || printf 'Warning: Failed to receive key\n' >&2
        sudo pacman-key --lsign-key 3056513887B78AEB 2>/dev/null || printf 'Warning: Failed to sign key\n' >&2
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 2>/dev/null || printf 'Warning: Failed to install chaotic-keyring\n' >&2
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' 2>/dev/null || printf 'Warning: Failed to install chaotic-mirrorlist\n' >&2
    fi

    if ! grep -q "chaotic-aur" /etc/pacman.conf; then
        printf 'Appending Chaotic-AUR in pacman.conf...\n'
        printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' | sudo tee -a /etc/pacman.conf >/dev/null
    fi

    refresh_package_sources

    printf 'Installing some packages...\n'
    [[ -f /etc/mkinitcpio.conf ]] && install_pkgs "mkinitcpio-firmware"

    pamacvar='aur'
    if command_exists flatpak; then
        pamacvar='flatpak'
    fi
    install_pkgs "pamac-${pamacvar}"

    # Configure pamac
    sudo sed -i "/RemoveUnrequiredDeps/s/^#//g; /NoUpdateHideIcon/s/^#//g; /KeepNumPackages/c\\KeepNumPackages = 1; /RefreshPeriod/c\\RefreshPeriod = 0" /etc/pamac.conf 2>/dev/null || true

    # misc
    flagstocopy=(code electron chromium chrome microsoft-edge-stable)
    for i in "${flagstocopy[@]}"; do
        copy_file ~/.config/"${i}"-flags.conf "${BASE_REPO_LOCATION}home/.config/${i}-flags.conf" || true
    done
}

setup_arch_cinnamon() {
    setup_cinnamon_theme
}

printf 'Done arch.sh...\n'

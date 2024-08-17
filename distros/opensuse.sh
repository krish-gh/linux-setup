#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo zypper refresh"
UPDATE_CMD="sudo zypper dup --allow-vendor-change -y"
INSTALL_CMD="sudo zypper install -y"
UNINSTALL_CMD="sudo zypper remove --clean-deps -y"

REQUIREMENTS="curl wget unzip xrdb dconf jq"
SYSTEM_PACKAGES_TO_INSTALL="fwupd ibus nss-mdns Mesa-vulkan-{device-select,overlay} alsa-firmware sof-firmware fprintd fprintd-pam power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver"
VMWARE_PACKAGES_TO_INSTALL="xf86-video-vmware xf86-video-qxl open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-tools"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="{liberation,google-noto}-fonts-common google-noto-{emoji,color-emoji}-fonts jetbrains-mono-fonts"
TERM_PACKAGES_TO_INSTALL="bash-completion nano starship fastfetch"
APP_PACKAGES_TO_INSTALL="firefox{,-langpacks} mozilla-openh264 gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="git make automake gcc gcc-c++ python3-pip shfmt diffutils meld gh code"
GTK_PACKAGES_TO_INSTALL="xdg-desktop-portal-gtk gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="qt{5,6}-qtwayland"
QT_PATCHES_TO_INSTALL="kvantum{,-qt5} qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} evolution-data-server nautilus-python pipx $QT_PATCHES_TO_INSTALL"
GNOME_EXT_MGR_PKG=""
KDE_PACKAGES_TO_INSTALL="plasma-workspace{,-x11} gwenview kate kcalc maliit-keyboard okular spectacle"
CINNAMON_PACKAGES_TO_INSTALL="xed xreader xviewer{,-plugins} nemo-emblems nemo-fileroller nemo-preview nemo-python mint-{themes,y-icons} $QT_PATCHES_TO_INSTALL"
PACKAGES_TO_REMOVE=""

setup_fedora() {
    

    refresh_package_sources
}

echo -e "Done opensuse.sh..."

#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo pacman -Syu --noconfirm"
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"

REQUIREMENTS="curl unzip base-devel xorg-xrdb dconf"
SYSTEM_PACKAGES_TO_INSTALL="vulkan-{mesa-layers,swrast,icd-loader} sof-firmware alsa-{firmware,oss,plugins,utils} fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver vulkan-intel"
VMWARE_PACKAGES_TO_INSTALL="xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-utils"
HYPERV_PACKAGES_TO_INSTALL="hyperv"
FONTS_TO_INSTALL="noto-fonts{,-extra,-emoji} ttf-{liberation,dejavu,roboto,ubuntu-font-family,jetbrains-mono-nerd}"
TERM_PACKAGES_TO_INSTALL="diffutils bash-completion nano-syntax-highlighting starship fastfetch xclip wl-clipboard"
APP_PACKAGES_TO_INSTALL="pacman-contrib firefox{,-i18n-en-gb,-i18n-en-us} gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="git github-cli shfmt meld"
GTK_PACKAGES_TO_INSTALL="gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="kvantum-qt5 qt{5,6}-wayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} python-nautilus python-pipx"
CINNAMON_PACKAGES_TO_INSTALL="x-apps nemo-emblems nemo-fileroller nemo-preview nemo-python"
PACKAGES_TO_REMOVE="baobab celluloid epiphany gedit gthumb mpv galculator rhythmbox simple-scan snapshot system-config-printer thunderbird totem vim neofetch gnome-{boxes,calculator,calendar,characters,clocks,connections,contacts,disk-utility,font-viewer,maps,music,nettool,power-manager,screenshot,tour,weather,user-docs} yelp"

echo -e "Done arch.sh..."
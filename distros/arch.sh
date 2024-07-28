#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo pacman -Syu --noconfirm"
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"

REQUIREMENTS="curl base-devel xorg-xrdb"
SYSTEM_PACKAGES_TO_INSTALL="vulkan-{mesa-layers,swrast,icd-loader} sof-firmware alsa-{firmware,oss,plugins,utils} fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver vulkan-intel"
VMWARE_PACKAGES_TO_INSTALL="xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-utils"
HYPERV_PACKAGES_TO_INSTALL="hyperv"
FONTS_TO_INSTALL="noto-fonts{,-extra,-emoji} ttf-{liberation,dejavu,roboto,ubuntu-font-family,nerd-fonts-symbols-mono,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="diffutils bash-completion nano-syntax-highlighting starship fastfetch xclip wl-clipboard neovim xterm"
APP_PACKAGES_TO_INSTALL="pacman-contrib firefox{,-i18n-en-gb,-i18n-en-us} gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="git github-cli shfmt meld"
GTK_PACKAGES_TO_INSTALL="kvantum-qt5 qt{5,6}-wayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{themes-extra,menus,tweaks,shell-extensions,console,text-editor} python-nautilus python-pipx"
PACKAGES_TO_REMOVE="snapshot baobab simple-scan epiphany totem gedit vim neofetch gnome-{calculator,calendar,characters,clocks,connections,contacts,font-viewer,maps,music,nettool,power-manager,screenshot,tour,weather,user-docs,terminal} yelp"

echo -e "Done arch.sh..."
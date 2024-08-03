#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo apt-get update && sudo apt-get full-upgrade -y"
INSTALL_CMD="sudo apt-get install -y"
UNINSTALL_CMD="sudo apt-get purge --ignore-missing --auto-remove -y"

REQUIREMENTS="curl unzip build-essential dconf-cli"
SYSTEM_PACKAGES_TO_INSTALL="mesa-vulkan-drivers firmware-sof-signed alsa-{firmware-loaders,oss,utils} fprintd libpam-fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-va-driver-non-free va-driver-all"
VMWARE_PACKAGES_TO_INSTALL="xserver-xorg-video-vmware open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-x11"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="fonts-{recommended,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="diffutils bash-completion nano neofetch xclip wl-clipboard"
APP_PACKAGES_TO_INSTALL="firefox{,-locale-en} gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="git shfmt meld"
GTK_PACKAGES_TO_INSTALL="gnome-themes-extra{,-data}"
QT_PACKAGES_TO_INSTALL="qt5-style-kvantum qt6-wayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,console,text-editor} python3-nautilus pipx"
CINNAMON_PACKAGES_TO_INSTALL=""
PACKAGES_TO_REMOVE="baobab caribou drawing epiphany gedit gthumb *libreoffice* mpv *rhythmbox* simple-scan snapshot totem vim gnome-{boxes,calculator,calendar,characters,clocks,connections,contacts,disk-utility,font-viewer,games,maps,music,nettool,power-manager,screenshot,tour,weather}"

echo -e "Done debian.sh..."
#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo apt update && sudo apt full-upgrade -y"
INSTALL_CMD="sudo apt install -y"
UNINSTALL_CMD="sudo apt purge --ignore-missing --auto-remove -y"

REQUIREMENTS="curl build-essential"
SYSTEM_PACKAGES_TO_INSTALL="mesa-vulkan-drivers firmware-sof-signed alsa-{firmware-loaders,oss,utils} fprintd libpam-fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-va-driver-non-free va-driver-all"
VMWARE_PACKAGES_TO_INSTALL="xserver-xorg-video-vmware open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-x11"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="fonts-noto-{core,color-emoji,extra,mono,ui-core,ui-extra} fonts-{liberation,dejavu,roboto,ubuntu,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="diffutils bash-completion nano fastfetch xclip wl-clipboard neovim xterm"

echo -e "Done debian.sh..."
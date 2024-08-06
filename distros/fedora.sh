#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo dnf check-update --refresh"
UPDATE_CMD="sudo dnf update -y --refresh"
INSTALL_CMD="sudo dnf install -y"
UNINSTALL_CMD="sudo dnf autoremove -y"

REQUIREMENTS="curl wget2-wget unzip xrdb dconf"
SYSTEM_PACKAGES_TO_INSTALL="mesa-vulkan-drivers vulkan-loader alsa-{firmware,sof-firmware,plugins-oss,utils} fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver"
VMWARE_PACKAGES_TO_INSTALL="xorg-x11-drv-vmware open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-additions"
HYPERV_PACKAGES_TO_INSTALL="hyperv-daemons hyperv-tools"
FONTS_TO_INSTALL="{liberation,google-noto}-fonts-common google-noto-{emoji,color-emoji}-fonts jetbrains-mono-fonts"
TERM_PACKAGES_TO_INSTALL="bash-completion nano starship fastfetch"
APP_PACKAGES_TO_INSTALL="firefox{,-langpacks} mozilla-openh264 gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="git make automake gcc gcc-c++ shfmt diffutils meld gh code"
GTK_PACKAGES_TO_INSTALL="gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="kvantum kvantum-qt5 qt{5,6}-qtwayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} nautilus-python pipx"
GNOME_EXT_MGR_PKG=""
CINNAMON_PACKAGES_TO_INSTALL=""
PACKAGES_TO_REMOVE="baobab caribou celluloid cheese drawing epiphany evolution galculator gedit gthumb *gucharmap* *libreoffice* mpv *rhythmbox* shotwell simple-scan snapshot *thunderbird* totem *transmission* vim* gnome-{boxes,calculator,calendar,characters,clocks,connections,contacts,disk-utility,font-viewer,games,maps,music,nettool,power-manager,screenshot,sound-recorder,tour,weather,user-docs} yelp"

setup_dnf() {
    echo -e "Setting up RPM Fusion..."
    # https://rpmfusion.org/Configuration
    # shellcheck disable=SC2046
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf config-manager --enable fedora-cisco-openh264
    sudo dnf update -y @core
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    #sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
    #sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
    #sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

    echo -e "Disabling some not needed repos..."
    sudo dnf config-manager --disable *PyCharm*
    sudo dnf config-manager --disable *nvidia*
    sudo dnf config-manager --disable *steam*

    # microsoft
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/vscode
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge

    refresh_package_sources
}

echo -e "Done fedora.sh..."

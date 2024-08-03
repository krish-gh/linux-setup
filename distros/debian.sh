#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo apt-get update && sudo apt-get full-upgrade -y"
INSTALL_CMD="sudo apt-get install -y"
UNINSTALL_CMD="sudo apt-get purge --ignore-missing --auto-remove -y"

REQUIREMENTS="curl git unzip dconf-cli"
SYSTEM_PACKAGES_TO_INSTALL="mesa-vulkan-drivers firmware-sof-signed alsa-{firmware-loaders,oss,utils} fprintd libpam-fprintd"
INTEL_PACKAGES_TO_INSTALL="intel-media-va-driver-non-free va-driver-all"
VMWARE_PACKAGES_TO_INSTALL="xserver-xorg-video-vmware open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-x11"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="fonts-{recommended,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="bash-completion nano fastfetch"
APP_PACKAGES_TO_INSTALL="firefox{,-locale-en} gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="build-essential shfmt diffutils meld code gh"
GTK_PACKAGES_TO_INSTALL="gnome-themes-extra{,-data}"
QT_PACKAGES_TO_INSTALL="qt{5,6}-style-kvantum{,-themes} qt6-wayland qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} python3-nautilus pipx"
GNOME_EXT_MGR_PKG="gnome-shell-extension-manager"
CINNAMON_PACKAGES_TO_INSTALL=""
PACKAGES_TO_REMOVE="baobab caribou drawing epiphany gedit gthumb *libreoffice* mpv *rhythmbox* simple-scan snapshot totem vim gnome-{boxes,calculator,calendar,characters,clocks,connections,contacts,disk-utility,font-viewer,games,maps,music,nettool,power-manager,screenshot,tour,weather}"

setup_apt() {
    echo -e "Setting up apt..."
    install_pkgs "nala wget gpg apt-transport-https"
    sudo mkdir -p -m 755 /etc/apt/keyrings

    # vscode
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
        rm -f packages.microsoft.gpg .wget-hsts
    fi

    # github
    if [[ ! -f /etc/apt/sources.list.d/github-cli.list ]]; then
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        rm -f .wget-hsts
    fi

    # add some ppa if ubuntu based
    if [[ $DIST_ID == *ubuntu* || $ID_LIKE == *ubuntu* ]]; then
        # for qt6-style-kvantum
        sudo add-apt-repository ppa:papirus/papirus -y
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    fi

    refresh_package_sources
}

echo -e "Done debian.sh..."
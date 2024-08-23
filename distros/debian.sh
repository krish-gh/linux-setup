#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo apt-get update"
UPDATE_CMD="sudo apt-get update && sudo apt-get full-upgrade -y"
INSTALL_CMD="sudo apt-get install -y"
UNINSTALL_CMD="sudo apt-get purge --ignore-missing --auto-remove -y"
UNINSTALL_ONLY_CMD="sudo apt-get purge --ignore-missing -y"

REQUIREMENTS="curl wget unzip dconf-cli jq"
SYSTEM_PACKAGES_TO_INSTALL="fwupd ibus libnss-mdns mesa-vulkan-drivers firmware-sof-signed alsa-firmware-loaders pipewire-libcamera fprintd libpam-fprintd power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-va-driver-non-free va-driver-all"
VMWARE_PACKAGES_TO_INSTALL="xserver-xorg-video-vmware xserver-xorg-video-qxl open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-x11"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="fonts-{recommended,noto-core,noto-ui-core,noto-color-emoji,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="bash-completion nano starship fastfetch"
APP_PACKAGES_TO_INSTALL="firefox{,-locale-en*,-l10n-en*} w{american,british} gnome-keyring seahorse vlc onboard"
DEV_PACKAGES_TO_INSTALL="git build-essential python3-pip shfmt diffutils meld gh code"
GTK_PACKAGES_TO_INSTALL="xdg-desktop-portal-gtk gnome-themes-extra{,-data}"
QT_PACKAGES_TO_INSTALL="qtwayland5 qt6-wayland"
QT_PATCHES_TO_INSTALL="qt{5,6}-style-kvantum{,-themes} qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} evolution-data-server python3-nautilus pipx $QT_PATCHES_TO_INSTALL"
GNOME_EXT_MGR_PKG="gnome-shell-extension-manager"
KDE_PACKAGES_TO_INSTALL="kde-plasma-desktop gwenview kcalc kfind kwrite okular kde-spectacle"
CINNAMON_PACKAGES_TO_INSTALL="xed xreader xviewer{,-plugins} mint-{themes,y-icons} $QT_PATCHES_TO_INSTALL"
XFCE_PACKAGES_TO_INSTALL="xfce4 xfce4-whiskermenu-plugin $QT_PATCHES_TO_INSTALL"
PACKAGES_TO_REMOVE=""

setup_debian() {
    echo -e "Setting up apt..."
    install_pkgs "software-properties-common python3-launchpadlib nala gpg apt-transport-https"

    sudo apt-add-repository contrib -y
    sudo apt-add-repository non-free -y
    sudo apt-add-repository non-free-firmware -y
    sudo apt-add-repository restricted -y

    sudo mkdir -p -m 755 /etc/apt/keyrings

    # microsoft
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null
    rm -f packages.microsoft.gpg

    # google
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google.gpg >/dev/null
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

    # github
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    rm -f .wget-hsts

    # add some ppa if ubuntu based
    if [[ $DIST_ID == *ubuntu* || $ID_LIKE == *ubuntu* ]]; then
        sudo add-apt-repository ppa:papirus/papirus -y # for qt6-style-kvantum
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    fi

    refresh_package_sources

    # synaptic
    sudo mkdir -p /root/.synaptic/
    copy_file "$TEMP_DIR"/synaptic.conf "${BASE_REPO_LOCATION}"system/root/.synaptic/synaptic.conf
    sudo mv -f "$TEMP_DIR"/synaptic.conf /root/.synaptic/
}

setup_debian_cinnamon() {
    setup_cinnamon_theme
}

echo -e "Done debian.sh..."

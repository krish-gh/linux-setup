#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo zypper --gpg-auto-import-keys refresh"
UPDATE_CMD="sudo zypper dup --allow-vendor-change -y"
INSTALL_CMD="sudo zypper install -y"
UNINSTALL_CMD="sudo zypper remove --clean-deps -y"
UNINSTALL_ONLY_CMD="sudo zypper remove -y"

FLATPAK_INSTALL_CMD="sudo flatpak install --assumeyes flathub" #override from DISTRO_TYPE specific script

REQUIREMENTS="curl wget unzip xrdb dconf jq"
SYSTEM_PACKAGES_TO_INSTALL="fwupd ibus nss-mdns Mesa-vulkan-{device-select,overlay} alsa-firmware sof-firmware fprintd fprintd-pam power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver"
VMWARE_PACKAGES_TO_INSTALL="xf86-video-vmware xf86-video-qxl open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-tools"
HYPERV_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL="{liberation,dejavu,ubuntu}-fonts google-noto-{coloremoji,sans,serif,sans-mono}-fonts google-roboto-fonts jetbrains-mono-fonts"
TERM_PACKAGES_TO_INSTALL="bash-completion nano starship fastfetch"
APP_PACKAGES_TO_INSTALL="MozillaFirefox{,-translations-common} mozilla-openh264 gnome-keyring seahorse vlc onboard"
DEV_PACKAGES_TO_INSTALL="git patterns-devel-base-devel_basis python3-pip shfmt diffutils meld gh"
GTK_PACKAGES_TO_INSTALL="xdg-desktop-portal-gtk gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="qt6-wayland"
QT_PATCHES_TO_INSTALL="kvantum-{manager,qt5,qt6,themes} qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} evolution-data-server python3-nautilus python3-pipx $QT_PATCHES_TO_INSTALL"
GNOME_EXT_MGR_PKG="extension-manager"
KDE_PACKAGES_TO_INSTALL="patterns-kde-kde_plasma gwenview kcalc kfind kwrite okular spectacle"
CINNAMON_PACKAGES_TO_INSTALL="xed xreader xviewer metatheme-mint-common mint-y-icon-theme $QT_PATCHES_TO_INSTALL"
XFCE_PACKAGES_TO_INSTALL="$QT_PATCHES_TO_INSTALL"
PACKAGES_TO_REMOVE="icewm*"

setup_opensuse() {
    #sudo zypper al totem
    echo -e "Setting up repo and packman..."
    # shellcheck disable=SC2154
    if [[ $releasever == '' ]]; then
        install_pkgs openSUSE-repos-Tumbleweed
        sudo zypper ar -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
    else
        install_pkgs openSUSE-repos-Leap
        sudo zypper ar -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_$releasever/' packman
    fi
    refresh_package_sources
    sudo zypper dup --from packman --allow-vendor-change -y

    echo -e "Installing some stuffs..."
    install_pkgs "opi"
    opi codecs -n
    opi vscode -n
    refresh_package_sources

    echo -e "Installing zypperoni for faster zypper download..."
    curl https://raw.githubusercontent.com/pavinjosdev/zypperoni/main/zypperoni | sudo tee /usr/bin/zypperoni >/dev/null
    sudo chmod 755 /usr/bin/zypperoni
}

echo -e "Done opensuse.sh..."

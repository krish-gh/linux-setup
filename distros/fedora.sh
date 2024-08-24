#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo dnf check-update --refresh"
UPDATE_CMD="sudo dnf update --refresh -y"
INSTALL_CMD="sudo dnf install -y"
UNINSTALL_CMD="sudo dnf autoremove -y"
UNINSTALL_ONLY_CMD="sudo dnf remove -y"

REQUIREMENTS="curl wget2-wget unzip xrdb dconf jq"
SYSTEM_PACKAGES_TO_INSTALL="fwupd-efi ibus nss-mdns mesa-vulkan-drivers vulkan-loader alsa-{firmware,sof-firmware} pipewire-plugin-libcamera fprintd fprintd-pam power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver"
VMWARE_PACKAGES_TO_INSTALL="xorg-x11-drv-vmware xorg-x11-drv-qxl open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-additions"
HYPERV_PACKAGES_TO_INSTALL="hyperv-{daemons,tools}"
FONTS_TO_INSTALL="{liberation,google-noto}-fonts-common google-noto-{emoji,color-emoji}-fonts jetbrains-mono-fonts"
TERM_PACKAGES_TO_INSTALL="bash-completion nano starship fastfetch"
APP_PACKAGES_TO_INSTALL="firefox{,-langpacks} mozilla-openh264 gnome-keyring seahorse vlc onboard"
DEV_PACKAGES_TO_INSTALL="git make automake gcc gcc-c++ python3-pip shfmt diffutils meld gh code"
GTK_PACKAGES_TO_INSTALL="xdg-desktop-portal-gtk gnome-themes-extra"
QT_PACKAGES_TO_INSTALL="qt{5,6}-qtwayland"
QT_PATCHES_TO_INSTALL="kvantum{,-qt5} qt{5,6}ct"
GNOME_PACKAGES_TO_INSTALL="gnome-{menus,tweaks,terminal,text-editor} evolution-data-server nautilus-python pipx $QT_PATCHES_TO_INSTALL"
GNOME_EXT_MGR_PKG=""
KDE_PACKAGES_TO_INSTALL="plasma-workspace{,-x11} gwenview kate kcalc kfind kwrite okular spectacle"
CINNAMON_PACKAGES_TO_INSTALL="xed xreader xviewer{,-plugins} nemo-emblems nemo-fileroller nemo-preview nemo-python mint-{themes,y-icons} $QT_PATCHES_TO_INSTALL"
XFCE_PACKAGES_TO_INSTALL="$QT_PATCHES_TO_INSTALL"
PACKAGES_TO_REMOVE=""

setup_fedora() {
    dnfConfigAppend="$(
        grep "~custom-setup~" /etc/dnf/dnf.conf >/dev/null 2>&1
        echo $?
    )"
    if [[ "${dnfConfigAppend}" -ne 0 ]]; then
        echo "Updating dnf.conf..."
        echo -e "# ~custom-setup~" | sudo tee -a /etc/dnf/dnf.conf
        echo -e "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
    fi

    install_pkgs "fedora-workstation-repositories"
    echo -e "Setting up RPM Fusion..."
    # https://rpmfusion.org/Configuration
    # shellcheck disable=SC2046
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf config-manager --enable fedora-cisco-openh264
    sudo dnf update -y @core
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    #sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
    #sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
    #sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing

    echo -e "Disabling some not needed repos..."
    sudo dnf config-manager --disable *PyCharm* *nvidia* *steam*

    echo -e "Adding some needed repos..."
    # google
    sudo dnf config-manager --enable google-chrome
    # microsoft
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/vscode
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
    sudo sed -i "/name=/c\name=microsoft-vscode" /etc/yum.repos.d/packages.microsoft.com_yumrepos_vscode.repo
    sudo sed -i "/name=/c\name=microsoft-edge" /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo

    #install_pkgs dnfdragora-gui

    # feddy https://github.com/rpmfusion-infra/fedy
    #sudo dnf copr enable -y kwizart/fedy
    #install_pkgs fedy

    refresh_package_sources
}

setup_fedora_cinnamon() {
    setup_cinnamon_theme
}

echo -e "Done fedora.sh..."

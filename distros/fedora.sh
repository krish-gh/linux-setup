#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo dnf check-update --refresh"
UPDATE_CMD="sudo dnf update --refresh -y"
INSTALL_CMD="sudo dnf install -y"
UNINSTALL_CMD="sudo dnf autoremove -y"
UNINSTALL_ONLY_CMD="sudo dnf remove -y"

FLATPAK_INSTALL_CMD="flatpak install --user --assumeyes flathub"

REQUIREMENTS="curl wget2-wget unzip xrdb dconf jq crudini"
SYSTEM_PACKAGES_TO_INSTALL="fwupd-efi fuse mesa-vulkan-drivers vulkan-loader alsa-{firmware,ucm,sof-firmware} fprintd fprintd-pam power-profiles-daemon"
INTEL_PACKAGES_TO_INSTALL="intel-media-driver"
VMWARE_PACKAGES_TO_INSTALL="open-vm-tools-desktop"
VBOX_PACKAGES_TO_INSTALL="virtualbox-guest-additions"
HYPERV_PACKAGES_TO_INSTALL="hyperv-{daemons,tools}"
VIRT_PACKAGES_TO_INSTALL="qemu-guest-agent"
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
XFCE_PACKAGES_TO_INSTALL="xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-screenshooter xfce4-taskmanager light-locker slick-greeter $QT_PATCHES_TO_INSTALL"
XFCE_MENU_LOGO="distributor-logo-fedora"
PACKAGES_TO_REMOVE=""

setup_fedora() {
    printf 'Updating dnf.conf...\n'
    sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main max_parallel_downloads 10
    sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main fastestmirror True
    sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main clean_requirements_on_remove True
    sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main skip_if_unavailable True

    install_pkgs "fedora-workstation-repositories"
    printf 'Setting up RPM Fusion...\n'
    sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    sudo dnf config-manager --enable fedora-cisco-openh264
    sudo dnf update -y @core
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    #sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
    #sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
    #sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing

    printf 'Disabling some not needed repos...\n'
    sudo dnf config-manager --disable *PyCharm* *nvidia* *steam*

    printf 'Adding some needed repos...\n'
    # google
    sudo dnf config-manager --enable google-chrome
    # microsoft
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/vscode
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
    sudo sed -i "/name=/c\name=microsoft-vscode" /etc/yum.repos.d/packages.microsoft.com_yumrepos_vscode.repo
    sudo sed -i "/name=/c\name=microsoft-edge" /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo

    command_exists flatpak && flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
        sudo flatpak remote-modify --disable fedora

    #install_pkgs dnfdragora-gui

    # feddy https://github.com/rpmfusion-infra/fedy
    #sudo dnf copr enable -y kwizart/fedy
    #install_pkgs fedy

    refresh_package_sources
}

setup_fedora_cinnamon() {
    setup_cinnamon_theme
}

setup_fedora_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme-dark"
    setup_xfce_theme
    set_xfce_wallpaper "/usr/share/backgrounds/default-dark.png"
    setup_xfce_panel
}

printf 'Done fedora.sh...\n'

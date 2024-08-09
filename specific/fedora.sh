#!/bin/bash

setup_fedora() {
    uninstall_pkgs "*abrt* mediawriter *pidgin* xawtv* xfburn"
    #if [[ $SYSTEM_TO_SETUP == vmware ]]; then
    #    echo -e "Making sound work for vmware"
    #    sudo dnf swap -y --allowerasing pipewire-pulseaudio pulseaudio
    #    sudo dnf swap -y wireplumber pipewire-media-session
    #fi
    command_exists flatpak && flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
        && sudo flatpak remote-modify --disable fedora
}

echo -e "Done fedora.sh..."

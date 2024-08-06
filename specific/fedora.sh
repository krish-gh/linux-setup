#!/bin/bash

setup_fedora() {
    uninstall_pkgs "*abrt* mediawriter"
    #if [[ $SYSTEM_TO_SETUP == vmware ]]; then
    #    echo -e "Making sound work for vmware"
    #    sudo dnf swap -y --allowerasing pipewire-pulseaudio pulseaudio
    #    sudo dnf swap -y wireplumber pipewire-media-session
    #fi
}

echo -e "Done fedora.sh..."

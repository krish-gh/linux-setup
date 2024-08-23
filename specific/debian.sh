#!/bin/bash

setup_specific_debian_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    setup_xfce_theme
    setup_xfce_panel
}

echo -e "Done debian.sh..."

#!/bin/bash

setup_specific_arch_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    setup_xfce_theme
    set_xfce_wallpaper "/usr/share/backgrounds/xfce/Aquarius.svg"
    setup_xfce_panel
}

echo -e "Done arch.sh..."

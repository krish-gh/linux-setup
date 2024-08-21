#!/bin/bash

setup_specific_arch_xfce() {
    setup_xfce_panel
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    xfconf-query -c xsettings -v -n -p /Net/ThemeName -t string -s Materia-dark
    xfconf-query -c xsettings -v -n -p /Net/IconThemeName -t string -s Papirus-Dark
    xfconf-query -c xfwm4 -v -n -p /general/theme -t string -s Materia-dark
}

echo -e "Done arch.sh..."

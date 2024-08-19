#!/bin/bash

setup_specific_arch_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    xfconf-query -c xsettings -p /Net/ThemeName -s Materia-dark
    xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus-Dark
    xfconf-query -c xfwm4 -p /general/theme -s Materia-dark
}

echo -e "Done arch.sh..."

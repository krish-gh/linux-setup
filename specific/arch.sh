#!/bin/bash

setup_specific_arch_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    xfconf-query -c xsettings -v --create -p /Net/ThemeName -t string -s Materia-dark
    xfconf-query -c xsettings -v --create -p /Net/IconThemeName -t string -s Papirus-Dark
    xfconf-query -c xfwm4 -v --create -p /general/theme -t string -s Materia-dark
}

echo -e "Done arch.sh..."

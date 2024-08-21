#!/bin/bash

setup_specific_arch_xfce() {
    install_pkgs "materia-gtk-theme papirus-icon-theme"
    gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    xfconf-query -c xsettings -v -n -p /Net/ThemeName -t string -s Materia-dark
    xfconf-query -c xsettings -v -n -p /Net/IconThemeName -t string -s Papirus-Dark
    xfconf-query -c xfwm4 -v -n -p /general/theme -t string -s Default-hdpi
    set_wallpaper "/usr/share/backgrounds/xfce/Aquarius.svg"
    setup_xfce_panel
}

echo -e "Done arch.sh..."

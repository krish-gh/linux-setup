#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=xed.desktop

setup_specific_linuxmint() {
    sudo sed -i "s/http:\/\/packages.linuxmint.com/https:\/\/fastly.linuxmint.io/g" /etc/apt/sources.list.d/official-package-repositories.list
    refresh_package_sources
    # just ensuring this meta package was not uninstalled, it will wait for confirmation if it was
    sudo apt-get install mint-meta-"$DESKTOP" 
    install_pkgs mint-meta-core mint-meta-codecs
    copy_file "$TEMP_DIR"/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / <"$TEMP_DIR"/linuxmint.dconf
    rm -f "$TEMP_DIR"/linuxmint.dconf
}

setup_specific_linuxmint_xfce() {
    gsettings set org.gnome.desktop.interface gtk-theme Mint-Y-Dark-Aqua
    gsettings set org.gnome.desktop.interface icon-theme Mint-Y-Aqua
    xfconf-query -c xsettings -v -n -p /Net/ThemeName -t string -s Mint-Y-Dark-Aqua
    xfconf-query -c xsettings -v -n -p /Net/IconThemeName -t string -s Mint-Y-Aqua
    xfconf-query -c xfwm4 -v -n -p /general/theme -t string -s Mint-Y-Dark-Aqua
}

echo -e "Done linuxmint.sh..."

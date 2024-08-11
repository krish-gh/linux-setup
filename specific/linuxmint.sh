#!/bin/bash

setup_linuxmint() {
    sudo sed -i "s/http:\/\/packages.linuxmint.com/https:\/\/fastly.linuxmint.io/g" /etc/apt/sources.list.d/official-package-repositories.list
    refresh_package_sources
    # just ensuring this meta package was not uninstalled, it will wait for confirmation if it was
    sudo apt-get install mint-meta-"$DESKTOP" 
    install_pkgs mint-meta-codecs
    copy_file "$TEMP_DIR"/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / <"$TEMP_DIR"/linuxmint.dconf
    rm -f "$TEMP_DIR"/linuxmint.dconf
}

echo -e "Done linuxmint.sh..."

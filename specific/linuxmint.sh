#!/bin/bash

setup_linuxmint() {
    sudo sed -i "s/http:\/\/packages.linuxmint.com/https:\/\/fastly.linuxmint.io/g" /etc/apt/sources.list.d/official-package-repositories.list
    refresh_package_sources
    uninstall_pkgs "hypnotix mintchat pix* sticky thingy *timeshift* warpinator webapp-manager"
    sudo apt-get install mint-meta-"$DESKTOP" # just ensuring this meta package was not uninstalled, it will wait for confirmation if it was
    install_pkgs mint-meta-codecs
    copy_file /tmp/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / </tmp/linuxmint.dconf
    rm -f /tmp/linuxmint.dconf
}

echo -e "Done linuxmint.sh..."

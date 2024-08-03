#!/bin/bash

setup_linuxmint() {
    uninstall_pkgs "*hexchat* hypnotix mintchat pix *timeshift* warpinator webapp-manager"
    sudo apt-get update
    install_pkgs "mint-meta-codecs"
    copy_file /tmp/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / </tmp/linuxmint.dconf
    rm -f /tmp/linuxmint.dconf

    echo -e "Done linuxmint..."
}

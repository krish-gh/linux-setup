#!/bin/bash

setup_linuxmint() {
    # shellcheck disable=SC2086
    uninstall_pkgs "*hexchat* hypnotix mintchat *thunderbird* *timeshift* warpinator webapp-manager"
    sudo apt-get update
    install_pkgs "mint-meta-codecs"
    copy_file /tmp/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / </tmp/linuxmint.dconf
    rm -f /tmp/linuxmint.dconf

    echo -e "Done linuxmint..."
}

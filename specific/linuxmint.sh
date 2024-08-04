#!/bin/bash

setup_linuxmint() {
    uninstall_pkgs "*hexchat* hypnotix mintchat pix* *redshift* sticky thingy *timeshift* warpinator webapp-manager"
    install_pkgs "mint-meta-codecs mint-meta-$DESKTOP"
    copy_file /tmp/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / </tmp/linuxmint.dconf
    rm -f /tmp/linuxmint.dconf
    echo -e "Done linuxmint..."
}

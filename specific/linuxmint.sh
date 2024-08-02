#!/bin/bash

setup_linuxmint() {
    # shellcheck disable=SC2086
    uninstall_pkgs "celluloid hypnotix mintchat *thunderbird* *timeshift* warpinator webapp-manager"
    copy_file /tmp/linuxmint.dconf "${BASE_REPO_LOCATION}"specific/linuxmint.dconf
    dconf load / </tmp/linuxmint.dconf
    rm -f /tmp/linuxmint.dconf

    echo -e "Done linuxmint..."
}

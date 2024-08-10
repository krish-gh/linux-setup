#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.kde.kwrite.desktop

setup_kde() {
    echo -e "Configuring kde stuffs..."
    install_pkgs "$KDE_PACKAGES_TO_INSTALL"
}

echo -e "Done gnome.sh..."

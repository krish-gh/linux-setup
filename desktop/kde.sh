#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.kde.kwrite.desktop

setup_kde() {
    echo -e "Configuring kde stuffs..."
    install_pkgs "$KDE_PACKAGES_TO_INSTALL"

    [[ -f ~/.config/environment.d/10-defaults.conf ]] && sed '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.config/environment.d/10-defaults.conf
    [[ -f ~/.profile ]] && sed '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.profile
    [[ -f ~/.xprofile ]] && sed '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.xprofile
    [[ -f ~/.config/systemd/user/service.d/env.conf ]] && sed '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.config/systemd/user/service.d/env.conf
}

echo -e "Done gnome.sh..."

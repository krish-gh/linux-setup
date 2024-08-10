#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.kde.kwrite.desktop

setup_kde() {
    echo -e "Configuring kde stuffs..."
    install_pkgs "$KDE_PACKAGES_TO_INSTALL"

    # No need for qt theme in kde environment
    [[ -f ~/.config/environment.d/10-defaults.conf ]] && sed -i '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.config/environment.d/10-defaults.conf
    [[ -f ~/.profile ]] && sed -i '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.profile
    [[ -f ~/.xprofile ]] && sed -i '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.xprofile
    [[ -f ~/.config/systemd/user/service.d/env.conf ]] && sed -i '/QT_QPA_PLATFORMTHEME/s/^/#/' ~/.config/systemd/user/service.d/env.conf

    # configs
    # konsole
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key ColorScheme catppuccin-mocha
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key Font "JetBrainsMono Nerd Font,12"
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key UseFontLineChararacters true
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key Name custom
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key TerminalColumns 120
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key TerminalRows 36    
    kwriteconfig6 --file ~/.config/konsolerc --group "Desktop Entry" --key DefaultProfile custom.profile
    kwriteconfig6 --file ~/.config/konsolerc --group KonsoleWindow --key RememberWindowSize false
    kwriteconfig6 --file ~/.config/konsolerc --group KonsoleWindow --key UseSingleInstance true

}

echo -e "Done gnome.sh..."

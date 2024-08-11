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
    lookandfeeltool -a org.kde.breezedark.desktop
    kwriteconfig6 --file ~/.config/kdeglobals --group KScreen --key ScaleFactor 1.3

    # konsole
    copy_file ~/.local/share/konsole/catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/main/themes/catppuccin-mocha.colorscheme
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key ColorScheme catppuccin-mocha
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key Font "JetBrainsMono Nerd Font,12"
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group Appearance --key UseFontLineChararacters true
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key Name custom
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key TerminalColumns 120
    kwriteconfig6 --file ~/.local/share/konsole/custom.profile --group General --key TerminalRows 36    
    kwriteconfig6 --file ~/.config/konsolerc --group "Desktop Entry" --key DefaultProfile custom.profile
    kwriteconfig6 --file ~/.config/konsolerc --group KonsoleWindow --key RememberWindowSize false
    kwriteconfig6 --file ~/.config/konsolerc --group KonsoleWindow --key UseSingleInstance true

    # kate
    kwriteconfig6 --file ~/.config/katerc --group General --key "Close After Last" true
    kwriteconfig6 --file ~/.config/katerc --group General --key "Restore Window Configuration" false
    kwriteconfig6 --file ~/.config/katerc --group General --key "Save Meta Infos" false
    kwriteconfig6 --file ~/.config/katerc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    kwriteconfig6 --file ~/.config/katerc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"

    # kwrite
    kwriteconfig6 --file ~/.config/kwriterc --group General --key "Close After Last" true
    kwriteconfig6 --file ~/.config/kwriterc --group General --key "Restore Window Configuration" false
    kwriteconfig6 --file ~/.config/kwriterc --group General --key "Save Meta Infos" false
    kwriteconfig6 --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    kwriteconfig6 --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"
    

}

echo -e "Done gnome.sh..."

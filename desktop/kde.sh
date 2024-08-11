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

    KWRITECONFIG_CMD=kwriteconfig6
    ! command_exists kwriteconfig6 && KWRITECONFIG_CMD=kwriteconfig5

    # configs
    lookandfeeltool -a org.kde.breezedark.desktop
    KWRITECONFIG_CMD --file ~/.config/kdeglobals --group KScreen --key ScaleFactor 1.3
    KWRITECONFIG_CMD --file ~/.config/kwinrc --group Xwayland --key Scale 1.3
    KWRITECONFIG_CMD --file ~/.config/plasmashellrc --group PlasmaViews --group "Panel 2" --group Defaults --key thickness 30
    KWRITECONFIG_CMD --file ~/.config/krunnerrc --group Plugins --key baloosearchEnabled false
    rm -f ~/.local/share/baloo/index

    # konsole
    copy_file ~/.local/share/konsole/catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/main/themes/catppuccin-mocha.colorscheme
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group Appearance --key ColorScheme catppuccin-mocha
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group Appearance --key Font "JetBrainsMono Nerd Font,12"
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group Appearance --key UseFontLineChararacters true
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group General --key Name custom
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group General --key TerminalColumns 120
    KWRITECONFIG_CMD --file ~/.local/share/konsole/custom.profile --group General --key TerminalRows 36    
    KWRITECONFIG_CMD --file ~/.config/konsolerc --group "Desktop Entry" --key DefaultProfile custom.profile
    KWRITECONFIG_CMD --file ~/.config/konsolerc --group KonsoleWindow --key RememberWindowSize false
    KWRITECONFIG_CMD --file ~/.config/konsolerc --group KonsoleWindow --key UseSingleInstance true

    # kate
    KWRITECONFIG_CMD --file ~/.config/katerc --group General --key "Close After Last" true
    KWRITECONFIG_CMD --file ~/.config/katerc --group General --key "Restore Window Configuration" false
    KWRITECONFIG_CMD --file ~/.config/katerc --group General --key "Save Meta Infos" false
    KWRITECONFIG_CMD --file ~/.config/katerc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    KWRITECONFIG_CMD --file ~/.config/katerc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"

    # kwrite
    KWRITECONFIG_CMD --file ~/.config/kwriterc --group General --key "Close After Last" true
    KWRITECONFIG_CMD --file ~/.config/kwriterc --group General --key "Restore Window Configuration" false
    KWRITECONFIG_CMD --file ~/.config/kwriterc --group General --key "Save Meta Infos" false
    KWRITECONFIG_CMD --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    KWRITECONFIG_CMD --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"
    

}

echo -e "Done gnome.sh..."

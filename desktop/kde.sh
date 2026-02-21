#!/bin/bash

GUI_TEXT_EDITOR=org.kde.kwrite.desktop

setup_kde() {
    printf 'Configuring KDE Plasma stuff...\n'
    install_pkgs "$KDE_PACKAGES_TO_INSTALL"

    KWRITECONFIG_CMD=kwriteconfig6
    if ! command_exists kwriteconfig6; then
        KWRITECONFIG_CMD=kwriteconfig5
    fi

    # configs
    lookandfeeltool -a org.kde.breezedark.desktop 2>/dev/null || printf 'Warning: Failed to set lookandfeel\n' >&2
    kscreen-doctor output.1.scale.1.25 2>/dev/null || true
    sudo mkdir -p /etc/sddm.conf.d
    sudo "$KWRITECONFIG_CMD" --file /etc/sddm.conf.d/kde_settings.conf --group Theme --key Current breeze
    sudo "$KWRITECONFIG_CMD" --file /etc/sddm.conf.d/kde_settings.conf --group Theme --key CursorTheme breeze_cursors
    sudo chmod -R +r /etc/sddm.conf.d/
    "$KWRITECONFIG_CMD" --file ~/.config/kdeglobals --group Sounds --key Enable false
    "$KWRITECONFIG_CMD" --file ~/.config/kdeglobals --group KScreen --key ScaleFactor 1.25
    "$KWRITECONFIG_CMD" --file ~/.config/kwinrc --group Xwayland --key Scale 1.25
    "$KWRITECONFIG_CMD" --file ~/.config/plasmashellrc --group PlasmaViews --group "Panel 2" --group Defaults --key thickness 30
    "$KWRITECONFIG_CMD" --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 2 --group Applets --group 5 --group Configuration --group General --key launchers "preferred://filemanager,applications:org.kde.kwrite.desktop,applications:org.kde.konsole.desktop,preferred://browser"
    "$KWRITECONFIG_CMD" --file ~/.config/kactivitymanagerd-pluginsrc --group Plugin-org.kde.ActivityManager.Resources.Scoring --key what-to-remember 2
    "$KWRITECONFIG_CMD" --file ~/.config/krunnerrc --group Plugins --key baloosearchEnabled false
    "$KWRITECONFIG_CMD" --file ~/.config/baloofilerc --group "Basic Settings" --key Indexing-Enabled false
    rm -f ~/.local/share/baloo/index
    "$KWRITECONFIG_CMD" --file ~/.config/powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec -1
    "$KWRITECONFIG_CMD" --file ~/.config/powerdevilrc --group AC --group Display --key TurnOffDisplayWhenIdle false

    # dolphin
    mkdir -p ~/.local/share/dolphin/view_properties/global
    "$KWRITECONFIG_CMD" --file ~/.local/share/dolphin/view_properties/global/.directory --group Settings --key HiddenFilesShown true

    # konsole
    copy_file ~/.local/share/konsole/catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/main/themes/catppuccin-mocha.colorscheme || true
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group Appearance --key ColorScheme catppuccin-mocha
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group Appearance --key Font "JetBrainsMono Nerd Font,12"
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group Appearance --key UseFontLineChararacters true
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group General --key Name custom
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group General --key TerminalColumns 120
    "$KWRITECONFIG_CMD" --file ~/.local/share/konsole/custom.profile --group General --key TerminalRows 36
    "$KWRITECONFIG_CMD" --file ~/.config/konsolerc --group "Desktop Entry" --key DefaultProfile custom.profile
    "$KWRITECONFIG_CMD" --file ~/.config/konsolerc --group KonsoleWindow --key RememberWindowSize false
    "$KWRITECONFIG_CMD" --file ~/.config/konsolerc --group KonsoleWindow --key UseSingleInstance true

    # kate
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group General --key "Close After Last" true
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group General --key "Restore Window Configuration" false
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group General --key "Save Meta Infos" false
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group "KTextEditor Renderer" --key "Auto Color Theme Selection" false
    "$KWRITECONFIG_CMD" --file ~/.config/katerc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"

    # kwrite
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group General --key "Close After Last" true
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group General --key "Restore Window Configuration" false
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group General --key "Save Meta Infos" false
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Color Theme" "Catppuccin Mocha"
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Auto Color Theme Selection" false
    "$KWRITECONFIG_CMD" --file ~/.config/kwriterc --group "KTextEditor Renderer" --key "Text Font" "JetBrainsMono Nerd Font,12"

}

printf 'Done kde.sh...\n'

#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.xfce.mousepad.desktop

setup_xfce() {
    echo -e "Configuring xfce stuffs..."
    install_pkgs "$XFCE_PACKAGES_TO_INSTALL"

    # config
    xfconf-query -c xsettings -v -n -p /Xft/DPI -t int -s 136
    xfconf-query -c xsettings -v -n -p /Xft/Hinting -t int -s 1
    xfconf-query -c xsettings -v -n -p /Xft/HintStyle -t string -s hintslight
    xfconf-query -c xsettings -v -n -p /Xft/RGBA -t string -s rgb
    xfconf-query -c xsettings -v -n -p /Xfce/LastCustomDPI -t int -s 136
    xfconf-query -c xsettings -v -n -p /Xfce/SyncThemes -t bool -s true 
    xfconf-query -c xfce4-session -v -n -p /general/SaveOnExit -t bool -s false 
    xfconf-query -c xfce4-session -v -n -p /compat/LaunchGNOME -t bool -s true 
    xfconf-query -c xfce4-power-manager -v -n -p /xfce4-power-manager/dpms-enabled -t bool -s false 
    xfconf-query -c xfce4-screensaver -v -n -p /saver/mode -t int -s 0 
    xfconf-query -c xfce4-screensaver -v -n -p /saver/enabled -t bool -s false 
    xfconf-query -c xfce4-screensaver -v -n -p /lock/enabled -t bool -s false 
    xfconf-query -c xfwm4 -v -n -p /general/workspace_count -t int -s 1

    # panel
    xfconf-query -c xfce4-panel -v -n -p /panels/dark-mode -t bool -s true

    # xfce4-terminal
    mkdir -p ~/.local/share/xfce4/terminal/colorschemes
    copy_file ~/.local/share/xfce4/terminal/colorschemes/catppuccin-mocha.theme https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/themes/catppuccin-mocha.theme
    copy_file ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml "${BASE_REPO_LOCATION}"home/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml

    # thunar
    xfconf-query -c thunar -v -n -p /last-show-hidden -t bool -s true
    xfconf-query -c thunar -v -n -p /misc-thumbnail-mode -t string -s THUNAR_THUMBNAIL_MODE_NEVER
    xfconf-query -c thunar -v -n -p /misc-thumbnail-max-file-size -t uint64 -s 1
    xfconf-query -c thunar-volman -v -n -p /automount-drives/enabled -t bool -s false
    xfconf-query -c thunar-volman -v -n -p /automount-media/enabled -t bool -s false

    copy_file "$TEMP_DIR"/xfce.dconf "${BASE_REPO_LOCATION}"desktop/xfce.dconf
    dconf load / <"$TEMP_DIR"/xfce.dconf
    rm -f "$TEMP_DIR"/xfce.dconf
}

setup_xfce_panel() {
    echo -e "Configuring xfce panel from scratch..."
    rm -rf ~/.config/xfce4/panel/launcher-*
    mkdir -p ~/.config/xfce4/panel/launcher-{2,3,4}
    copy_file ~/.config/xfce4/panel/launcher-2/FileManager.desktop "${BASE_REPO_LOCATION}"home/.config/xfce4/panel/launcher-2/FileManager.desktop
    copy_file ~/.config/xfce4/panel/launcher-3/TerminalEmulator.desktop "${BASE_REPO_LOCATION}"home/.config/xfce4/panel/launcher-3/TerminalEmulator.desktop
    copy_file ~/.config/xfce4/panel/launcher-4/WebBrowser.desktop "${BASE_REPO_LOCATION}"home/.config/xfce4/panel/launcher-4/WebBrowser.desktop
    copy_file ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml "${BASE_REPO_LOCATION}"home/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml

    xfce4-panel --restart
}

echo -e "Done xfce.sh..."

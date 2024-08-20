#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.xfce.mousepad.desktop

setup_xfce() {
    echo -e "Configuring xfce stuffs..."
    install_pkgs "$XFCE_PACKAGES_TO_INSTALL"

    # config
    xfconf-query -c xsettings -p /Xft/DPI -s 136
    xfconf-query -c xsettings -p /Xft/Hinting -s 1
    xfconf-query -c xsettings -p /Xft/HintStyle -s hintslight
    xfconf-query -c xsettings -p /Xft/RGBA -s rgb
    xfconf-query -c xsettings -p /Xfce/LastCustomDPI -s 136
    xfconf-query -c xsettings -p /Xfce/SyncThemes -s true 

    # xfce4-terminal
    mkdir -p ~/.local/share/xfce4/terminal/colorschemes
    copy_file ~/.local/share/xfce4/terminal/colorschemes/catppuccin-mocha.theme https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/themes/catppuccin-mocha.theme
    copy_file ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml "${BASE_REPO_LOCATION}"home/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml

    copy_file "$TEMP_DIR"/xfce.dconf "${BASE_REPO_LOCATION}"desktop/xfce.dconf
    dconf load / <"$TEMP_DIR"/xfce.dconf
    rm -f "$TEMP_DIR"/xfce.dconf
}

echo -e "Done xfce.sh..."

#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.xfce.mousepad.desktop

setup_xfce() {
    echo -e "Configuring xfce stuffs..."
    install_pkgs "$XFCE_PACKAGES_TO_INSTALL"

    # xfce4-terminal
    mkdir -p ~/.local/share/xfce4/terminal/colorschemes
    copy_file ~/.local/share/xfce4/terminal/colorschemes/catppuccin-mocha.theme https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/themes/catppuccin-mocha.theme

}

echo -e "Done xfce.sh..."
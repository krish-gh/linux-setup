#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=xed.desktop

setup_cinnamon() {
    echo -e "Configuring cinnamon stuffs..."
    install_pkgs "$CINNAMON_PACKAGES_TO_INSTALL"

    #mkdir -p ~/.local/share/xed/styles
    #copy_file ~/.local/share/xed/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml

    copy_file /tmp/cinnamon.dconf "${BASE_REPO_LOCATION}"desktop/cinnamon.dconf
    dconf load / </tmp/cinnamon.dconf
    rm -f /tmp/cinnamon.dconf

    [[ -f ~/.local/share/backgrounds/wallpaper ]] && gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper"
}

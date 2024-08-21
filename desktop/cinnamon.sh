#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=xed.desktop

setup_cinnamon() {
    echo -e "Configuring cinnamon stuffs..."
    install_pkgs "$CINNAMON_PACKAGES_TO_INSTALL"

    #mkdir -p ~/.local/share/xed/styles
    #copy_file ~/.local/share/xed/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml

    copy_file "$TEMP_DIR"/cinnamon.dconf "${BASE_REPO_LOCATION}"desktop/cinnamon.dconf
    dconf load / <"$TEMP_DIR"/cinnamon.dconf
    rm -f "$TEMP_DIR"/cinnamon.dconf

    # pinned apps
    gwlconfigfile=$(ls ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json)
    gwlconfig="$(jq '(."pinned-apps".value) |= [ "nemo.desktop", "xed.desktop", "org.gnome.Terminal.desktop", "firefox.desktop" ]' "$gwlconfigfile")" &&
        echo -E "${gwlconfig}" >"$gwlconfigfile"
}

setup_cinnamon_theme() {
    gsettings set org.gnome.desktop.interface gtk-theme Mint-Y-Dark-Blue
    gsettings set org.gnome.desktop.interface icon-theme Mint-Y-Blue
    gsettings set org.cinnamon.desktop.interface gtk-theme Mint-Y-Dark-Blue
    gsettings set org.cinnamon.desktop.interface icon-theme Mint-Y-Blue
    gsettings set org.cinnamon.theme name Mint-Y-Dark-Blue
}

set_wallpaper() {
    # shellcheck disable=SC2046
    gsettings set org.cinnamon.desktop.background picture-uri "file://$1"
}

echo -e "Done cinnamon.sh..."

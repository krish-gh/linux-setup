#!/bin/sh

GUI_TEXT_EDITOR=xed.desktop

setup_cinnamon() {
    printf 'Configuring Cinnamon stuff...\n'
    install_pkgs "$CINNAMON_PACKAGES_TO_INSTALL"

    copy_file "$TEMP_DIR/cinnamon.dconf" "${BASE_REPO_LOCATION}desktop/cinnamon.dconf" && {
        dconf load / < "$TEMP_DIR/cinnamon.dconf" 2>/dev/null || printf 'Warning: Failed to load dconf settings\n' >&2
        rm -f "$TEMP_DIR/cinnamon.dconf"
    }

    # pinned apps
    gwlconfigfile=$(ls ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json 2>/dev/null)
    if [ -n "$gwlconfigfile" ]; then
        gwlconfig="$(jq '(."pinned-apps".value) |= [ "nemo.desktop", "xed.desktop", "org.gnome.Terminal.desktop", "firefox.desktop" ]' "$gwlconfigfile")" && \
            printf '%s\n' "$gwlconfig" > "$gwlconfigfile"
    fi

    # menu
    mconfigfile=$(ls ~/.config/cinnamon/spices/menu@cinnamon.org/*.json 2>/dev/null)
    if [ -n "$mconfigfile" ]; then
        mconfig="$(jq '(."popup-height".value) |= 600' "$mconfigfile")" && \
            printf '%s\n' "$mconfig" > "$mconfigfile"
    fi
}

setup_cinnamon_theme() {
    gsettings set org.gnome.desktop.interface gtk-theme Mint-Y-Dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme Mint-Y 2>/dev/null || true
    gsettings set org.cinnamon.desktop.interface gtk-theme Mint-Y-Dark 2>/dev/null || true
    gsettings set org.cinnamon.desktop.interface icon-theme Mint-Y 2>/dev/null || true
    gsettings set org.cinnamon.theme name Mint-Y-Dark 2>/dev/null || true
    sudo crudini --ini-options=nospace --set /etc/lightdm/slick-greeter.conf Greeter theme-name Mint-Y-Dark 2>/dev/null || true
    sudo crudini --ini-options=nospace --set /etc/lightdm/slick-greeter.conf Greeter icon-theme-name Mint-Y 2>/dev/null || true
}

set_cinnamon_wallpaper() {
    # Set wallpaper for Cinnamon desktop
    gsettings set org.cinnamon.desktop.background picture-uri "file://$1" 2>/dev/null || true
}

printf 'Done cinnamon.sh...\n'

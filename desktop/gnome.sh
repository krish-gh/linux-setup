#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.gnome.TextEditor.desktop

setup_gnome() {
    echo -e "Configuring gnome stuffs..."
    install_pkgs "$GNOME_PACKAGES_TO_INSTALL"

    # GDM
    #sudo mkdir -p /etc/dconf/db/gdm.d
    #copy_file 95-gdm-settings ${BASE_REPO_LOCATION}system/etc/dconf/db/gdm.d/95-gdm-settings
    #sudo mv -f 95-gdm-settings /etc/dconf/db/gdm.d/

    echo -e "Installing some extensions..."
    if command_exists flatpak; then
        flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes
    else
        install_pkgs "$GNOME_EXT_MGR_PKG"
    fi
    pipx ensurepath
    pipx install gnome-extensions-cli --system-site-packages

    declare -A exts
    exts[1]=AlphabeticalAppGrid@stuarthayhurst
    exts[2]=clipboard-indicator@tudmotu.com
    exts[3]=status-area-horizontal-spacing@mathematical.coffee.gmail.com
    exts[4]=xwayland-indicator@swsnr.de
    exts[5]=apps-menu@gnome-shell-extensions.gcampax.github.com
    [[ $DIST_ID != ubuntu ]] && exts[6]=appindicatorsupport@rgcjonas.gmail.com
    [[ $DIST_ID != ubuntu ]] && exts[7]=dash-to-dock@micxgx.gmail.com
    [[ $DISTRO_TYPE == arch ]] && exts[arch]=arch-update@RaphaelRochet

    extdir=~/.local/share/gnome-shell/extensions
    for i in "${exts[@]}"; do
        ~/.local/bin/gnome-extensions-cli --filesystem install "$i"
        [[ -d $extdir/"$i"/schemas ]] && glib-compile-schemas $extdir/"$i"/schemas/
    done

    if [[ $TERMINAL_TO_INSTALL != none ]]; then
       python -m pip install --user --upgrade nautilus-open-any-terminal
       glib-compile-schemas ~/.local/share/glib-2.0/schemas/
       gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal "$TERMINAL_TO_INSTALL"
    fi

    copy_file "$TEMP_DIR"/gnome.dconf "${BASE_REPO_LOCATION}"desktop/gnome.dconf
    dconf load / <"$TEMP_DIR"/gnome.dconf
    rm -f "$TEMP_DIR"/gnome.dconf

    if [[ -f ~/.local/share/backgrounds/wallpaper ]]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/wallpaper"
    fi
}

echo -e "Done gnome.sh..."


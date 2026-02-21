#!/bin/bash

# shellcheck disable=SC2034
GUI_TEXT_EDITOR=org.gnome.TextEditor.desktop

setup_gnome() {
    printf 'Configuring GNOME stuff...\n'
    install_pkgs "$GNOME_PACKAGES_TO_INSTALL"

    printf 'Installing some extensions...\n'
    if command_exists flatpak; then
        eval "$FLATPAK_INSTALL_CMD" com.mattjakeman.ExtensionManager || printf 'Warning: Failed to install extension manager\n' >&2
    else
        install_pkgs "$GNOME_EXT_MGR_PKG"
    fi
    
    if command_exists pipx; then
        pipx ensurepath >/dev/null 2>&1 || true
        pipx install gnome-extensions-cli --system-site-packages 2>/dev/null || printf 'Warning: Failed to install gnome-extensions-cli\n' >&2
    else
        printf 'Warning: pipx not found, skipping gnome-extensions-cli\n' >&2
        return
    fi

    # POSIX-compatible extension list (using space-separated string instead of associative array)
    exts='AlphabeticalAppGrid@stuarthayhurst clipboard-indicator@tudmotu.com status-area-horizontal-spacing@mathematical.coffee.gmail.com xwayland-indicator@swsnr.de apps-menu@gnome-shell-extensions.gcampax.github.com'
    
    if [ "$DIST_ID" != "ubuntu" ]; then
        exts="$exts appindicatorsupport@rgcjonas.gmail.com dash-to-dock@micxgx.gmail.com"
    fi
    
    if [ "$DISTRO_TYPE" = "arch" ]; then
        exts="$exts arch-update@RaphaelRochet"
    elif [ "$DISTRO_TYPE" = "debian" ]; then
        exts="$exts debian-updates-indicator@glerro.pm.me"
    elif [ "$DISTRO_TYPE" = "fedora" ]; then
        exts="$exts update-extension@purejava.org"
    fi

    extdir=~/.local/share/gnome-shell/extensions
    for i in $exts; do
        ~/.local/bin/gnome-extensions-cli --filesystem install "$i" 2>/dev/null || printf 'Warning: Failed to install extension %s\n' "$i" >&2
        [ -d "$extdir/$i/schemas" ] && glib-compile-schemas "$extdir/$i/schemas/" 2>/dev/null || true
    done

    if [ "$TERMINAL_TO_INSTALL" != "none" ]; then
        python -m pip install --user --upgrade nautilus-open-any-terminal 2>/dev/null || printf 'Warning: Failed to install nautilus-open-any-terminal\n' >&2
        glib-compile-schemas ~/.local/share/glib-2.0/schemas/ 2>/dev/null || true
        gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal "$TERMINAL_TO_INSTALL" 2>/dev/null || true
    fi

    copy_file "$TEMP_DIR/gnome.dconf" "${BASE_REPO_LOCATION}desktop/gnome.dconf" && {
        dconf load / < "$TEMP_DIR/gnome.dconf" 2>/dev/null || printf 'Warning: Failed to load dconf settings\n' >&2
        rm -f "$TEMP_DIR/gnome.dconf"
    }
}

set_gnome_wallpaper() {
    # Set both light and dark wallpaper
    local wallpaper_uri="file://$1"
    gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "$wallpaper_uri" 2>/dev/null || true
}

printf 'Done gnome.sh...\n'


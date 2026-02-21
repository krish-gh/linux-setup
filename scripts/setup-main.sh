#!/bin/bash
set -o pipefail

scriptDir=$(cd -- "$(dirname -- "$0")" && pwd) || { printf 'Failed to determine script directory\n' >&2; exit 1; }
repoDir="$(dirname "$scriptDir")"
if [ -d "$repoDir/.git" ] && [ -f "$repoDir/scripts/setup-main.sh" ]; then
    BASE_REPO_LOCATION="$repoDir/"
else
    BASE_REPO_LOCATION="https://raw.githubusercontent.com/krish-gh/linux-setup/main/"
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Portable sed -i that works on both GNU and BSD systems
sed_i() {
    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i "$@"
    else
        # BSD sed requires an empty string for in-place editing
        sed -i '' "$@"
    fi
}

DISTRO_TYPE=''
PKG_MGR=''

if command_exists pacman; then
    PKG_MGR=pacman
    DISTRO_TYPE=arch
elif command_exists apt; then
    PKG_MGR=apt
    DISTRO_TYPE=debian
elif command_exists dnf; then
    PKG_MGR=dnf
    DISTRO_TYPE=fedora
elif command_exists zypper; then
    PKG_MGR=zypper
    DISTRO_TYPE=opensuse
fi

if [ -z "$DISTRO_TYPE" ]; then
    printf 'Error: Unsupported Linux distribution\n' >&2
    exit 1
fi

if ! command_exists curl; then
    printf 'Error: curl is required but not found\n' >&2
    exit 2
fi

DIST_ID=''
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DIST_ID="${ID:-}"
fi

DESKTOP=$(printf '%s\n' "${XDG_CURRENT_DESKTOP##*:}" | tr '[:upper:]' '[:lower:]' | sed 's/^x-//')
CURRENT_TERMINAL=$(ps -p "$PPID" -o comm= | sed 's/-$//')

printf '#################################################################\n'
printf 'BASE_REPO_LOCATION=%s\n' "$BASE_REPO_LOCATION"
printf 'DISTRO_TYPE=%s\n' "$DISTRO_TYPE"
printf 'PACKAGE_MANAGER=%s\n' "$PKG_MGR"
printf 'DESKTOP=%s\n' "$DESKTOP"
printf 'TERMINAL=%s\n' "$CURRENT_TERMINAL"
printf 'DISTRO_ID=%s\n' "$DIST_ID"
printf '#################################################################\n'
cat /etc/os-release
printf '#################################################################\n'

REFRESH_CMD=""
UPDATE_CMD=""
INSTALL_CMD=""
UNINSTALL_CMD=""
UNINSTALL_ONLY_CMD=""

FLATPAK_INSTALL_CMD="flatpak install --assumeyes flathub"
FLATPAK_UPDATE_CMD="flatpak update --assumeyes"

REQUIREMENTS=""
SYSTEM_PACKAGES_TO_INSTALL=""
INTEL_PACKAGES_TO_INSTALL=""
VMWARE_PACKAGES_TO_INSTALL=""
VBOX_PACKAGES_TO_INSTALL=""
HYPERV_PACKAGES_TO_INSTALL=""
VIRT_PACKAGES_TO_INSTALL=""
FONTS_TO_INSTALL=""
TERM_PACKAGES_TO_INSTALL=""
APP_PACKAGES_TO_INSTALL=""
DEV_PACKAGES_TO_INSTALL=""
GTK_PACKAGES_TO_INSTALL=""
QT_PACKAGES_TO_INSTALL=""
QT_PATCHES_TO_INSTALL=""
GNOME_PACKAGES_TO_INSTALL=""
GNOME_EXT_MGR_PKG=""
KDE_PACKAGES_TO_INSTALL=""
CINNAMON_PACKAGES_TO_INSTALL=""
XFCE_PACKAGES_TO_INSTALL=""
XFCE_MENU_LOGO=""
PACKAGES_TO_REMOVE=""

TERMINAL_TO_INSTALL=none
GUI_TEXT_EDITOR=""

TEMP_DIR=$(mktemp -d) || { printf 'Failed to create temp directory\n' >&2; exit 1; }
trap 'rm -rf "$TEMP_DIR"' EXIT

# arg1 = destination path, arg2 = source path
copy_file() {
    local dest="$1" src="$2"
    if echo "$src" | grep -q '^http'; then
        curl -f -o "$dest" "$src?$(date +%s)" || { printf 'Error downloading %s\n' "$src" >&2; return 1; }
    else
        cp -f "$src" "$dest" || { printf 'Error copying %s\n' "$src" >&2; return 1; }
    fi
}

# arg1 = source path
copy_content() {
    local src="$1"
    if echo "$src" | grep -q '^http'; then
        curl -f "$src?$(date +%s)" || { printf 'Error downloading %s\n' "$src" >&2; return 1; }
    else
        cat "$src" || { printf 'Error reading %s\n' "$src" >&2; return 1; }
    fi
}

refresh_package_sources() {
    eval "$REFRESH_CMD" || { printf 'Error refreshing package sources\n' >&2; return 1; }
}

update_packages() {
    eval "$UPDATE_CMD" || { printf 'Error updating packages\n' >&2; return 1; }
    if command_exists flatpak; then
        eval "$FLATPAK_UPDATE_CMD" || printf 'Warning: flatpak update failed\n' >&2
    fi
}

install_pkgs() {
    # Install packages one by one to avoid aborting on individual failures
    # Use word splitting instead of bash arrays for POSIX compatibility
    for pkg in $1; do
        eval "$INSTALL_CMD $pkg" || printf 'Warning: Failed to install %s\n' "$pkg" >&2
    done
}

uninstall_pkgs() {
    # Uninstall packages one by one to avoid aborting on individual failures
    for pkg in $1; do
        eval "$UNINSTALL_CMD $pkg" || printf 'Warning: Failed to uninstall %s\n' "$pkg" >&2
    done
}

uninstall_only_pkgs() {
    # Uninstall packages (without dependencies) one by one to avoid aborting on individual failures
    for pkg in $1; do
        eval "$UNINSTALL_ONLY_CMD $pkg" || printf 'Warning: Failed to uninstall %s\n' "$pkg" >&2
    done
}

debloat_pkgs() {
    printf 'Debloating...\n'
    local debloat_file="$TEMP_DIR/$DISTRO_TYPE.txt"
    copy_file "$debloat_file" "${BASE_REPO_LOCATION}debloat/$DISTRO_TYPE.txt" || { printf 'Warning: Could not download debloat list\n' >&2; return; }
    while IFS= read -r pkg; do
        [ -z "$pkg" ] || echo "$pkg" | grep -q '^#' && continue
        uninstall_pkgs "$pkg"
    done < "$debloat_file"
    rm -f "$debloat_file"

    if [ -n "$PACKAGES_TO_REMOVE" ]; then
        printf 'Removing additional packages...\n'
        uninstall_only_pkgs "$PACKAGES_TO_REMOVE"
    fi
}

# override with DISTRO_TYPE specific stuffs
printf 'Executing common %s specific script...\n' "$DISTRO_TYPE"
copy_file "$TEMP_DIR/$DISTRO_TYPE.sh" "${BASE_REPO_LOCATION}distros/$DISTRO_TYPE.sh" || { printf 'Error: Failed to download %s specific script\n' "$DISTRO_TYPE" >&2; exit 3; }
if [ ! -f "$TEMP_DIR/$DISTRO_TYPE.sh" ]; then
    printf 'Error: %s specific script not found!\n' "$DISTRO_TYPE" >&2
    exit 3
fi
# shellcheck disable=SC1090
. "$TEMP_DIR/$DISTRO_TYPE.sh" || { printf 'Error: Failed to source %s specific script\n' "$DISTRO_TYPE" >&2; exit 3; }
rm -f "$TEMP_DIR/$DISTRO_TYPE.sh"

# desktop environment specific stuffs
copy_file "$TEMP_DIR/$DESKTOP.sh" "${BASE_REPO_LOCATION}desktop/$DESKTOP.sh"
# shellcheck disable=SC1090
[ -f "$TEMP_DIR/$DESKTOP.sh" ] && . "$TEMP_DIR/$DESKTOP.sh"
rm -f "$TEMP_DIR/$DESKTOP.sh"

# execute exact distro specic stuffs if exists e.g. linux mint, ubuntu, manjaro etc. Optional.
if [ -n "$DIST_ID" ]; then
    copy_file "$TEMP_DIR/$DIST_ID.sh" "${BASE_REPO_LOCATION}specific/$DIST_ID.sh"
    # shellcheck disable=SC1090
    [ -f "$TEMP_DIR/$DIST_ID.sh" ] && . "$TEMP_DIR/$DIST_ID.sh"
    rm -f "$TEMP_DIR/$DIST_ID.sh"
fi

setup_system() {
    install_pkgs "virt-what"
    SYSTEM_TO_SETUP=$(sudo virt-what 2>/dev/null)

    if [ -n "$SYSTEM_TO_SETUP" ]; then
        printf 'SYSTEM=%s\n' "$SYSTEM_TO_SETUP"

        case "$SYSTEM_TO_SETUP" in

        vmware)
            install_pkgs "$VMWARE_PACKAGES_TO_INSTALL"
            sudo systemctl enable --now vmtoolsd.service 2>/dev/null || true
            ;;

        virtualbox)
            install_pkgs "$VBOX_PACKAGES_TO_INSTALL"
            sudo systemctl enable --now vboxservice.service 2>/dev/null || true
            ;;

        hyperv)
            install_pkgs "$HYPERV_PACKAGES_TO_INSTALL"
            sudo systemctl enable --now hv_{fcopy,kvp,vss}_daemon.service 2>/dev/null || true
            ;;

        qemu | kvm | xen | virt)
            install_pkgs "$VIRT_PACKAGES_TO_INSTALL"
            ;;

        *)
            printf 'Ahh! Taking a note...\n'
            ;;
        esac
    else
        # TODO detect bare metal
        SYSTEM_TO_SETUP=intel
        printf 'SYSTEM=%s\n' "$SYSTEM_TO_SETUP"

        case "$SYSTEM_TO_SETUP" in

        intel)
            install_pkgs "$INTEL_PACKAGES_TO_INSTALL"
            ;;

        *)
            printf 'Ahh! Taking a note...\n'
            ;;
        esac
    fi

    install_pkgs "$SYSTEM_PACKAGES_TO_INSTALL"

    printf 'Tweaking some system stuffs...\n'
    sudo mkdir -p /etc/sysctl.d /etc/systemd/{journald.conf.d,coredump.conf.d}
    copy_content "${BASE_REPO_LOCATION}system/etc/sysctl.d/999-sysctl.conf" | sudo tee /etc/sysctl.d/999-sysctl.conf >/dev/null
    copy_content "${BASE_REPO_LOCATION}system/etc/systemd/journald.conf.d/00-journal-size.conf" | sudo tee /etc/systemd/journald.conf.d/00-journal-size.conf >/dev/null
    sudo journalctl --rotate --vacuum-size=10M 2>/dev/null || true
    copy_content "${BASE_REPO_LOCATION}system/etc/systemd/coredump.conf.d/custom.conf" | sudo tee /etc/systemd/coredump.conf.d/custom.conf >/dev/null

    # env var
    mkdir -p ~/.config/environment.d
    copy_file ~/.config/environment.d/10-defaults.conf "${BASE_REPO_LOCATION}home/.config/environment.d/10-defaults.conf" || true

    # Helper function for appending to config files
    append_if_missing() {
        local file="$1" marker="$2" content_source="$3"
        if ! grep -q "$marker" "$file" 2>/dev/null; then
            copy_content "$content_source" >> "$file" || printf 'Warning: Failed to append to %s\n' "$file" >&2
        fi
    }

    append_if_missing ~/.profile "~custom-setup~" "${BASE_REPO_LOCATION}home/.profile"
    append_if_missing ~/.xprofile "~custom-setup~" "${BASE_REPO_LOCATION}home/.xprofile"
    append_if_missing ~/.xsessionrc "~custom-setup~" "${BASE_REPO_LOCATION}home/.xsessionrc"

    printf 'Setting up keyring...\n'
    mkdir -p ~/.local/share/keyrings/
    copy_file ~/.local/share/keyrings/Default_keyring.keyring "${BASE_REPO_LOCATION}home/.local/share/keyrings/Default_keyring.keyring" || true
    copy_file ~/.local/share/keyrings/default "${BASE_REPO_LOCATION}home/.local/share/keyrings/default" || true
    chmod og= ~/.local/share/keyrings/ 2>/dev/null || true
    chmod og= ~/.local/share/keyrings/Default_keyring.keyring 2>/dev/null || true

    printf 'Updating some sudo stuff...\n'
    sudo mkdir -p /etc/sudoers.d
    printf 'Defaults:%s !authenticate\n' "$(whoami)" | sudo tee /etc/sudoers.d/99-custom >/dev/null

    # autologin capability
    sudo groupadd -r autologin 2>/dev/null || true
    sudo gpasswd -a "$(whoami)" autologin 2>/dev/null || true

    systemctl is-enabled casper-md5check.service 2>/dev/null && sudo systemctl disable casper-md5check.service
    sudo systemctl daemon-reload
}

setup_font() {
    printf 'Installing fonts...\n'
    install_pkgs "$FONTS_TO_INSTALL"
    printf 'Making font look better...\n'
    mkdir -p ~/.config/fontconfig/conf.d
    copy_file ~/.config/fontconfig/fonts.conf "${BASE_REPO_LOCATION}home/.config/fontconfig/fonts.conf" || true
    copy_file ~/.config/fontconfig/conf.d/20-no-embedded.conf "${BASE_REPO_LOCATION}home/.config/fontconfig/conf.d/20-no-embedded.conf" || true
    copy_file ~/.Xresources "${BASE_REPO_LOCATION}home/.Xresources" || true
    xrdb -merge ~/.Xresources 2>/dev/null || true
    [ -f /etc/profile.d/freetype2.sh ] && sudo sed_i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/ 2>/dev/null
    sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/ 2>/dev/null
    sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/ 2>/dev/null
    [ -f /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf ] && sudo ln -sf /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/ 2>/dev/null
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        printf 'Installing Nerd Font manually as not found...\n'
        mkdir -p ~/.local/bin
        curl -fsS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin || printf 'Warning: Failed to install oh-my-posh\n' >&2
        ~/.local/bin/oh-my-posh font install JetBrainsMono 2>/dev/null || printf 'Warning: Failed to install JetBrainsMono font\n' >&2
    fi
    sudo fc-cache -fv >/dev/null || printf 'Warning: fc-cache failed\n' >&2
    fc-cache -fv >/dev/null || printf 'Warning: fc-cache failed\n' >&2
}

setup_terminal() {
    printf 'Configuring shell stuff...\n'
    install_pkgs "$TERM_PACKAGES_TO_INSTALL"
    if ! command_exists starship; then
        mkdir -p ~/.local/bin
        curl -fsS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin || printf 'Warning: starship installation failed\n' >&2
    fi
    copy_file ~/.aliases "${BASE_REPO_LOCATION}distros/$DISTRO_TYPE.aliases" || true
    append_if_missing ~/.bashrc "~custom-setup~" "${BASE_REPO_LOCATION}home/.bashrc"

    # nano
    mkdir -p ~/.config/nano
    copy_file ~/.config/nano/nanorc "${BASE_REPO_LOCATION}home/.config/nano/nanorc" || true
    if [ -d /usr/share/nano-syntax-highlighting/ ]; then
        append_if_missing ~/.config/nano/nanorc "nano-syntax-highlighting" "include \"/usr/share/nano-syntax-highlighting/*.nanorc\""
    fi

    # if fastfetch not found at this point fallback to neofetch, otherwise remove neofetch
    if ! command_exists fastfetch; then
        install_pkgs neofetch
    else
        uninstall_pkgs neofetch
    fi

    printf 'Installing terminal %s...\n' "$TERMINAL_TO_INSTALL"
    case "$TERMINAL_TO_INSTALL" in

    alacritty)
        install_pkgs "$TERMINAL_TO_INSTALL"
        mkdir -p ~/.config/alacritty
        copy_file ~/.config/alacritty/catppuccin-mocha.toml https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml || true
        copy_file ~/.config/alacritty/alacritty.toml "${BASE_REPO_LOCATION}home/.config/alacritty/alacritty.toml" || true
        ;;

    kitty)
        install_pkgs "$TERMINAL_TO_INSTALL"
        mkdir -p ~/.config/kitty
        copy_file ~/.config/kitty/mocha.conf https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf || true
        copy_file ~/.config/kitty/kitty.conf "${BASE_REPO_LOCATION}home/.config/kitty/kitty.conf" || true
        ;;

    wezterm)
        install_pkgs "$TERMINAL_TO_INSTALL"
        mkdir -p ~/.config/wezterm
        copy_file ~/.config/wezterm/wezterm.lua "${BASE_REPO_LOCATION}home/.config/wezterm/wezterm.lua" || true
        ;;

    *)
        printf 'No additional terminal installed...\n'
        ;;
    esac

    # gnome terminal
    if command_exists gnome-terminal; then
        tprofileid=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'" || echo "default")
        copy_file "$TEMP_DIR/gterm.dconf" "${BASE_REPO_LOCATION}desktop/gterm.dconf" && {
            sed_i "s/DEFAULT_PROFILE/$tprofileid/g" "$TEMP_DIR/gterm.dconf"
            dconf load /org/gnome/terminal/ < "$TEMP_DIR/gterm.dconf" 2>/dev/null || printf 'Warning: Failed to load dconf settings\n' >&2
            rm -f "$TEMP_DIR/gterm.dconf"
        }
    fi
}

setup_common_ui() {
    install_pkgs "$GTK_PACKAGES_TO_INSTALL"
    install_pkgs "$QT_PACKAGES_TO_INSTALL"

    gtktheme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || echo "")
    printf 'CURRENT_GTK_THEME=%s\n' "$gtktheme"
    # make it dark
    if [ -n "$gtktheme" ] && ! echo "$gtktheme" | grep -q -- '-dark$'; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtktheme-dark" 2>/dev/null || true
    fi

    copy_file "$TEMP_DIR/common.dconf" "${BASE_REPO_LOCATION}desktop/common.dconf" && {
        dconf load / < "$TEMP_DIR/common.dconf" 2>/dev/null || printf 'Warning: Failed to load dconf settings\n' >&2
        rm -f "$TEMP_DIR/common.dconf"
    }

    mkdir -p ~/.config/{gtk-3.0,gtk-4.0}
    if [ ! -f ~/.config/gtk-3.0/settings.ini ]; then
        printf '[Settings]\n' > ~/.config/gtk-3.0/settings.ini
        printf '#gtk-application-prefer-dark-theme=true\n' >> ~/.config/gtk-3.0/settings.ini
    fi
    if [ ! -f ~/.config/gtk-4.0/settings.ini ]; then
        cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/ || true
        printf 'gtk-hint-font-metrics=1\n' >> ~/.config/gtk-4.0/settings.ini
    fi

    mkdir -p ~/.local/share/gtksourceview-{3.0,4,5}/styles
    copy_file ~/.local/share/gtksourceview-3.0/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml || true
    for i in ~/.local/share/gtksourceview-{4,5}/styles; do
        cp -sf ~/.local/share/gtksourceview-3.0/styles/mocha.xml "$i" 2>/dev/null || true
    done

    printf 'Setting up QT apps to look like GTK...\n'
    mkdir -p ~/.config/Kvantum ~/.config/qt{5,6}ct
    copy_file ~/.config/Kvantum/kvantum.kvconfig "${BASE_REPO_LOCATION}home/.config/Kvantum/kvantum.kvconfig" || true
    for i in 5 6; do
        copy_file ~/.config/qt"${i}"ct/qt"${i}"ct.conf "${BASE_REPO_LOCATION}home/.config/qt${i}ct/qt${i}ct.conf" || true
    done

    if [ -d /etc/lightdm ]; then
        printf 'Configuring lightdm stuff...\n'
        grep -rl greeter-hide-users /etc/lightdm /usr/share/lightdm 2>/dev/null | \
        xargs -r sudo sed_i "/greeter-hide-users=true/c\\greeter-hide-users=false" 2>/dev/null || true
    fi
}

setup_apps() {
    printf 'Installing some apps...\n'
    install_pkgs "$APP_PACKAGES_TO_INSTALL"
    printf 'Installing some dev stuff...\n'
    install_pkgs "$DEV_PACKAGES_TO_INSTALL"

    # vlc
    mkdir -p ~/.config/vlc
    copy_file ~/.config/vlc/vlcrc "${BASE_REPO_LOCATION}home/.config/vlc/vlcrc" || true

    if command_exists yad; then
        gsettings set yad.settings terminal "$CURRENT_TERMINAL"' -e "%s"' 2>/dev/null || true
    fi

    printf 'Setting up file associations...\n'
    copy_file ~/.config/mimeapps.list "${BASE_REPO_LOCATION}home/.config/mimeapps.list" || true
    [ -f ~/.config/mimeapps.list ] && sed_i "s/DEFAULT_TEXT_EDITOR/$GUI_TEXT_EDITOR/g" ~/.config/mimeapps.list
    mkdir -p ~/.local/share/applications
    ln -sf ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list 2>/dev/null || true
}

debloat_pkgs
refresh_package_sources
printf 'Installing required packages...\n'
install_pkgs "$REQUIREMENTS"
if (command -v setup_"$DISTRO_TYPE" >/dev/null 2>&1); then
    setup_"$DISTRO_TYPE"
fi
install_pkgs crudini
if (command -v setup_specific_"$DIST_ID" >/dev/null 2>&1); then
    printf 'Executing additional %s specific script...\n' "$DIST_ID"
    setup_specific_"$DIST_ID"
fi
update_packages
setup_system
setup_font
setup_apps
if (command -v setup_"$DESKTOP" >/dev/null 2>&1); then
    setup_"$DESKTOP"
fi
setup_common_ui
if (command -v setup_"$DISTRO_TYPE"_"$DESKTOP" >/dev/null 2>&1); then
    printf 'Executing additional %s %s specific script...\n' "$DISTRO_TYPE" "$DESKTOP"
    setup_"$DISTRO_TYPE"_"$DESKTOP"
fi
if (command -v setup_specific_"$DIST_ID"_"$DESKTOP" >/dev/null 2>&1); then
    printf 'Executing additional %s %s specific script...\n' "$DIST_ID" "$DESKTOP"
    setup_specific_"$DIST_ID"_"$DESKTOP"
fi
setup_terminal
update_packages

printf '\n%s\n' "Setup complete! Please reboot your system."


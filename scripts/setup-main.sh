#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# arg1 = destination path, arg2 = source path
download_file() {
    curl -o "$1" "$2?$(date +%s)"
}

# arg1 = source path
download_content() {
    curl "$1?$(date +%s)"
}

DISTRO_TYPE=''
command_exists pacman && DISTRO_TYPE=arch
command_exists apt && DISTRO_TYPE=debian
#command_exists dnf && DISTRO_TYPE=fedora

if [[ $DISTRO_TYPE == '' ]]; then
    echo "You are not running supported Linux distrbution..."
    exit 1
fi

DESKTOP=$DESKTOP_SESSION
SYSTEM_TO_SETUP=vmware

echo -e "#################################################################"
echo -e "DISTRO TYPE=$DISTRO_TYPE"
echo -e "DESKTOP=$DESKTOP"
echo -e "SYSTEM=$SYSTEM_TO_SETUP"
echo -e "#################################################################"
cat /etc/os-release
echo -e "#################################################################"

BASE_REPO_URL="https://raw.githubusercontent.com/krish-gh/linux-setup/main/"

REFRESH_CMD=""   #override from DISTRO_TYPE specific script
INSTALL_CMD=""   #override from DISTRO_TYPE specific script
UNINSTALL_CMD="" #override from DISTRO_TYPE specific script

REQUIREMENTS=""               #override from DISTRO_TYPE specific script
SYSTEM_PACKAGES_TO_INSTALL="" #override from DISTRO_TYPE specific script
INTEL_PACKAGES_TO_INSTALL=""  #override from DISTRO_TYPE specific script
VMWARE_PACKAGES_TO_INSTALL="" #override from DISTRO_TYPE specific script
VBOX_PACKAGES_TO_INSTALL=""   #override from DISTRO_TYPE specific script
HYPERV_PACKAGES_TO_INSTALL="" #override from DISTRO_TYPE specific script
FONTS_TO_INSTALL=""           #override from DISTRO_TYPE specific script
TERM_PACKAGES_TO_INSTALL=""   #override from DISTRO_TYPE specific script
APP_PACKAGES_TO_INSTALL=""    #override from DISTRO_TYPE specific script
DEV_PACKAGES_TO_INSTALL=""    #override from DISTRO_TYPE specific script
GTK_PACKAGES_TO_INSTALL=""    #override from DISTRO_TYPE specific script
GNOME_PACKAGES_TO_INSTALL=""  #override from DISTRO_TYPE specific script
PACKAGES_TO_REMOVE=""         #override from DISTRO_TYPE specific script

TERMINAL_TO_INSTALL=kitty
GUI_TEXT_EDITOR="" #override from desktop specific script

# override with DISTRO_TYPE and desktop specific stuffs
download_file /tmp/"$DISTRO_TYPE".sh ${BASE_REPO_URL}distros/"$DISTRO_TYPE".sh
download_file /tmp/"$DESKTOP".sh ${BASE_REPO_URL}desktop/"$DESKTOP".sh
chmod +x /tmp/"$DISTRO_TYPE".sh
chmod +x /tmp/"$DESKTOP".sh
# shellcheck disable=SC1090
source /tmp/"$DISTRO_TYPE".sh
# shellcheck disable=SC1090
source /tmp/"$DESKTOP".sh
rm -f /tmp/"$DISTRO_TYPE".sh
rm -f /tmp/"$DESKTOP".sh
echo -e ""

refresh_package_sources() {
    eval "$REFRESH_CMD"
}

install_pkgs() {
    #doing in loop to avoid abort in case something is wrong
    # shellcheck disable=SC2207
    pkgs=($(eval echo "$1"))
    for i in "${pkgs[@]}"; do eval "$INSTALL_CMD $i"; done
}

uninstall_pkgs() {
    #doing in loop to avoid abort in case something is wrong
    # shellcheck disable=SC2207
    pkgs=($(eval echo "$1"))
    for i in "${pkgs[@]}"; do eval "$UNINSTALL_CMD $i"; done
}

setup_system() {
    echo -e "Setting up $SYSTEM_TO_SETUP..."
    case $SYSTEM_TO_SETUP in

    intel)
        install_pkgs "$INTEL_PACKAGES_TO_INSTALL"
        ;;

    vmware)
        install_pkgs "$VMWARE_PACKAGES_TO_INSTALL"
        sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service
        ;;

    vbox)
        install_pkgs "$VBOX_PACKAGES_TO_INSTALL"
        sudo systemctl enable --now vboxservice.service
        ;;

    hyperv)
        install_pkgs "$HYPERV_PACKAGES_TO_INSTALL"
        sudo systemctl enable --now hv_{fcopy,kvp,vss}_daemon.service
        ;;

    *)
        echo -e "No system selected..."
        ;;
    esac

    install_pkgs "$SYSTEM_PACKAGES_TO_INSTALL"

    echo -e "Tweaking some system stuffs..."
    sudo mkdir -p /etc/sysctl.d /etc/systemd/journald.conf.d
    download_file /tmp/999-sysctl.conf ${BASE_REPO_URL}system/etc/sysctl.d/999-sysctl.conf
    sudo mv -f /tmp/999-sysctl.conf /etc/sysctl.d/
    download_file /tmp/00-journal-size.conf ${BASE_REPO_URL}system/etc/systemd/journald.conf.d/00-journal-size.conf
    sudo mv -f /tmp/00-journal-size.conf /etc/systemd/journald.conf.d/
    sudo journalctl --rotate --vacuum-size=10M

    # env var
    mkdir -p ~/.config/environment.d
    download_file ~/.config/environment.d/10-defaults.conf ${BASE_REPO_URL}home/.config/environment.d/10-defaults.conf

    # wallpaper
    mkdir -p ~/.local/share/backgrounds
    download_file ~/.local/share/backgrounds/$DISTRO_TYPE.png ${BASE_REPO_URL}home/.local/share/backgrounds/$DISTRO_TYPE.png

    echo -e "Setting up keyring..."
    mkdir -p ~/.local/share/keyrings/
    download_file ~/.local/share/keyrings/Default_keyring.keyring ${BASE_REPO_URL}home/.local/share/keyrings/Default_keyring.keyring
    download_file ~/.local/share/keyrings/default ${BASE_REPO_URL}home/.local/share/keyrings/default
    chmod og= ~/.local/share/keyrings/
    chmod og= ~/.local/share/keyrings/Default_keyring.keyring

    echo -e "Updating some sudo stuffs..."
    sudo mkdir -p /etc/sudoers.d
    echo -e Defaults:"$(whoami)" \!authenticate | sudo tee /etc/sudoers.d/99-custom
}

improve_font() {
    echo -e "Installing fonts..."
    install_pkgs "$FONTS_TO_INSTALL"
    echo -e "Making font look better..."
    mkdir -p ~/.config/fontconfig/conf.d
    download_file ~/.config/fontconfig/fonts.conf ${BASE_REPO_URL}home/.config/fontconfig/fonts.conf
    #download_file ~/.config/fontconfig/conf.d/20-no-embedded.conf ${BASE_REPO_URL}home/.config/fontconfig/conf.d/20-no-embedded.conf
    download_file ~/.Xresources ${BASE_REPO_URL}home/.Xresources
    xrdb -merge ~/.Xresources    
    [[ -f /etc/profile.d/freetype2.sh ]] && sudo sed -i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
    [[ -f /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf ]] && sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/
    if [[ $(fc-list | grep -i "JetBrainsMono Nerd") == "" ]]; then
        echo -e "Installing Nerd Font manually as not found..."
        mkdir -p ~/.local/bin
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
        ~/.local/bin/oh-my-posh font install JetBrainsMono
    fi
    sudo fc-cache -fv
    fc-cache -fv
}

configure_terminal() {
    echo -e "Configuring shell stuffs..."
    install_pkgs "$TERM_PACKAGES_TO_INSTALL"
    if ! command_exists starship; then
        mkdir -p ~/.local/bin
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin
    fi
    #starship preset no-nerd-font -o ~/.config/starship.toml
    download_file ~/.aliases ${BASE_REPO_URL}distros/$DISTRO_TYPE.aliases
    bashrcAppend="$(
        grep "\.aliases" ~/.bashrc >/dev/null 2>&1
        echo $?
    )"
    if [[ "${bashrcAppend}" -ne 0 ]]; then
        download_content ${BASE_REPO_URL}home/.bashrc >>~/.bashrc
    fi

    # nano
    mkdir -p ~/.config/nano
    download_file ~/.config/nano/nanorc ${BASE_REPO_URL}home/.config/nano/nanorc
    if [[ -d /usr/share/nano-syntax-highlighting/ ]]; then
        nanorcAppend="$(
            grep "nano-syntax-highlighting" ~/.config/nano/nanorc >/dev/null 2>&1
            echo $?
        )"
        if [[ "${nanorcAppend}" -ne 0 ]]; then
            echo -e "include "/usr/share/nano-syntax-highlighting/*.nanorc"" >>~/.config/nano/nanorc
        fi
    fi

    # fastfetch
    #mkdir p ~/.config/fastfetch
    #download_file ~/.config/fastfetch/config.jsonc ${BASE_REPO_URL}home/.config/fastfetch/config.jsonc

    echo -e "Installing terminal $TERMINAL_TO_INSTALL..."
    case $TERMINAL_TO_INSTALL in

    alacritty)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/alacritty
        download_file ~/.config/alacritty/catppuccin-mocha.toml https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml
        download_file ~/.config/alacritty/alacritty.toml ${BASE_REPO_URL}home/.config/alacritty/alacritty.toml
        ;;

    kitty)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/kitty
        download_file ~/.config/kitty/mocha.conf https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf
        download_file ~/.config/kitty/kitty.conf ${BASE_REPO_URL}home/.config/kitty/kitty.conf
        ;;

    wezterm)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/wezterm
        download_file ~/.config/wezterm/wezterm.lua ${BASE_REPO_URL}home/.config/wezterm/wezterm.lua
        ;;

    *)
        echo -e "No additional terminal installed..."
        ;;
    esac

    # gnome console
    if command_exists kgx; then
        gsettings set org.gnome.Console audible-bell false
        gsettings set org.gnome.Console custom-font 'JetBrainsMono Nerd Font 12'
        # Below is to avoid updating font during setup as font starts looking bad
        #gsettings set org.gnome.Console use-system-font false
    fi

    # gnome terminal
    if command_exists gnome-terminal; then
        tprofileid=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        download_file /tmp/gterm.dconf ${BASE_REPO_URL}desktop/gterm.dconf
        sed -i "s/DEFAULT_PROFILE/$tprofileid/g" /tmp/gterm.dconf
        dconf load /org/gnome/terminal/ < /tmp/gterm.dconf
        rm -f /tmp/gterm.dconf
    fi

    #source ~/.bashrc
}

setup_pacman() {
    echo -e "Doing some cool stuffs in /etc/pacman.conf ..."
    sudo sed -i "/^#Color/c\Color\nILoveCandy
        /^#VerbosePkgLists/c\VerbosePkgLists
        /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    if [[ "$(find /etc/pacman.d/ -name chaotic-mirrorlist)" == "" ]]; then
        echo -e "Configuring Chaotic-AUR - https://aur.chaotic.cx/docs..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    fi

    chaoticAurAppend="$(
        grep "chaotic-aur" /etc/pacman.conf >/dev/null 2>&1
        echo $?
    )"
    if [[ "${chaoticAurAppend}" -ne 0 ]]; then
        echo "Appending Chaotic-AUR in pacman.conf..."
        echo -e | sudo tee -a /etc/pacman.conf
        echo -e "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
        echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    fi

    refresh_package_sources

    echo -e "Installing some more stuffs..."
    pamacvar='aur'
    if command_exists flatpak; then
        pamacvar='flatpak'
    fi

    install_pkgs "yay rate-mirrors reflector-simple mkinitcpio-firmware pamac-${pamacvar} visual-studio-code-bin"

    gsettings set yad.sourceview line-num true
    gsettings set yad.sourceview brackets true
    gsettings set yad.sourceview theme catppuccin_mocha
    #gsettings set yad.settings terminal 'kgx -e "%s"'

    # Configure pamac
    sudo sed -i "/RemoveUnrequiredDeps/s/^#//g
        /NoUpdateHideIcon/s/^#//g
        /KeepNumPackages/c\KeepNumPackages = 1
        /RefreshPeriod/c\RefreshPeriod = 0" /etc/pamac.conf

    if [[ $DESKTOP == "gnome" ]]; then
        echo -e "Installing some gnome stuffs from chaotic-aur"
        ! command_exists flatpak && install_pkgs "extension-manager"
        if [[ $TERMINAL_TO_INSTALL != none ]]; then
            install_pkgs "nautilus-open-any-terminal"
            gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal $TERMINAL_TO_INSTALL
        fi
    fi

    # misc
    flagstocopy=(code electron chromium chrome microsoft-edge-stable)
    for i in "${flagstocopy[@]}"; do
        download_file ~/.config/"${i}"-flags.conf ${BASE_REPO_URL}home/.config/"${i}"-flags.conf
    done
}

setup_apt() {
    echo -e "Setting up apt..."
    install_pkgs "nala wget gpg apt-transport-https"

    # vscode
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        refresh_package_sources
        install_pkgs code
    fi
}

setup_gtk() {
    install_pkgs "$GTK_PACKAGES_TO_INSTALL"

    download_file /tmp/gtk.dconf ${BASE_REPO_URL}desktop/gtk.dconf
    dconf load / < /tmp/gtk.dconf
    rm -f /tmp/gtk.dconf

    mkdir -p ~/.config/gtk-{3,4}.0
    #echo >~/.gtkrc-2.0
    echo -e "[Settings]" >~/.config/gtk-3.0/settings.ini && echo -e "#gtk-application-prefer-dark-theme=1" >>~/.config/gtk-3.0/settings.ini
    cp -f ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/
    echo -e "gtk-hint-font-metrics=1" >>~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.local/share/gtksourceview-{3.0,4,5}/styles
    download_file ~/.local/share/gtksourceview-3.0/styles/catppuccin-mocha.xml https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
    for i in ~/.local/share/gtksourceview-{4,5}/styles; do
        cp -s -f ~/.local/share/gtksourceview-3.0/styles/catppuccin-mocha.xml "$i"
    done

    echo -e "Setting up QT apps to look like GTK.."
    mkdir -p ~/.config/Kvantum ~/.config/qt{5,6}ct
    download_file ~/.config/Kvantum/kvantum.kvconfig ${BASE_REPO_URL}home/.config/Kvantum/kvantum.kvconfig
    for i in 5 6; do
        download_file ~/.config/qt${i}ct/qt${i}ct.conf ${BASE_REPO_URL}home/.config/qt${i}ct/qt${i}ct.conf
    done

}

setup_gnome() {
    echo -e "Configuring gnome stuffs..."
    install_pkgs "$GNOME_PACKAGES_TO_INSTALL"

    # GDM
    #sudo mkdir -p /etc/dconf/db/gdm.d
    #download_file 95-gdm-settings ${BASE_REPO_URL}system/etc/dconf/db/gdm.d/95-gdm-settings
    #sudo mv -f 95-gdm-settings /etc/dconf/db/gdm.d/

    echo -e "Installing some extensions..."
    command_exists flatpak && flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes
    pipx ensurepath
    pipx install gnome-extensions-cli --system-site-packages

    declare -A exts
    exts[1]=AlphabeticalAppGrid@stuarthayhurst
    exts[2]=appindicatorsupport@rgcjonas.gmail.com
    exts[3]=dash-to-dock@micxgx.gmail.com
    exts[4]=clipboard-indicator@tudmotu.com
    exts[5]=status-area-horizontal-spacing@mathematical.coffee.gmail.com
    exts[6]=xwayland-indicator@swsnr.de
    [[ $DISTRO_TYPE == arch ]] && exts[arch]=arch-update@RaphaelRochet

    extdir=~/.local/share/gnome-shell/extensions
    for i in "${exts[@]}"; do
        ~/.local/bin/gnome-extensions-cli --filesystem install "$i"
        [[ -d $extdir/"$i"/schemas ]] && glib-compile-schemas $extdir/"$i"/schemas/
    done
    ~/.local/bin/gnome-extensions-cli enable apps-menu@gnome-shell-extensions.gcampax.github.com    

    download_file /tmp/gnome.dconf ${BASE_REPO_URL}desktop/gnome.dconf
    dconf load / < /tmp/gnome.dconf
    rm -f /tmp/gnome.dconf
    
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/$DISTRO_TYPE.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/$DISTRO_TYPE.png"
}

setup_cinnamon() {
    echo -e "Configuring cinnamon stuffs..."
    download_file ~/.local/share/xed/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml

    download_file /tmp/cinnamon.dconf ${BASE_REPO_URL}desktop/cinnamon.dconf
    dconf load / < /tmp/cinnamon.dconf
    rm -f /tmp/cinnamon.dconf

    gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/$DISTRO_TYPE.png"
}

setup_apps() {
    echo -e "Installing some apps..."
    install_pkgs "$APP_PACKAGES_TO_INSTALL"
    echo -e "Installing some dev stuffs..."
    install_pkgs "$DEV_PACKAGES_TO_INSTALL"

    # meld
    gsettings set org.gnome.meld prefer-dark-theme true
    gsettings set org.gnome.meld show-line-numbers true
    gsettings set org.gnome.meld style-scheme catppuccin_mocha
    gsettings set org.gnome.meld highlight-syntax true

    # vlc
    mkdir -p ~/.config/vlc
    download_file ~/.config/vlc/vlcrc ${BASE_REPO_URL}home/.config/vlc/vlcrc

    echo -e "Setting up file associations..."
    download_file ~/.config/mimeapps.list ${BASE_REPO_URL}home/.config/mimeapps.list
    sed -i "s/DEFAULT_TEXT_EDITOR/$GUI_TEXT_EDITOR/g" ~/.config/mimeapps.list
    mkdir -p ~/.local/share/applications
    ln -sf ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list
}

echo -e "Removing not needed packages..."
uninstall_pkgs "$PACKAGES_TO_REMOVE"

refresh_package_sources

echo -e "Installing some needed stuffs..."
install_pkgs "$REQUIREMENTS"

setup_system
improve_font
configure_terminal
setup_gtk
[[ $DESKTOP == "gnome" ]] && setup_gnome
[[ $DESKTOP == "cinnamon" ]] && setup_cinnamon
setup_apps
command_exists pacman && setup_pacman
command_exists apt && setup_apt

echo -e ""
echo -e "Done...Reboot..."

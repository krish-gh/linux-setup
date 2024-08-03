#!/bin/bash

BASE_REPO_LOCATION="https://raw.githubusercontent.com/krish-gh/linux-setup/main/"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

DISTRO_TYPE=''
PKG_MGR=''
command_exists pacman && PKG_MGR=pacman && DISTRO_TYPE=arch
command_exists apt && PKG_MGR=apt && DISTRO_TYPE=debian
#command_exists dnf && PKG_MGR=dnf && DISTRO_TYPE=fedora

if [[ $DISTRO_TYPE == '' ]]; then
    >&2 echo "You are not running supported Linux distrbution..."
    exit 1
fi

if ! command_exists curl; then
    >&2 echo "curl required, but not found..."
    exit 2
fi

DIST_ID=''
# shellcheck disable=SC1091
[[ -f /etc/os-release ]] && source /etc/os-release && DIST_ID=$ID

# shellcheck disable=SC2086
DESKTOP=$(echo ${XDG_CURRENT_DESKTOP##*:} | tr '[:upper:]' '[:lower:]' | sed 's/^x-//')
SYSTEM_TO_SETUP=vmware
CURRENT_TERMINAL=$(ps -p $PPID -o comm= | sed 's/-$//')

echo -e "#################################################################"
echo -e "DISTRO_TYPE=$DISTRO_TYPE"
echo -e "PACKAGE_MANAGER=$PKG_MGR"
echo -e "DESKTOP=$DESKTOP"
echo -e "SYSTEM=$SYSTEM_TO_SETUP"
echo -e "TERMINAL=$CURRENT_TERMINAL"
echo -e "DISTRO_ID=$DIST_ID"
echo -e "#################################################################"
cat /etc/os-release
echo -e "#################################################################"

REFRESH_CMD=""   #override from DISTRO_TYPE specific script
INSTALL_CMD=""   #override from DISTRO_TYPE specific script
UNINSTALL_CMD="" #override from DISTRO_TYPE specific script

REQUIREMENTS=""                 #override from DISTRO_TYPE specific script
SYSTEM_PACKAGES_TO_INSTALL=""   #override from DISTRO_TYPE specific script
INTEL_PACKAGES_TO_INSTALL=""    #override from DISTRO_TYPE specific script
VMWARE_PACKAGES_TO_INSTALL=""   #override from DISTRO_TYPE specific script
VBOX_PACKAGES_TO_INSTALL=""     #override from DISTRO_TYPE specific script
HYPERV_PACKAGES_TO_INSTALL=""   #override from DISTRO_TYPE specific script
FONTS_TO_INSTALL=""             #override from DISTRO_TYPE specific script
TERM_PACKAGES_TO_INSTALL=""     #override from DISTRO_TYPE specific script
APP_PACKAGES_TO_INSTALL=""      #override from DISTRO_TYPE specific script
DEV_PACKAGES_TO_INSTALL=""      #override from DISTRO_TYPE specific script
GTK_PACKAGES_TO_INSTALL=""      #override from DISTRO_TYPE specific script
QT_PACKAGES_TO_INSTALL=""       #override from DISTRO_TYPE specific script
GNOME_PACKAGES_TO_INSTALL=""    #override from DISTRO_TYPE specific script
CINNAMON_PACKAGES_TO_INSTALL="" #override from DISTRO_TYPE specific script
PACKAGES_TO_REMOVE=""           #override from DISTRO_TYPE specific script

TERMINAL_TO_INSTALL=kitty
GUI_TEXT_EDITOR="" #override from desktop specific script

# arg1 = destination path, arg2 = source path
copy_file() {
    curl -f -o "$1" "$2?$(date +%s)"
    curl_exit_status=$?
    [[ $curl_exit_status != 0 ]] && >&2 echo -e "Error downloading $2"
}

# arg1 = source path
copy_content() {
    curl -f "$1?$(date +%s)"
    curl_exit_status=$?
    [[ $curl_exit_status != 0 ]] && >&2 echo -e "Error downloading $1"
}

# override with DISTRO_TYPE specific stuffs
echo -e "Executing common $DISTRO_TYPE specific script..."
copy_file /tmp/"$DISTRO_TYPE".sh ${BASE_REPO_LOCATION}distros/"$DISTRO_TYPE".sh
if [[ ! -f /tmp/"$DISTRO_TYPE".sh ]]; then
    >&2 echo "Error: $DISTRO_TYPE specific script not found!"
    exit 3
fi
# shellcheck disable=SC1090
source /tmp/"$DISTRO_TYPE".sh
rm -f /tmp/"$DISTRO_TYPE".sh

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
        ! systemctl is-enabled vmtoolsd.service && sudo systemctl enable --now vmtoolsd.service
        ;;

    vbox)
        install_pkgs "$VBOX_PACKAGES_TO_INSTALL"
        ! systemctl is-enabled vboxservice.service && sudo systemctl enable --now vboxservice.service
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
    copy_file /tmp/999-sysctl.conf ${BASE_REPO_LOCATION}system/etc/sysctl.d/999-sysctl.conf
    sudo mv -f /tmp/999-sysctl.conf /etc/sysctl.d/
    copy_file /tmp/00-journal-size.conf ${BASE_REPO_LOCATION}system/etc/systemd/journald.conf.d/00-journal-size.conf
    sudo mv -f /tmp/00-journal-size.conf /etc/systemd/journald.conf.d/
    sudo journalctl --rotate --vacuum-size=10M

    # env var
    mkdir -p ~/.config/environment.d
    copy_file ~/.config/environment.d/10-defaults.conf ${BASE_REPO_LOCATION}home/.config/environment.d/10-defaults.conf

    #mkdir -p ~/.config/systemd/user/service.d
    #copy_file ~/.config/systemd/user/service.d/env.conf ${BASE_REPO_LOCATION}home/.config/systemd/user/service.d/env.conf

    profileAppend="$(
        grep "~custom-setup~" ~/.profile >/dev/null 2>&1
        echo $?
    )"
    if [[ "${profileAppend}" -ne 0 ]]; then
        copy_content ${BASE_REPO_LOCATION}home/.profile >>~/.profile
    fi

    xprofileAppend="$(
        grep "~custom-setup~" ~/.xprofile >/dev/null 2>&1
        echo $?
    )"
    if [[ "${xprofileAppend}" -ne 0 ]]; then
        copy_content ${BASE_REPO_LOCATION}home/.xprofile >>~/.xprofile
    fi

    echo -e "Setting up keyring..."
    mkdir -p ~/.local/share/keyrings/
    copy_file ~/.local/share/keyrings/Default_keyring.keyring ${BASE_REPO_LOCATION}home/.local/share/keyrings/Default_keyring.keyring
    copy_file ~/.local/share/keyrings/default ${BASE_REPO_LOCATION}home/.local/share/keyrings/default
    chmod og= ~/.local/share/keyrings/
    chmod og= ~/.local/share/keyrings/Default_keyring.keyring

    echo -e "Updating some sudo stuffs..."
    sudo mkdir -p /etc/sudoers.d
    echo -e Defaults:"$(whoami)" \!authenticate | sudo tee /etc/sudoers.d/99-custom

    systemctl is-enabled casper-md5check.service && sudo systemctl disable casper-md5check.service
}

setup_font() {
    echo -e "Installing fonts..."
    install_pkgs "$FONTS_TO_INSTALL"
    echo -e "Making font look better..."
    mkdir -p ~/.config/fontconfig/conf.d
    copy_file ~/.config/fontconfig/fonts.conf ${BASE_REPO_LOCATION}home/.config/fontconfig/fonts.conf
    copy_file ~/.config/fontconfig/conf.d/20-no-embedded.conf ${BASE_REPO_LOCATION}home/.config/fontconfig/conf.d/20-no-embedded.conf
    copy_file ~/.Xresources ${BASE_REPO_LOCATION}home/.Xresources
    xrdb -merge ~/.Xresources
    [[ -f /etc/profile.d/freetype2.sh ]] && sudo sed -i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
    [[ -f /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf ]] && sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/
    if [[ $(fc-list | grep -i "JetBrainsMono Nerd") == "" ]]; then
        echo -e "Installing Nerd Font manually as not found..."
        mkdir -p ~/.local/bin
        curl -fs https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
        ~/.local/bin/oh-my-posh font install JetBrainsMono
    fi
    sudo fc-cache -fv
    fc-cache -fv
}

setup_terminal() {
    echo -e "Configuring shell stuffs..."
    install_pkgs "$TERM_PACKAGES_TO_INSTALL"
    if ! command_exists starship; then
        mkdir -p ~/.local/bin
        curl -fsS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin
    fi
    #starship preset no-nerd-font -o ~/.config/starship.toml
    copy_file ~/.aliases ${BASE_REPO_LOCATION}distros/$DISTRO_TYPE.aliases
    bashrcAppend="$(
        grep "~custom-setup~" ~/.bashrc >/dev/null 2>&1
        echo $?
    )"
    if [[ "${bashrcAppend}" -ne 0 ]]; then
        copy_content ${BASE_REPO_LOCATION}home/.bashrc >>~/.bashrc
    fi

    # nano
    mkdir -p ~/.config/nano
    copy_file ~/.config/nano/nanorc ${BASE_REPO_LOCATION}home/.config/nano/nanorc
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
    #copy_file ~/.config/fastfetch/config.jsonc ${BASE_REPO_LOCATION}home/.config/fastfetch/config.jsonc

    echo -e "Installing terminal $TERMINAL_TO_INSTALL..."
    case $TERMINAL_TO_INSTALL in

    alacritty)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/alacritty
        copy_file ~/.config/alacritty/catppuccin-mocha.toml https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml
        copy_file ~/.config/alacritty/alacritty.toml ${BASE_REPO_LOCATION}home/.config/alacritty/alacritty.toml
        ;;

    kitty)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/kitty
        copy_file ~/.config/kitty/mocha.conf https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf
        copy_file ~/.config/kitty/kitty.conf ${BASE_REPO_LOCATION}home/.config/kitty/kitty.conf
        ;;

    wezterm)
        install_pkgs $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/wezterm
        copy_file ~/.config/wezterm/wezterm.lua ${BASE_REPO_LOCATION}home/.config/wezterm/wezterm.lua
        ;;

    *)
        echo -e "No additional terminal installed..."
        ;;
    esac

    # gnome terminal
    if command_exists gnome-terminal; then
        tprofileid=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        copy_file /tmp/gterm.dconf ${BASE_REPO_LOCATION}desktop/gterm.dconf
        sed -i "s/DEFAULT_PROFILE/$tprofileid/g" /tmp/gterm.dconf
        dconf load /org/gnome/terminal/ </tmp/gterm.dconf
        rm -f /tmp/gterm.dconf
    fi

    #source ~/.bashrc
}

setup_ui() {
    install_pkgs "$GTK_PACKAGES_TO_INSTALL"
    install_pkgs "$QT_PACKAGES_TO_INSTALL"

    copy_file /tmp/gtk.dconf ${BASE_REPO_LOCATION}desktop/gtk.dconf
    dconf load / </tmp/gtk.dconf
    rm -f /tmp/gtk.dconf

    # make it dark
    gtktheme=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \'\")
    if [[ $gtktheme != '' && $gtktheme != *dark ]]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtktheme"-dark
    fi

    mkdir -p ~/.config/gtk-{3,4}.0
    #echo >~/.gtkrc-2.0
    echo -e "[Settings]" >~/.config/gtk-3.0/settings.ini && echo -e "#gtk-application-prefer-dark-theme=1" >>~/.config/gtk-3.0/settings.ini
    cp -f ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/
    echo -e "gtk-hint-font-metrics=1" >>~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.local/share/gtksourceview-{3.0,4,5}/styles
    copy_file ~/.local/share/gtksourceview-3.0/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml
    for i in ~/.local/share/gtksourceview-{4,5}/styles; do
        cp -s -f ~/.local/share/gtksourceview-3.0/styles/mocha.xml "$i"
    done

    echo -e "Setting up QT apps to look like GTK.."
    mkdir -p ~/.config/Kvantum ~/.config/qt{5,6}ct
    copy_file ~/.config/Kvantum/kvantum.kvconfig ${BASE_REPO_LOCATION}home/.config/Kvantum/kvantum.kvconfig
    for i in 5 6; do
        copy_file ~/.config/qt${i}ct/qt${i}ct.conf ${BASE_REPO_LOCATION}home/.config/qt${i}ct/qt${i}ct.conf
    done

    # wallpaper
    #mkdir -p ~/.local/share/backgrounds
    #copy_file ~/.local/share/backgrounds/wallpaper ${BASE_REPO_LOCATION}home/.local/share/backgrounds/wallpaper
}

setup_gnome() {
    echo -e "Configuring gnome stuffs..."
    GUI_TEXT_EDITOR=org.gnome.TextEditor.desktop
    install_pkgs "$GNOME_PACKAGES_TO_INSTALL"

    # GDM
    #sudo mkdir -p /etc/dconf/db/gdm.d
    #copy_file 95-gdm-settings ${BASE_REPO_LOCATION}system/etc/dconf/db/gdm.d/95-gdm-settings
    #sudo mv -f 95-gdm-settings /etc/dconf/db/gdm.d/

    echo -e "Installing some extensions..."
    command_exists flatpak && flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes
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

    copy_file /tmp/gnome.dconf ${BASE_REPO_LOCATION}desktop/gnome.dconf
    dconf load / </tmp/gnome.dconf
    rm -f /tmp/gnome.dconf

    if [[ -f ~/.local/share/backgrounds/wallpaper ]]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/wallpaper"
    fi
}

setup_cinnamon() {
    echo -e "Configuring cinnamon stuffs..."
    GUI_TEXT_EDITOR=xed.desktop
    install_pkgs "$CINNAMON_PACKAGES_TO_INSTALL"

    #mkdir -p ~/.local/share/xed/styles
    #copy_file ~/.local/share/xed/styles/mocha.xml https://raw.githubusercontent.com/catppuccin/xed/main/src/mocha.xml

    copy_file /tmp/cinnamon.dconf ${BASE_REPO_LOCATION}desktop/cinnamon.dconf
    dconf load / </tmp/cinnamon.dconf
    rm -f /tmp/cinnamon.dconf

    [[ -f ~/.local/share/backgrounds/wallpaper ]] && gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper"
}

setup_apps() {
    echo -e "Installing some apps..."
    install_pkgs "$APP_PACKAGES_TO_INSTALL"
    echo -e "Installing some dev stuffs..."
    install_pkgs "$DEV_PACKAGES_TO_INSTALL"

    # meld
    gsettings set org.gnome.meld prefer-dark-theme true
    gsettings set org.gnome.meld show-line-numbers true
    gsettings set org.gnome.meld style-scheme catppuccin-mocha
    gsettings set org.gnome.meld highlight-syntax true

    # vlc
    mkdir -p ~/.config/vlc
    copy_file ~/.config/vlc/vlcrc ${BASE_REPO_LOCATION}home/.config/vlc/vlcrc

    # onboard
    if command_exists onboard; then
        gsettings set org.onboard theme '/usr/share/onboard/themes/Droid.theme'
        gsettings set org.onboard.window docking-enabled true
        gsettings set org.onboard.window docking-edge bottom
        gsettings set org.onboard.window docking-shrink-workarea false
        gsettings set org.onboard.window.landscape dock-expand false
        gsettings set org.onboard.window.portrait dock-expand false
    fi

    if command_exists yad; then
        gsettings set yad.sourceview line-num true
        gsettings set yad.sourceview brackets true
        gsettings set yad.sourceview theme catppuccin-mocha
        gsettings set yad.settings terminal "$CURRENT_TERMINAL"' -e "%s"'
    fi

    echo -e "Setting up file associations..."
    copy_file ~/.config/mimeapps.list ${BASE_REPO_LOCATION}home/.config/mimeapps.list
    sed -i "s/DEFAULT_TEXT_EDITOR/$GUI_TEXT_EDITOR/g" ~/.config/mimeapps.list
    mkdir -p ~/.local/share/applications
    ln -sf ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list
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

    install_pkgs "yay rate-mirrors reflector-simple pamac-${pamacvar} visual-studio-code-bin"
    [[ -f /etc/mkinitcpio.conf ]] && install_pkgs "mkinitcpio-firmware"

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

    if [[ $DESKTOP == "cinnamon" ]]; then
        echo -e "Installing some cinnamon stuffs from chaotic-aur"
        install_pkgs "xviewer xviewer-plugins mint-themes mint-y-icons"
    fi

    # misc
    flagstocopy=(code electron chromium chrome microsoft-edge-stable)
    for i in "${flagstocopy[@]}"; do
        copy_file ~/.config/"${i}"-flags.conf ${BASE_REPO_LOCATION}home/.config/"${i}"-flags.conf
    done
}

setup_apt() {
    echo -e "Setting up apt..."
    install_pkgs "nala wget gpg apt-transport-https"
    sudo mkdir -p -m 755 /etc/apt/keyrings

    # vscode
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
        rm -f packages.microsoft.gpg .wget-hsts
    fi

    # github
    if [[ ! -f /etc/apt/sources.list.d/github-cli.list ]]; then
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        rm -f .wget-hsts
    fi

    # add some ppa if ubuntu based
    if [[ $DIST_ID == *ubuntu* || $ID_LIKE == *ubuntu* ]]; then
        # for qt6-style-kvantum
        sudo add-apt-repository ppa:papirus/papirus -y
    fi

    refresh_package_sources
    install_pkgs "code gh qt6-style-kvantum{,-themes}"

    if [[ $DESKTOP == "gnome" ]]; then
        echo -e "Installing some more gnome stuffs"
        ! command_exists flatpak && install_pkgs "gnome-shell-extension-manager"
    fi
}

# execute exact distro specic stuffs if exists e.g. linux mint, ubuntu, manjaro etc. Optional.
if [[ $DIST_ID != '' ]]; then
    copy_file /tmp/"$DIST_ID".sh ${BASE_REPO_LOCATION}specific/"$DIST_ID".sh
    # shellcheck disable=SC1090
    [[ -f /tmp/"$DIST_ID".sh ]] && source /tmp/"$DIST_ID".sh
    rm -f /tmp/"$DIST_ID".sh
fi

if [[ $(type -t setup_"$DIST_ID") == function ]]; then
    echo -e "Executing additional $DIST_ID specific script..."
    setup_"$DIST_ID"
fi

echo -e "Removing not needed packages..."
uninstall_pkgs "$PACKAGES_TO_REMOVE"
refresh_package_sources

echo -e "Installing some needed stuffs..."
install_pkgs "$REQUIREMENTS"

setup_system
setup_font
setup_ui
[[ $(type -t setup_"$DESKTOP") == function ]] && setup_"$DESKTOP"
setup_terminal
setup_apps
[[ $(type -t setup_"$PKG_MGR") == function ]] && setup_"$PKG_MGR"

echo -e ""
echo -e "Done...Reboot..."

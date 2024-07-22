#!/bin/bash

# Check if the distro is (based on) Arch Linux
isArch="$(
    command -v pacman >/dev/null 2>&1
    echo $?
)"

if [[ "${isArch}" -ne 0 ]]; then
    echo "You do not run an Arch-based Linux distrbution ..."
    exit 1
fi

unset isArch

SYSTEM_TO_SETUP=vmware
baseRepoUrl="https://raw.githubusercontent.com/krish-gh/linux-setup/main/"

REFRESH_CMD="sudo pacman -Syu"
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"

REQUIREMENTS="curl"
SYSTEM_PACKAGES_TO_INSTALL="vulkan-{mesa-layers,swrast,icd-loader} sof-firmware alsa-{firmware,oss,plugins,utils}"
FONTS_TO_INSTALL="noto-{fonts,fonts-extra,fonts-emoji} ttf-{liberation,dejavu,roboto,ubuntu-font-family,nerd-fonts-symbols-mono,jetbrains-mono}"
TERM_PACKAGES_TO_INSTALL="diffutils bash-completion nano-syntax-highlighting starship neofetch fastfetch xclip wl-clipboard neovim"
APP_PACKAGES_TO_INSTALL="pacman-contrib archlinux-wallpaper firefox gnome-keyring seahorse vlc"
DEV_PACKAGES_TO_INSTALL="base-devel git github-cli shfmt meld"
PACKAGES_TO_REMOVE="snapshot baobab simple-scan epiphany totem yelp gedit vim gnome-{calculator,calendar,clocks,connections,contacts,maps,music,nettool,power-manager,tour,weather,user-docs,terminal}"
GTK_PACKAGES_TO_INSTALL="kvantum-qt5 qt{5,6}-wayland qt{5,6}ct"

gnome=1
GNOME_PACKAGES_TO_INSTALL="gnome-{themes-extra,menus,tweaks,shell-extensions,console,text-editor} python-nautilus python-pipx"

TERMINAL_TO_INSTALL=kitty
GUI_TEXT_EDITOR=org.gnome.TextEditor.desktop

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

refresh_package_sources() {
    $REFRESH_CMD
}

install() {
    #expanding the string to allow substitution
    pkgs=$(eval echo "$1")
    # shellcheck disable=SC2086
    $INSTALL_CMD $pkgs
}

uninstall() {
    #doing removing in loop to avoid abort in case something is not installed
    # shellcheck disable=SC2207
    pkgs=($(eval echo "$1"))
    for i in "${pkgs[@]}"; do $UNINSTALL_CMD "$i"; done
}

setup_system() {
    echo -e "Setting up $SYSTEM_TO_SETUP..."
    case $SYSTEM_TO_SETUP in

    intel)
        install "intel-media-driver vulkan-intel"
        ;;

    vmware)
        install "xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools"
        sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service
        ;;

    vbox)
        install "virtualbox-guest-utils"
        sudo systemctl enable --now vboxservice.service
        ;;

    hyperv)
        install "hyperv"
        sudo systemctl enable --now hv_{fcopy,kvp,vss}_daemon.service
        ;;

    *)
        echo -e "No system selected..."
        ;;
    esac

    install "$SYSTEM_PACKAGES_TO_INSTALL"
    
    echo -e "Tweaking some system stuffs..."
    sudo mkdir -p /etc/sysctl.d /etc/systemd/journald.conf.d
    curl -o 999-sysctl.conf ${baseRepoUrl}system/etc/sysctl.d/999-sysctl.conf
    sudo mv -i 999-sysctl.conf /etc/sysctl.d/
    curl -o 00-journal-size.conf ${baseRepoUrl}system/etc/systemd/journald.conf.d/00-journal-size.conf
    sudo mv -i 00-journal-size.conf /etc/systemd/journald.conf.d/
    sudo journalctl --rotate --vacuum-size=10M

    echo -e "Updating some sudo stuffs..."
    sudo mkdir -p /etc/sudoers.d
    echo -e Defaults:"$(whoami)" \!authenticate | sudo tee /etc/sudoers.d/99-custom
}

improve_font() {
    echo -e "Installing fonts..."
    install "$FONTS_TO_INSTALL"
    echo -e "Making font look better..."
    mkdir -p ~/.config/fontconfig/conf.d
    curl -o ~/.config/fontconfig/fonts.conf ${baseRepoUrl}home/.config/fontconfig/fonts.conf
    curl -o ~/.config/fontconfig/conf.d/20-no-embedded.conf ${baseRepoUrl}home/.config/fontconfig/conf.d/20-no-embedded.conf
    curl -o ~/.Xresources ${baseRepoUrl}home/.Xresources
    install "xorg-xrdb"
    xrdb -merge ~/.Xresources
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/
    sudo sed -i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    gsettings set org.gnome.desktop.interface font-antialiasing rgba
    gsettings set org.gnome.desktop.interface font-hinting slight
    sudo fc-cache -fv
    fc-cache -fv
}

configure_terminal() {
    echo -e "Configuring shell stuffs..."
    install "$TERM_PACKAGES_TO_INSTALL"
    #starship preset no-nerd-font -o ~/.config/starship.toml
    curl -o ~/.aliases ${baseRepoUrl}home/arch/.aliases
    bashrcAppend="$(
        grep ".aliases" ~/.bashrc >/dev/null 2>&1
        echo $?
    )"
    if [[ "${bashrcAppend}" -ne 0 ]]; then
        curl ${baseRepoUrl}home/.bashrc >>~/.bashrc
    fi

    # env var
    mkdir -p ~/.config/environment.d
    curl -o ~/.config/environment.d/10-defaults.conf ${baseRepoUrl}home/.config/environment.d/10-defaults.conf

    # nano
    mkdir -p ~/.config/nano
    curl -o ~/.config/nano/nanorc ${baseRepoUrl}home/.config/nano/nanorc

    echo -e "Installing terminal $TERMINAL_TO_INSTALL..."
    case $TERMINAL_TO_INSTALL in

    alacritty)
        install $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/alacritty
        curl -o ~/.config/alacritty/catppuccin-mocha.toml https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml
        curl -o ~/.config/alacritty/alacritty.toml ${baseRepoUrl}home/.config/alacritty/alacritty.toml
        ;;

    kitty)
        install $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/kitty
        curl -o ~/.config/kitty/mocha.conf https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf
        curl -o ~/.config/kitty/kitty.conf ${baseRepoUrl}home/.config/kitty/kitty.conf
        ;;

    wezterm)
        install $TERMINAL_TO_INSTALL
        mkdir -p ~/.config/wezterm
        curl -o ~/.config/wezterm/wezterm.lua ${baseRepoUrl}home/.config/wezterm/wezterm.lua
        ;;

    *)
        echo -e "No additional terminal installed..."
        ;;
    esac

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
    install "yay rate-mirrors reflector-simple xterm mkinitcpio-firmware"

    gsettings set yad.sourceview line-num true
    gsettings set yad.sourceview brackets true
    gsettings set yad.sourceview theme catppuccin_mocha
    #gsettings set yad.settings terminal 'kgx -e "%s"'

    pamacvar='aur'
    if command_exists flatpak; then
        pamacvar='flatpak'
    fi
    install "pamac-${pamacvar}"

    # Configure pamac
    sudo sed -i "/RemoveUnrequiredDeps/s/^#//g
        /NoUpdateHideIcon/s/^#//g
        /KeepNumPackages/c\KeepNumPackages = 1
        /RefreshPeriod/c\RefreshPeriod = 0" /etc/pamac.conf

    if [[ ${gnome} -eq 1 ]]; then
        echo -e "Installing some gnome stuffs from chaotic-aur"
        ! command_exists flatpak && install "extension-manager"
        if [[ $TERMINAL_TO_INSTALL != none ]]; then
            install "nautilus-open-any-terminal"
            gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal $TERMINAL_TO_INSTALL
        fi
    fi
}

setup_gtk() {
    install "$GTK_PACKAGES_TO_INSTALL"
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gtk.Settings.FileChooser show-hidden true
    gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
    gsettings set org.gtk.Settings.FileChooser sort-directories-first true
    gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true

    mkdir -p ~/.config/gtk-{3,4}.0
    #echo >~/.gtkrc-2.0
    echo -e "[Settings]" >~/.config/gtk-3.0/settings.ini && echo -e "#gtk-application-prefer-dark-theme=1" >>~/.config/gtk-3.0/settings.ini
    cp -f ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/
    echo -e "gtk-hint-font-metrics=1" >>~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.local/share/gtksourceview-{3.0,4,5}/styles
    curl -o ~/.local/share/gtksourceview-3.0/styles/catppuccin-mocha.xml https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
    for i in ~/.local/share/gtksourceview-{4,5}/styles; do
        cp -s -f ~/.local/share/gtksourceview-3.0/styles/catppuccin-mocha.xml "$i"
    done

    echo -e "Setting up QT apps to look like GTK.."
    mkdir -p ~/.config/Kvantum ~/.config/qt{5,6}ct
    curl -o ~/.config/Kvantum/kvantum.kvconfig ${baseRepoUrl}home/.config/Kvantum/kvantum.kvconfig
    for i in 5 6; do
        curl -o ~/.config/qt${i}ct/qt${i}ct.conf ${baseRepoUrl}home/.config/qt${i}ct/qt${i}ct.conf
    done

}

setup_gnome() {
    echo -e "Configuring gnome stuffs..."
    install "$GNOME_PACKAGES_TO_INSTALL"

    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
    gsettings set org.gnome.desktop.wm.preferences audible-bell false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    gsettings set org.gnome.system.location enabled true
    gsettings set org.gnome.desktop.privacy old-files-age 0
    gsettings set org.gnome.desktop.privacy recent-files-max-age 1
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.privacy remember-app-usage false
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
    gsettings set org.gnome.desktop.privacy report-technical-problems false
    gsettings set org.gnome.desktop.privacy send-software-usage-stats false
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.search-providers disable-external true
    gsettings set org.gnome.desktop.sound event-sounds false
    gsettings set org.gnome.desktop.thumbnailers disable-all true
    gsettings set org.gnome.desktop.peripherals.mouse speed 1
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/archlinux/gritty.png'
    gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/archlinux/gritty.png'
    gsettings set org.gnome.desktop.background primary-color '#000000000000'
    gsettings set org.gnome.desktop.background secondary-color '#000000000000'
    gsettings set org.gnome.software screenshot-cache-age-maximum 60
    gsettings set org.gnome.gnome-system-monitor show-dependencies true
    gsettings set org.gnome.shell.weather automatic-location true
    gsettings set org.gnome.tweaks show-extensions-notice false

    gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Console.desktop', 'Alacritty.desktop', 'kitty.desktop', 'org.wezfurlong.wezterm.desktop', 'firefox.desktop']"
    # organize in app folder
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/zzz/ name 'zzz'
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/zzz/ apps "['bssh.desktop', 'bvnc.desktop', 'avahi-discover.desktop', 'htop.desktop', 'yad-icon-browser.desktop', 'kvantummanager.desktop', 'nvim.desktop', 'qv4l2.desktop', 'qvidcap.desktop', 'qt5ct.desktop', 'qt6ct.desktop', 'reflector-simple.desktop', 'stoken-gui.desktop', 'stoken-gui-small.desktop', 'uxterm.desktop', 'vim.desktop', 'xterm.desktop', 'yad-settings.desktop']"
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/eos/ name 'eos'
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/eos/ apps "['eos-apps-info.desktop', 'eos-log-tool.desktop', 'eos-quickstart.desktop', 'eos-update.desktop', 'welcome.desktop']"
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/stuffs/ name 'Stuffs'
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/stuffs/ apps "['org.manjaro.pamac.manager.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Contacts.desktop', 'com.mattjakeman.ExtensionManager.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.Meld.desktop', 'gnome-nettool.desktop', 'org.gnome.PowerStats.desktop', 'org.pulseaudio.pavucontrol.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Software.desktop', 'org.gnome.SystemMonitor.desktop', 'vlc.desktop']"
    gsettings set org.gnome.desktop.app-folders folder-children "['eos','stuffs','Utilities','zzz']"

    # GDM
    #sudo mkdir -p /etc/dconf/db/gdm.d
    #curl -o 95-gdm-settings ${baseRepoUrl}system/etc/dconf/db/gdm.d/95-gdm-settings
    #sudo mv -i 95-gdm-settings /etc/dconf/db/gdm.d/

    # console
    gsettings set org.gnome.Console audible-bell false
    gsettings set org.gnome.Console custom-font 'JetBrains Mono 12'
    # Below is to avoid updating font during setup as font starts looking bad
    [[ "$TERM_PROGRAM" != kgx ]] && gsettings set org.gnome.Console use-system-font false

    # text editor
    gsettings set org.gnome.TextEditor restore-session false
    gsettings set org.gnome.TextEditor custom-font 'JetBrains Mono 12'
    gsettings set org.gnome.TextEditor use-system-font false
    gsettings set org.gnome.TextEditor show-line-numbers true
    gsettings set org.gnome.TextEditor style-scheme catppuccin_mocha

    # files
    gsettings set org.gnome.nautilus.preferences show-image-thumbnails never
    gsettings set org.gnome.nautilus.preferences show-directory-item-counts never
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.preferences show-create-link true
    gsettings set org.gnome.nautilus.preferences show-delete-permanently true
    #gsettings set org.gnome.nautilus.preferences sort-directories-first true

    echo -e "Installing some extensions..."
    command_exists flatpak && flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes
    pipx ensurepath
    pipx install gnome-extensions-cli --system-site-packages
    ~/.local/bin/gnome-extensions-cli install AlphabeticalAppGrid@stuarthayhurst appindicatorsupport@rgcjonas.gmail.com dash-to-dock@micxgx.gmail.com clipboard-indicator@tudmotu.com arch-update@RaphaelRochet
    ~/.local/bin/gnome-extensions-cli enable apps-menu@gnome-shell-extensions.gcampax.github.com

    # dash to dock
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock apply-custom-theme true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock click-action minimize
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock hot-keys false

    # arch update
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/arch-update@RaphaelRochet/schemas/ set org.gnome.shell.extensions.arch-update always-visible false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/arch-update@RaphaelRochet/schemas/ set org.gnome.shell.extensions.arch-update check-cmd '/usr/bin/checkupdates'
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/arch-update@RaphaelRochet/schemas/ set org.gnome.shell.extensions.arch-update update-cmd 'kgx -e '\''/bin/sh -c "sudo pacman -Syu ; echo Done - Press enter to exit; read _" '\'''
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/arch-update@RaphaelRochet/schemas/ set org.gnome.shell.extensions.arch-update use-buildin-icons true

    # clipboard indicator
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com/schemas/ set org.gnome.shell.extensions.clipboard-indicator cache-size 1
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com/schemas/ set org.gnome.shell.extensions.clipboard-indicator clear-on-boot true
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com/schemas/ set org.gnome.shell.extensions.clipboard-indicator enable-keybindings false
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com/schemas/ set org.gnome.shell.extensions.clipboard-indicator history-size 10

}

setup_apps() {
    echo -e "Installing some apps..."
    install "$APP_PACKAGES_TO_INSTALL"
    echo -e "Installing some dev stuffs..."
    install "$DEV_PACKAGES_TO_INSTALL"

    # misc
    flagstocopy=(code electron) # (chromium chrome microsoft-edge-stable)
    for i in "${flagstocopy[@]}"; do
        curl -o ~/.config/"${i}"-flags.conf ${baseRepoUrl}home/.config/"${i}"-flags.conf
    done

    # meld
    gsettings set org.gnome.meld prefer-dark-theme true
    gsettings set org.gnome.meld show-line-numbers true
    gsettings set org.gnome.meld style-scheme catppuccin_mocha
    gsettings set org.gnome.meld highlight-syntax true

    # vlc
    mkdir -p ~/.config/vlc
    curl -o ~/.config/vlc/vlcrc ${baseRepoUrl}home/.config/vlc/vlcrc

    echo -e "Setting up keyring..."
    mkdir -p ~/.local/share/keyrings/
    curl -o ~/.local/share/keyrings/Default_keyring.keyring ${baseRepoUrl}home/.local/share/keyrings/Default_keyring.keyring
    curl -o ~/.local/share/keyrings/default ${baseRepoUrl}home/.local/share/keyrings/default
    chmod og= ~/.local/share/keyrings/
    chmod og= ~/.local/share/keyrings/Default_keyring.keyring

    echo -e "Setting up file associations..."
    curl -o ~/.config/mimeapps.list ${baseRepoUrl}home/.config/mimeapps.list
    sed -i "s/DEFAULT_TEXT_EDITOR/$GUI_TEXT_EDITOR/g" ~/.config/mimeapps.list
    mkdir -p ~/.local/share/applications
    ln -s ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list

    echo -e "Removing not needed apps..."
    uninstall "$PACKAGES_TO_REMOVE"
}

refresh_package_sources

echo -e "Installing some needed stuffs..."
install "$REQUIREMENTS"

setup_system
improve_font
configure_terminal
setup_gtk
[[ ${gnome} == 1 ]] && setup_gnome
setup_apps
command_exists pacman && setup_pacman

echo -e ""
read -rp "After next step, terminal font may look messed up, but will be fine after restart. Press any key to continue..."
[[ "$TERM_PROGRAM" == kgx ]] && gsettings set org.gnome.Console use-system-font false

echo -e "Done...Reboot..."

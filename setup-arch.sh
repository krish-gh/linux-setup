#!/bin/bash

# Check if the distro is (based on) Arch Linux
isArch="$(
    command -v pacman >/dev/null 2>&1
    echo $?
)"

if [ "${isArch}" -ne 0 ]; then
    echo "You do not run an Arch-based Linux distrbution ..."
    exit 1
fi

unset isArch

baseRepoUrl="https://raw.githubusercontent.com/krish-gh/linux-setup/main/"

vmware=1
vbox=0
hyperv=0
gnome=1
chaoticaur=1

setup_vm() {
    if [ ${vmware} -eq 1 ]; then
        echo -e "Configuring VMware stuffs..."
        sudo pacman -Sy --noconfirm --needed xf86-video-vmware xf86-input-vmmouse gtkmm gtkmm3 open-vm-tools
        sudo systemctl enable --now vmtoolsd.service
        sudo systemctl enable --now vmware-vmblock-fuse.service
    fi

    if [ ${vbox} -eq 1 ]; then
        echo -e "Configuring VirtualBox stuffs..."
        sudo pacman -Sy --noconfirm --needed virtualbox-guest-utils
        sudo systemctl enable --now vboxservice.service
    fi

    if [ ${hyperv} -eq 1 ]; then
        echo -e "Configuring Hyper-V stuffs..."
        sudo pacman -Sy --noconfirm --needed hyperv
        sudo systemctl enable --now hv_fcopy_daemon.service
        sudo systemctl enable --now hv_kvp_daemon.service
        sudo systemctl enable --now hv_vss_daemon.service

    fi

    sudo pacman -Sy --noconfirm --needed vulkan-mesa-layers vulkan-swrast
}

tweak_system() {
    echo -e "Tweaking some system stuffs..."
    sudo mkdir -p /etc/sysctl.d /etc/systemd/journald.conf.d
    curl -o 99-sysctl.conf ${baseRepoUrl}system/etc/sysctl.d/99-sysctl.conf
    sudo mv -f 99-sysctl.conf /etc/sysctl.d/
    curl -o 00-journal-size.conf ${baseRepoUrl}system/etc/systemd/journald.conf.d/00-journal-size.conf
    sudo mv -f 00-journal-size.conf /etc/systemd/journald.conf.d/
    sudo journalctl --rotate --vacuum-size=10M
}

improve_font() {
    echo -e "Installing fonts..."
    sudo pacman -Sy --noconfirm --needed noto-fonts noto-fonts-emoji ttf-liberation ttf-dejavu ttf-roboto ttf-ubuntu-font-family
    echo -e "Making font look better..."
    mkdir -p ~/.config/fontconfig/conf.d
    curl -o ~/.config/fontconfig/fonts.conf ${baseRepoUrl}home/.config/fontconfig/fonts.conf
    curl -o ~/.config/fontconfig/conf.d/20-no-embedded.conf ${baseRepoUrl}home/.config/fontconfig/conf.d/20-no-embedded.conf
    curl -o .Xresources ${baseRepoUrl}.Xresources
    sudo pacman -Sy --noconfirm --needed xorg-xrdb
    xrdb -merge ~/.Xresources
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
    sudo sed -i '/export FREETYPE_PROPERTIES=/s/^#//g' /etc/profile.d/freetype2.sh
    gsettings set org.gnome.desktop.interface font-antialiasing rgba
    gsettings set org.gnome.desktop.interface font-hinting slight
    sudo fc-cache -fv
    fc-cache -fv
}

configure_bash() {
    echo -e "Configuring bash..."
    sudo pacman -Sy --noconfirm --needed ttf-jetbrains-mono-nerd starship
    curl -o ~/.aliases ${baseRepoUrl}home/arch/.aliases
    bashrcAppend="$(
        grep ".aliases" ~/.bashrc >/dev/null 2>&1
        echo $?
    )"
    if [ "${bashrcAppend}" -ne 0 ]; then
        curl ${baseRepoUrl}home/.bashrc >>~/.bashrc
    fi
    starship preset no-nerd-font -o ~/.config/starship.toml
    source ~/.bashrc
}

pacman_configure_chaotic_aur() {
    if [ "$(find /etc/pacman.d/ -name chaotic-mirrorlist)" == "" ]; then
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
    if [ "${chaoticAurAppend}" -ne 0 ]; then
        echo "Appending Chaotic-AUR in pacman.conf..."
        echo -e "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
        echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    fi

    sudo pacman -Syyu
    sudo pacman -Fy

    echo -e "Installing some more needed stuffs..."
    sudo pacman -Sy --noconfirm --needed yay rate-mirrors
}

setup_gtk() {
    sudo pacman -Sy --noconfirm --needed kvantum-qt5 qt5-wayland qt5ct qt6ct
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.3
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gtk.Settings.FileChooser show-hidden true
    gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
    mkdir -p ~/.config/gtk-{3,4}.0
    echo >~/.gtkrc-2.0
    echo -e "[Settings]" >~/.config/gtk-3.0/settings.ini && echo -e "gtk-application-prefer-dark-theme=1" >>~/.config/gtk-3.0/settings.ini
    echo -e "[Settings]" >~/.config/gtk-4.0/settings.ini && echo -e "gtk-hint-font-metrics=1" >>~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.local/share/gtksourceview-{4,5}/styles
    curl -o ~/.local/share/gtksourceview-4/styles/catppuccin-mocha.xml https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
    curl -o ~/.local/share/gtksourceview-5/styles/catppuccin-mocha.xml https://raw.githubusercontent.com/catppuccin/gedit/main/themes/catppuccin-mocha.xml
}

setup_gnome() {
    echo -e "Configuring gnome stuffs..."
    sudo pacman -Rns --noconfirm snapshot gnome-calculator gnome-clocks gnome-connections gnome-contacts gnome-disk-utility baobab simple-scan gnome-maps gnome-music gnome-tour totem gnome-weather epiphany gnome-user-docs yelp
    sudo pacman -Sy --noconfirm --needed gnome-themes-extra gnome-tweaks vlc python-pipx
    
    gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
    
    # console
    gsettings set org.gnome.Console audible-bell false
    gsettings set org.gnome.Console custom-font 'JetBrainsMono Nerd Font 12'
    gsettings set org.gnome.Console use-system-font false

    # text editor
    gsettings set org.gnome.TextEditor restore-session false
    gsettings set org.gnome.TextEditor custom-font 'JetBrainsMono Nerd Font 12'
    gsettings set org.gnome.TextEditor use-system-font false
    gsettings set org.gnome.TextEditor show-line-numbers true
    gsettings set org.gnome.TextEditor style-scheme catppuccin_mocha

    # files
    gsettings set org.gnome.nautilus.preferences show-image-thumbnails never
    gsettings set org.gnome.nautilus.preferences show-directory-item-counts never
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    gsettings set org.gnome.nautilus.preferences show-create-link true
    gsettings set org.gnome.nautilus.preferences show-delete-permanently true


    
    if [ ${chaoticaur} -eq 1 ]; then
        sudo pacman -Sy --noconfirm --needed extension-manager
    fi

    echo -e "Installing some extensions..."
    pipx ensurepath
    pipx install gnome-extensions-cli --system-site-packages
    ~/.local/bin/gnome-extensions-cli install AlphabeticalAppGrid@stuarthayhurst appindicatorsupport@rgcjonas.gmail.com dash-to-dock@micxgx.gmail.com
}

sudo pacman -Syyu
setup_vm
tweak_system

improve_font

echo -e "Installing some needed stuffs..."
sudo pacman -Sy --noconfirm --needed pacman-contrib meld firefox base-devel nano git github-cli curl seahorse

if [ ${chaoticaur} -eq 1 ]; then
    pacman_configure_chaotic_aur
fi

echo -e "Doing some cool stuffs in /etc/pacman.conf ..."
sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

configure_bash
setup_gtk

if [ ${gnome} -eq 1 ]; then
    setup_gnome
fi

mkdir -p ~/.config/environment.d
curl -o ~/.config/environment.d/10-defaults.conf ${baseRepoUrl}home/.config/environment.d/10-defaults.conf

curl -o ~/.config/chromium-flags.conf ${baseRepoUrl}home/.config/chromium-flags.conf
curl -o ~/.config/chrome-flags.conf ${baseRepoUrl}home/.config/chrome-flags.conf
curl -o ~/.config/code-flags.conf ${baseRepoUrl}home/.config/code-flags.conf
curl -o ~/.config/electron-flags.conf ${baseRepoUrl}home/.config/electron-flags.conf

sudoAppend="$(
    grep "Defaults:krish      !authenticate" /etc/sudoers >/dev/null 2>&1
    echo $?
)"
if [ "${sudoAppend}" -ne 0 ]; then
    echo -e "Defaults:krish      !authenticate" | sudo tee -a /etc/sudoers
fi

echo -e "Done...Reboot..."

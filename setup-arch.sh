


echo -e "Installing fonts..."
sudo pacman -Sy --needed noto-fonts noto-fonts-emoji ttf-liberation ttf-dejavu ttf-roboto ttf-ubuntu-font-family ttf-jetbrains-mono-nerd

echo -e "Installing some needed stuffs..."
sudo pacman -Sy --needed pacman-contrib firefox base-devel git


pacman-configure-chaotic-aur

echo -e "Doing some cool stuffs in /etc/pacman.conf ..."
sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

sudo pacman -Syyu
sudo pacman -Fy

echo -e "Installing some more needed stuffs..."
sudo pacman -Sy --needed yay rate-mirrors

pacman-configure-chaotic-aur()
{
    if [ ! -f /etc/pacman.d/chaotic-mirrorlist ]
    then
        echo -e "Configuring Chaotic-AUR - https://aur.chaotic.cx/docs..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -Uy 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -Uy 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    fi

    if ! grep --quiet -x '\[chaotic-aur\]' '/etc/pacman.conf'
    then
        sudo echo -e "#Chaotic-AUR" >> /etc/pacman.conf
        sudo echo -e "" >> /etc/pacman.conf
        sudo echo -e "[chaotic-aur]" >> /etc/pacman.conf
        sudo echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
    fi
}


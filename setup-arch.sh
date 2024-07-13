
pacman-configure-chaotic-aur

echo -e "Updating /etc/pacman.conf ..."
sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

sudo pacman -Syyu
sudo pacman -Fy


echo -e "Installing fonts..."
sudo pacman -Sy noto-fonts noto-fonts-emoji ttf-liberation ttf-dejavu ttf-roboto

pacman-configure-chaotic-aur()
{
    if [ ! -f /etc/pacman.d/chaotic-mirrorlist ]
    then
        echo -e "Configuring Chaotic-AUR - https://aur.chaotic.cx/docs..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'


        if ! grep --quiet -x '\[chaotic-aur\]' '/etc/pacman.conf' && grep --quiet -x 'Include = /etc/pacman.d/chaotic-mirrorlist' '/etc/pacman.conf'
        then
            sudo echo -e "#Chaotic-AUR" >> /etc/pacman.conf
            sudo echo -e "" >> /etc/pacman.conf
            sudo echo -e "[chaotic-aur]" >> /etc/pacman.conf
            sudo echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
        fi
    fi
}


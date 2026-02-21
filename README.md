# Post installation setup for desktop linux

Automated post-installation setup script for Linux desktop environments. This project automates system configuration, package installation, debloating, and desktop environment setup across multiple Linux distributions and desktop environments.

## Supported scenario

> **_NOTE:_** KDE's config system is all over the places and many things are only possible from UI. So, I could automate only few things. That's one of the reasons I don't like KDE.

| Distrution Type | Specific                | Desktop Environment        |
| --------------- | ----------------------- | -------------------------- |
| Arch            | Arch                    | Gnome, KDE, Cinnamon, XFCE |
|                 | EndeavourOS             | Gnome, KDE, Cinnamon       |
| Debian          | Debian                  | Gnome, XFCE                |
|                 | Ubuntu                  | Gnome                      |
|                 | Mint                    | Cinnamon, XFCE             |
|                 | LMDE                    | Cinnamon                   |
| Fedora          | Fedora (Non-Silverblue) | Gnome, KDE, Cinnamon, XFCE |
| OpenSUSE        | Tumbleweed, Leap        | Gnome, KDE, Cinnamon, XFCE |

## Project Structure

### `/debloat`
Contains lists of packages to uninstall for each distribution to reduce bloat:
- `arch.txt` - Packages to remove from Arch-based systems
- `debian.txt` - Packages to remove from Debian-based systems
- `fedora.txt` - Packages to remove from Fedora
- `opensuse.txt` - Packages to remove from OpenSUSE

### `/desktop`
Desktop environment configuration scripts and dconf settings:
- `gnome.sh` - GNOME setup and configuration
- `gnome.dconf` - GNOME dconf database settings
- `kde.sh` - KDE Plasma setup and configuration
- `cinnamon.sh` - Cinnamon setup and configuration
- `cinnamon.dconf` - Cinnamon dconf database settings
- `xfce.sh` - XFCE setup and configuration
- `xfce.dconf` - XFCE dconf database settings
- `gterm.dconf` - GNOME Terminal dconf settings
- `common.dconf` - Common dconf settings across all DEs

### `/distros`
Distribution-specific setup scripts and shell aliases:
- `arch.sh` - Arch Linux package configuration and installation lists
- `arch.aliases` - Arch-specific shell aliases
- `debian.sh` - Debian/Ubuntu package configuration and installation lists
- `debian.aliases` - Debian-specific shell aliases
- `fedora.sh` - Fedora package configuration and installation lists
- `fedora.aliases` - Fedora-specific shell aliases
- `opensuse.sh` - OpenSUSE package configuration and installation lists
- `opensuse.aliases` - OpenSUSE-specific shell aliases

### `/home`
Home directory configuration files:
- `.bashrc` - Bash shell configuration
- `.profile` - Shell profile configuration
- `.xinitrc` - X11 initialization script
- `.xprofile` - X11 profile configuration
- `.xsessionrc` - X11 session configuration
- `.Xresources` - X11 resource configuration
- `.config/` - User configuration directory
- `.local/` - User local data directory

### `/scripts`
Main setup automation scripts:
- `setup-main.sh` - Primary setup script handling distribution/DE detection and orchestration
- `setup-guide.sh` - Quick reference guide with usage examples

### `/specific`
Distro-specific setup scripts and configurations:
- `arch.sh` - Arch-specific setup
- `debian.sh` - Debian-specific setup
- `ubuntu.sh` - Ubuntu-specific setup
- `linuxmint.sh` - Linux Mint-specific setup
- `linuxmint.dconf` - Linux Mint dconf settings
- `neon.sh` - KDE Neon-specific setup

### `/system`
System-level configuration files:
- `etc/dconf/db/gdm.d/95-gdm-settings` - GDM (GNOME Display Manager) settings
- `etc/sysctl.d/999-sysctl.conf` - Kernel and system parameters configuration
- `etc/systemd/journald.conf.d/00-journal-size.conf` - Systemd journal configuration
- `etc/systemd/coredump.conf.d/custom.conf` - Core dump configuration

## How

### Option #1
Run without cloning this repo. It downloads required files when required.

```
curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/setup.sh | bash
```

### Option #2
Run by cloning this repo. It uses files from clone path.

```
git clone https://github.com/krish-gh/linux-setup.git &&
. linux-setup/setup.sh &&
rm -rf linux-setup
```

# Post installation setup for desktop linux

Automated post-installation setup script for Linux desktop environments. This project automates system configuration, package installation, debloating, and desktop environment setup across multiple Linux distributions and desktop environments.

## Features

- **Automatic Distro Detection**: Detects your Linux distribution and desktop environment automatically
- **Debloating**: Removes unnecessary pre-installed packages to reduce system bloat
- **Package Management**: Installs essential system, development, and application packages
- **Shell Configuration**: Sets up Bash with aliases, Starship prompt, and syntax highlighting for Nano
- **Font Setup**: Installs and configures fonts including Nerd Fonts for terminal use
- **Terminal Emulator Setup**: Configures Alacritty, Kitty, WezTerm, or GNOME Terminal with themes
- **Desktop Environment Configuration**: Applies dconf settings for GNOME, KDE, Cinnamon, and XFCE
- **Home Directory Setup**: Configures user home files (.bashrc, .profile, .xresources, etc.)
- **Security**: Sets up keyring, sudo configuration, and autologin capabilities
- **Hardware Support**: Installs drivers for Intel, VMware, VirtualBox, Hyper-V, and QEMU
- **System Customization**: Applies kernel parameters, journald, and core dump configurations

## Code Quality & Best Practices

This project emphasizes reliability and security:

- **Error Handling**: Comprehensive error checking on all critical operations with clear diagnostics
- **Secure Temp Files**: Uses `mktemp` for secure temporary directories with automatic cleanup via trap handlers
- **Safe Quoting**: Proper variable quoting throughout to prevent word splitting and glob expansion
- **Portable**: Uses `printf` instead of `echo -e` for better portability across shell implementations
- **Fail-Safe**: Non-critical failures don't halt the entire setup—the script continues gracefully
- **No eval**: Avoids dangerous `eval` for remote script execution; uses safe alternatives instead
- **Validation**: All shell scripts are POSIX sh-compatible and pass strict syntax validation with `sh -n`

## Prerequisites

- A supported Linux distribution (see [Supported Scenarios](#supported-scenario))
- Sudo access for system-level configuration
- Internet connection to download packages and resources
- `curl` command-line tool (required)

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

### Main Scripts

- [setup.sh](setup.sh) - Entry point that detects whether running local or remote and executes `setup-main.sh`
- [scripts/setup-main.sh](scripts/setup-main.sh) - Primary orchestration script that handles:
  - Distribution and desktop environment detection
  - Variable initialization for package managers
  - Package installation and system configuration
  - Home directory and dconf setup
- [scripts/setup-guide.sh](scripts/setup-guide.sh) - Quick reference and example usage

### `/debloat`
Contains lists of packages to uninstall for each distribution to reduce bloat:
- `arch.txt` - Packages to remove from Arch-based systems
- `debian.txt` - Packages to remove from Debian-based systems
- `fedora.txt` - Packages to remove from Fedora
- `opensuse.txt` - Packages to remove from OpenSUSE

### `/desktop`
Desktop environment configuration scripts and dconf boolean settings:
- `gnome.sh` - GNOME setup: installs tweaks, extensions, applies dconf settings
- `gnome.dconf` - GNOME dconf database settings (schemas, keybindings, appearance)
- `kde.sh` - KDE Plasma setup and limited configuration (KDE is mostly UI-driven)
- `cinnamon.sh` - Cinnamon setup: installs packages, applies themes
- `cinnamon.dconf` - Cinnamon dconf settings (panel, themes, animations)
- `xfce.sh` - XFCE setup: installs packages, configures panels and themes
- `xfce.dconf` - XFCE dconf settings (panel layout, window manager behavior)
- `gterm.dconf` - GNOME Terminal color scheme and appearance settings
- `common.dconf` - Shared dconf settings applied across all desktop environments

### `/distros`
Distribution-specific setup and package lists. Each distro has:

**Arch-based systems:**
- `arch.sh` - Package manager commands and package lists for Arch (pacman)
- `arch.aliases` - Useful shell aliases for Arch (pacman, yay, etc.)

**Debian-based systems:**
- `debian.sh` - Package manager commands and package lists for Debian/Ubuntu (apt)
- `debian.aliases` - Useful shell aliases for Debian systems

**Fedora:**
- `fedora.sh` - Package manager commands and package lists for Fedora (dnf)
- `fedora.aliases` - Useful shell aliases for Fedora (dnf, rpm, etc.)

**OpenSUSE:**
- `opensuse.sh` - Package manager commands and package lists for OpenSUSE (zypper)
- `opensuse.aliases` - Useful shell aliases for OpenSUSE

### `/home`
User home directory configuration files and templates:
- `.bashrc` - Bash initialization (custom functions, sourcing from .aliases)
- `.profile` - Shell login profile environment setup
- `.xinitrc` - X11 initialization (for startx)
- `.xprofile` - X11 session startup profile
- `.xsessionrc` - X11 session configuration
- `.Xresources` - X11 resource database (font DPI, colors, etc.)
- `.config/` - Desktop environment and application configs
- `.local/` - User-local binaries and data files
- `.config/fontconfig/fonts.conf` - Font rendering configuration
- `.config/nano/nanorc` - Nano editor configuration
- `.config/alacritty/alacritty.toml` - Alacritty terminal emulator config
- `.config/kitty/kitty.conf` - Kitty terminal emulator config
- `.local/share/keyrings/` - GNOME Keyring files

### `/specific`
Fine-grained, distro-version specific configurations:
- `arch.sh` - Arch-specific setup hooks
- `debian.sh` - Debian-specific setup hooks
- `ubuntu.sh` - Ubuntu-specific setup hooks
- `linuxmint.sh` - Linux Mint-specific setup hooks
- `linuxmint.dconf` - Linux Mint dconf settings
- `neon.sh` - KDE Neon-specific setup hooks

### `/system`
System-level configuration files (require sudo):

**Kernel and System Parameters:**
- `etc/sysctl.d/999-sysctl.conf` - Kernel parameters (network, memory, security)

**Systemd Services:**
- `etc/systemd/journald.conf.d/00-journal-size.conf` - Journal size and retention policy
- `etc/systemd/coredump.conf.d/custom.conf` - Core dump handling configuration

**Display Manager:**
- `etc/dconf/db/gdm.d/95-gdm-settings` - GNOME Display Manager (GDM) login screen settings

## Customization

### Modifying Package Lists

To customize which packages are installed/removed:

1. **For your specific distribution**, edit `/distros/{arch,debian,fedora,opensuse}.sh`:
   - Modify `*_PACKAGES_TO_INSTALL` variables to add/remove packages
   - Update `UNINSTALL_CMD` options for removal behavior

2. **For debloating**, edit `/debloat/{arch,debian,fedora,opensuse}.txt`:
   - Add or remove one package name per line
   - Comment out lines starting with `#` to skip removal

3. **For your specific distro version**, edit `/specific/{arch,debian,ubuntu,linuxmint,neon}.sh`:
   - Add distro-specific hooks and configurations
   - Override variables from `/distros` scripts if needed

### Customizing Desktop Environment Settings

Edit the relevant dconf file in `/desktop/`:
- **GNOME**: Modify `gnome.dconf` (keybindings, schema settings, appearance)
- **XFCE**: Modify `xfce.dconf` (panel, window manager, workspace)
- **Cinnamon**: Modify `cinnamon.dconf` (animations, themes, effects)
- **Common**: Modify `common.dconf` (settings applied to all DEs)

DConf files use a simple key=value format. See [DConf documentation](https://wiki.gnome.org/Projects/dconf) for details.

### Terminal Emulator Configuration

Configure terminal theme and appearance:

- **Alacritty** (`.config/alacritty/alacritty.toml`): Edit for font, colors, padding
- **Kitty** (`.config/kitty/kitty.conf`): Edit for font, opacity, keybindings  
- **WezTerm** (`.config/wezterm/wezterm.lua`): Configure with Lua scripting

Themes are downloaded from upstream projects (Catppuccin by default).

### Shell Aliases and Functions

Customize `/distros/{distro}.aliases` to add your own shell aliases sourced at login.

## Logging and Debugging

The setup script creates a log file in your home directory for each run:
```
~/setup-2026-02-21-14:30:45.log
```

View the log:
```bash
cat ~/setup-*.log
tail -f ~/setup-*.log  # Follow in real-time
```

**Error Handling**: The script logs warnings for non-critical failures and continues execution. Check the log file to see if any operations failed. The setup log is timestamped so you can keep history of multiple runs.

## Notes and Limitations

- **KDE Plasma**: KDE's configuration system is complex and mostly UI-driven. The automation covers basic packages and themes only. Manual configuration of many settings is still required.
- **GDM Configuration**: Commented out in the main setup—uncomment `/desktop/gnome.sh` if you need to customize the login screen.
- **Wayland/Xorg**: The script detects your current session; some settings may not apply if switching between Wayland and Xorg.
- **Error Recovery**: Some operations may fail gracefully (logged as warnings) and continue; check the setup log for details.
- **Package Availability**: Not all packages may be available in every distribution version; installation failures are logged but don't halt the setup.

## Requirements

- **Supported Distributions**: Arch, Debian, Fedora, OpenSUSE (and their derivatives)
- **Sudo Access**: Required for system-level configuration
- **Internet Connection**: Needed for downloading packages and resources
- **curl**: Required for downloading remote files
- **jq**: JSON parser (installed during setup if not present)

## License

This project is provided as-is for personal use and customization.

## Installation

### Quick Start - Option #1 (Remote)
Run without cloning this repo. It downloads required files when needed:

```sh
curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/setup.sh | sh
```

### Option #2 (Local Clone)
Clone the repo first and run from local files:

```sh
git clone https://github.com/krish-gh/linux-setup.git &&
. linux-setup/setup.sh &&
rm -rf linux-setup
```

The script will:
1. Detect your distribution and desktop environment
2. Display detected configuration
3. Ask for confirmation before making any changes
4. Create a timestamped log file at `~/setup-YYYY-MM-DD-HH:MM:SS.log`

## Setup Overview

The setup process is orchestrated by `setup-main.sh` which performs the following in order:

1. **Detection Phase**: Identifies Linux distribution, package manager, and desktop environment
2. **System Update**: Refreshes package sources and updates the system
3. **Debloating**: Removes unnecessary pre-installed packages from `/debloat` directory
4. **Package Installation**: Installs software in categories:
   - System packages (firmware, ALSA, power management)
   - Hardware drivers (Intel, VMware, VirtualBox, etc.)
   - Fonts and rendering improvements
   - Terminal utilities (Shellcheck, Starship, Fastfetch)
   - Applications (Firefox, VLC, Seahorse, etc.)
   - Development tools (Git, Python, Visual Studio Code, etc.)
   - DE-specific packages and themes
5. **Shell Configuration**: Sets up Bash completion, aliases, and Starship prompt
6. **Font Installation**: Configures fonts with proper hinting and installs Nerd Fonts
7. **Terminal Emulator**: Sets up terminal configuration with color themes
8. **Home Directory**: Copies configuration files and sets up keyring
9. **Desktop Environment**: Applies aesthetic and behavior settings via dconf
10. **System Configuration**: Sets kernel parameters, journald logging, and core dumps
11. **Permissions**: Configures sudo rules and autologin group membership

## Configuration Files

### Distribution-Specific Variables

Each distro script (in `/distros`) defines package managers and package lists:
- Package manager commands (install, remove, update)
- System packages by category
- Hardware-specific drivers
- Application packages
- Development packages
- Desktop environment packages

### Desktop Environment Settings

DConf files (in `/desktop`) store graphical settings for:
- **GNOME**: Window manager, keyboard shortcuts, color scheme
- **Cinnamon**: Panel layout, themes, animations
- **XFCE**: Panel configuration, window behavior
- **KDE**: Limited automation (requires manual configuration in many cases)

### Package Removal Lists

Files in `/debloat` contain package names to remove by distribution:
- Games, media players (if pre-installed)
- Extra applications
- Language plugins
- Accessibility tools (if not needed)

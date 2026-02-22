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

- A supported Linux distribution (see [Supported Scenarios](#supported-scenarios))
- Sudo access for system-level configuration
- Internet connection to download packages and resources
- `curl` command-line tool (required)

## Supported Scenarios

> **_NOTE:_** KDE Plasma configuration is complex due to its scattered configuration system. The setup automates package installation and basic theming only; many settings require manual configuration through the System Settings GUI.

| Distribution Type | Specific Variant        | Desktop Environment    |
| --- | --- | --- |
| **Arch-based** | Arch Linux, EndeavourOS | GNOME, KDE, Cinnamon, XFCE |
| **Debian-based** | Debian, Ubuntu, Linux Mint, LMDE | GNOME, Cinnamon, XFCE |
| **Fedora** | Fedora (non-Silverblue) | GNOME, KDE, Cinnamon, XFCE |
| **OpenSUSE** | Tumbleweed, Leap | GNOME, KDE, Cinnamon, XFCE |

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

**Shell & X11:**
- `.bashrc` - Bash initialization with custom functions and aliases
- `.profile` - Shell login profile and environment variables
- `.xinitrc` - X11 initialization for startx
- `.xprofile` - X11 session startup profile
- `.xsessionrc` - X11 session configuration
- `.Xresources` - X11 resource database (font DPI, colors)

**Terminal Emulators:**
- `.config/alacritty/alacritty.toml` - Alacritty terminal configuration and themes
- `.config/kitty/kitty.conf` - Kitty terminal configuration
- `.config/wezterm/wezterm.lua` - WezTerm terminal configuration (Lua-based)

**System & App Configs:**
- `.config/fontconfig/fonts.conf` - Font rendering and hinting configuration
- `.config/nano/nanorc` - Nano editor configuration with syntax highlighting
- `.config/fastfetch/config.jsonc` - System info display configuration
- `.config/mimeapps.list` - Default applications for file types
- `.config/xfce4/` - XFCE-specific panel and window manager settings
- `.config/Kvantum/` - KDE Qt application theming
- `.config/qt5ct/` & `.config/qt6ct/` - Qt5/Qt6 theme configuration
- `.config/vlc/` - VLC media player preferences
- `.config/environment.d/` - User environment variables
- `.config/systemd/` - User systemd service configurations

**Application Flags:**
- `.config/chrome-flags.conf`, `.config/chromium-flags.conf` - Chromium-based browser flags
- `.config/code-flags.conf` - Visual Studio Code startup flags
- `.config/electron-flags.conf` - Electron application flags
- `.config/microsoft-edge-stable-flags.conf` - Microsoft Edge flags

**User Data:**
- `.local/share/keyrings/` - GNOME Keyring files and SSH key storage

### `/specific`
Fine-grained, distro-version specific configurations:
- `arch.sh` - Arch-specific setup hooks
- `debian.sh` - Debian-specific setup hooks
- `ubuntu.sh` - Ubuntu-specific setup hooks
- `linuxmint.sh` - Linux Mint-specific setup hooks
- `linuxmint.dconf` - Linux Mint dconf settings
- `neon.sh` - KDE Neon-specific setup hooks

### `/system`
System-level configuration files for machine-wide settings (require sudo to apply):

**Kernel and Sysctl Parameters:**
- `etc/sysctl.d/999-sysctl.conf` - Kernel tuning (network performance, memory management, security hardening)

**Systemd Services:**
- `etc/systemd/journald.conf.d/00-journal-size.conf` - Journal storage policy and size limits
- `etc/systemd/coredump.conf.d/custom.conf` - Core dump handling and storage configuration

**Display Manager (GNOME GDM):**
- `etc/dconf/db/gdm.d/95-gdm-settings` - Login screen appearance and behavior (currently commented out in main setup)

## Customization

### Modifying Package Lists

To customize which packages are installed/removed:

1. **General distribution packages** - Edit `/distros/{arch,debian,fedora,opensuse}.sh`:
   - Modify category variables like `*_PACKAGES_TO_INSTALL` to add/remove packages
   - Adjust package manager command options in `INSTALL_CMD`, `REMOVE_CMD`, etc.

2. **Debloat lists** - Edit `/debloat/{arch,debian,fedora,opensuse}.txt`:
   - One package name per line to remove during setup
   - Prefix with `#` to comment out and skip removal of specific packages

3. **Version-specific configurations** - Edit `/specific/{arch,debian,ubuntu,linuxmint,neon}.sh`:
   - Add distro-variant hooks before or after main installation
   - Override or append to variables from `/distros` for custom behavior

### Customizing Desktop Environment Settings

Edit the relevant dconf file in `/desktop/`:
- **GNOME**: Modify `gnome.dconf` for keybindings, workspaces, appearance, and extensions
- **XFCE**: Modify `xfce.dconf` for panel layout, window manager behavior, and workspaces
- **Cinnamon**: Modify `cinnamon.dconf` for animations, panel settings, and theme effects
- **KDE**: `kde.sh` handles automatable settings (KDE config is mostly UI-driven)
- **Common**: Modify `common.dconf` for settings applied across all desktop environments
- **GNOME Terminal**: Edit `gterm.dconf` for color schemes and terminal appearance
- **Linux Mint**: Edit `linuxmint.dconf` for Mint-specific settings

DConf files use `key=value` format (one setting per line). See [DConf documentation](https://wiki.gnome.org/Projects/dconf) for schema details and valid value types.

### Terminal Emulator Configuration

Configure your preferred terminal emulator:

- **Alacritty** (`.config/alacritty/alacritty.toml`): TOML format for font, colors, window padding, and opacity
- **Kitty** (`.config/kitty/kitty.conf`): INI format for fonts, keybindings, colors, and transparency
- **WezTerm** (`.config/wezterm/wezterm.lua`): Lua scripting for full terminal customization

Color themes are automatically downloaded from upstream projects (Catppuccin Mocha by default). Customize fonts, enable ligatures, and adjust colors by editing the appropriate config file.

### Shell Aliases and Functions

Distribution-specific aliases are defined in `/distros/{distro}.aliases` and automatically sourced by `.bashrc`. Add your own custom aliases to these files or directly to `.bashrc`.

## Logging and Debugging

**Log File Location:** Each run creates a timestamped log in your home directory:
```bash
ls -la ~/setup-*.log              # List all setup logs
cat ~/setup-*.log                 # View latest log
tail -100 ~/setup-*.log           # View last 100 lines
tail -f ~/setup-*.log             # Follow in real-time (for actively running setup)
```

**Error Handling:** The script:
- Logs all warnings and non-critical failures without stopping the setup
- Continues executing subsequent steps even if some operations fail
- Timestamps logs so you can compare multiple runs and track changes over time
- Check the log file if unexpected behavior occurs or if some packages didn't install

## Notes and Limitations

- **KDE Plasma**: KDE's configuration is mostly UI-driven (`~/.config/kdedefaults/`). Automation handles only packages, themes, and a few key settings. Many customizations require manual configuration through the System Settings GUI.
- **GDM Login Screen**: GNOME Display Manager configuration is intentionally commented out in the main setup. Uncomment the relevant section in `setup-main.sh` if you want to customize the login screen.
- **Wayland vs Xorg**: The script auto-detects your session type. Some settings (especially DE-specific dconf values) may not apply correctly when switching between Wayland and Xorg—re-run the setup after switching.
- **Error Recovery**: Non-critical failures are logged as warnings and don't stop the setup. Check the setup log to identify which operations failed.
- **Package Availability**: Package availability varies across distro versions. Installation failures are logged but ignore; the setup continues with remaining packages.
- **File Conflicts**: If customization files exist before setup, they may be overwritten. Back up important configs in `.config/` before running the setup.

## Requirements

- **Supported Distributions**: Arch, Debian, Fedora, OpenSUSE (and official derivatives)
- **Sudo Access**: Required for system-level package installation and configuration
- **Internet Connection**: Essential for downloading packages, themes, and fonts
- **curl**: Command-line tool for downloading remote scripts and packages
- **jq**: JSON query tool (auto-installed during setup if missing)
- **bash or sh**: POSIX-compatible shell (script is compatible with both)

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

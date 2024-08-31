# Post installation setup for desktop linux

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
|                 | KDE neon                | KDE                        |
| Fedora          | Fedora (Non-Silverblue) | Gnome, KDE, Cinnamon, XFCE |
| OpenSUSE        | Tumbleweed, Leap        | Gnome, KDE, XFCE           |

## How

### Option #1
Run without cloning this repo. Fully remote. It downloads required files when required.

```
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') 
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?"$timestamp")" 2>&1 | tee setup-"$timestamp".log
```

### Option #2
Run by cloning this repo. It uses files from clone path.

```
git clone https://github.com/krish-gh/linux-setup.git
cd linux-setup || exit
timestamp=$(date '+%Y-%m-%d-%H:%M:%S')
chmod +x scripts/setup-main.sh
. scripts/setup-main.sh 2>&1 | tee setup-"$timestamp".log
rm -r linux-setup
```

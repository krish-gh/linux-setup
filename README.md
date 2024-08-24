# Fully automated post installation setup for desktop linux

## Supported scenario

> **_NOTE:_** KDE's config system is all over the places and many things are only possible from UI. So, I could only automate few things. That's one of the reasons I don't like KDE.

| Distrution Type | Specific                | Desktop Environment        |
| --------------- | ----------------------- | -------------------------- |
| Arch            | Arch                    | Gnome, KDE, Cinnamon, XFCE |
|                 | EndeavourOS             | Gnome, KDE, Cinnamon       |
| Debian          | Debian                  | Gnome, XFCE                |
|                 | Ubuntu                  | Gnome                      |
|                 | Mint                    | Cinnamon, XFCE             |
|                 | LMDE                    | Cinnamon                   |
|                 | KDE neon                | KDE                        |
| Fedora          | Fedora (Non-Silverblue) | Gnome, KDE, Cinnamon       |
| OpenSUSE        | Tumbleweed, Leap        | Gnome, KDE                 |

## How

### Option #1
Run without cloning this repo. Fully remote. It downloads required files when required.

`
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$(date +%s))" 2>&1 | tee setup.log
`

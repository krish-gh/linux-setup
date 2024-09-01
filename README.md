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
| OpenSUSE        | Tumbleweed, Leap        | Gnome, KDE, Cinnamon, XFCE |

## How

### Option #1
Run without cloning this repo. It downloads required files when required.

```
curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/setup.sh | sh
```

### Option #2
Run by cloning this repo. It uses files from clone path.

```
git clone https://github.com/krish-gh/linux-setup.git &&
. linux-setup/setup.sh &&
rm -rf linux-setup
```

# Fully automated post installation setup for desktop linux

## Supported scenario

| Distrution Type | Specific                   | Desktop Environment |
| --------------- | -------------------------- | ------------------- |
| Arch            | Arch, EndeavourOS          | Gnome, Cinnamon     |
| Debian          | Debian, Ubuntu, Mint, LMDE | Gnome, Cinnamon     |
| Fedora          | Fedora                     | Gnome               |

## How

### Option #1
Run without cloning this repo. Fully remote. It downloads required files when required.

`
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh)" 2>&1 | tee setup.log
`

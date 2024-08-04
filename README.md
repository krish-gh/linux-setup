# Fully automated post installation setup for desktop linux

## Supported scenario

| Distrution Type | Specific           | Desktop Environment |
| --------------- | ------------------ | ------------------- |
| Arch            | Arch, EndeavourOS  | Gnome, Cinnamon     |
| Debian          | Debian, Mint, LMDE | Gnome, Cinnamon     |

## How

### Option #1
Run without cloning this repo. Fully remote. It downloads required files when required.

`
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$(date +%s))" 2>&1 | tee setup.log
`

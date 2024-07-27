#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo pacman -Syu --noconfirm"
INSTALL_CMD="sudo pacman -S --noconfirm --needed"
UNINSTALL_CMD="sudo pacman -Rns --noconfirm"

declare -A pkgmap

echo -e "Done arch.sh..."
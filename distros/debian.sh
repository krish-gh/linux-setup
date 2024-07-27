#!/bin/bash

# shellcheck disable=SC2034
REFRESH_CMD="sudo apt update && sudo apt full-upgrade -y"
INSTALL_CMD="sudo apt install -y"
UNINSTALL_CMD="sudo apt purge --ignore-missing --auto-remove -y"

declare -A pkgmap
pkgmap[base-devel]="build-essential"

echo -e "Done debian.sh..."
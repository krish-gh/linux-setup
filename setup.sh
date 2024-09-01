#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2128

timestamp=$(date '+%Y-%m-%d-%H:%M:%S')
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
if [[ -d "$scriptDir"/.git && -f "$scriptDir"/scripts/setup-main.sh ]]; then
    echo -e "Running from local clone..."
    . "$scriptDir"/scripts/setup-main.sh 2>&1 | tee ~/setup-"$timestamp".log 
else
    echo -e "Running from remote on the fly..."
    eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?"$timestamp")" 2>&1 | tee ~/setup-"$timestamp".log
fi

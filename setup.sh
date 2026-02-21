#!/bin/bash
set -o pipefail

timestamp=$(date '+%Y-%m-%d-%H:%M:%S')
scriptDir=$(cd -- "$(dirname -- "$0")" && pwd) || { printf 'Error: Failed to determine script directory\n' >&2; exit 1; }

if [ -d "$scriptDir/.git" ] && [ -f "$scriptDir/scripts/setup-main.sh" ]; then
    printf 'Running from local clone...\n'
    . "$scriptDir/scripts/setup-main.sh" 2>&1 | tee ~/setup-"$timestamp".log
else
    printf 'Running from remote sources...\n'
    # Download and execute the main setup script
    if ! curl -fsSL "https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$timestamp" | bash 2>&1 | tee ~/setup-"$timestamp".log; then
        printf 'Error: Failed to download or execute setup script\n' >&2
        exit 1
    fi
fi


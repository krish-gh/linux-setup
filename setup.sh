#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC2128

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
chmod +x "$scriptDir"/scripts/setup-main.sh &&
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') &&
. "$scriptDir"/scripts/setup-main.sh 2>&1 | tee ~/setup-"$timestamp".log 

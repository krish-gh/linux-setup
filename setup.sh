#!/bin/bash
# shellcheck disable=SC2046

## option #1
timestamp=$(date '+%Y-%m-%d-%H:%M:%S')
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?"$timestamp")" 2>&1 | tee setup-"$timestamp".log
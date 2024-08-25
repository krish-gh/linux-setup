#!/bin/bash
# shellcheck disable=SC2046

## option #1
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$(date +%s))" 2>&1 | tee setup-$(date '+%Y-%m-%d-%H:%M:%S').log
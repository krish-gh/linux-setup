#!/bin/bash
# shellcheck disable=SC2046
# shellcheck disable=SC1091
# shellcheck disable=SC2164
# shellcheck disable=SC2103

## option #1
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') &&
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?"$timestamp")" 2>&1 | tee ~/setup-"$timestamp".log

## option #2
git clone https://github.com/krish-gh/linux-setup.git &&
. linux-setup/setup.sh &&
rm -rf linux-setup

#!/bin/bash
# shellcheck disable=SC2046
# shellcheck disable=SC1091
# shellcheck disable=SC2164
# shellcheck disable=SC2103

## option #1
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') &&
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?"$timestamp")" 2>&1 | tee setup-"$timestamp".log

## option #2
current=$PWD &&
git clone https://github.com/krish-gh/linux-setup.git &&
cd linux-setup &&
chmod +x scripts/setup-main.sh &&
timestamp=$(date '+%Y-%m-%d-%H:%M:%S') &&
. scripts/setup-main.sh 2>&1 | tee "$current"/setup-"$timestamp".log &&
cd "$current" &&
rm -rf linux-setup

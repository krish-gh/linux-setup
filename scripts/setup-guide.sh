#!/bin/bash
# shellcheck disable=SC2046
# shellcheck disable=SC1091
# shellcheck disable=SC2164
# shellcheck disable=SC2103

## option #1
curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/setup.sh | sh

## option #2
git clone https://github.com/krish-gh/linux-setup.git &&
. linux-setup/setup.sh &&
rm -rf linux-setup

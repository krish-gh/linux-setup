#!/bin/bash

# shellcheck disable=SC2046
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$(date +%s))" 2>&1 | tee -a setup.log
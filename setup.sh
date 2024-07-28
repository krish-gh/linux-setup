#!/bin/bash

# shellcheck disable=SC2046
eval "$(curl -fsSL https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh?$(date +%s))" | tee -a setup.log
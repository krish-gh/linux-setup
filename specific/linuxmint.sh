#!/bin/bash

# shellcheck disable=SC2035
sudo apt-get purge --ignore-missing --auto-remove -y celluloid hypnotix mintchat *thunderbird* *timeshift* *transmission* warpinator webapp-manager

echo -e "Done linuxmint.sh..."
#!/bin/bash

curl -o setup-main.sh https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-main.sh
chmod +x setup-main.sh
./setup-main.sh | tee setup.log
rm -rf setup-main.sh
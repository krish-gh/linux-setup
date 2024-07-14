#!/bin/bash

wget -nd -np https://raw.githubusercontent.com/krish-gh/linux-setup/main/scripts/setup-arch.sh
chmod +x setup-arch.sh
./setup-arch.sh
rm setup-arch.sh
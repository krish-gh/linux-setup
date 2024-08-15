#!/bin/bash

setup_specific_neon() {
    # just ensuring this meta package was not uninstalled, it will wait for confirmation if it was
    sudo apt-get install neon-desktop neon-essentials-desktop ubuntu-minimal 
}

echo -e "Done neon.sh..."

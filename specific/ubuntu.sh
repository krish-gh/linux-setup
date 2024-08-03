#!/bin/bash

setup_ubuntu() {
    sudo apt-get update
    install_pkgs "ubuntu-restricted-addons ubuntu-restricted-extras"

    echo -e "Done ubuntu..."
}

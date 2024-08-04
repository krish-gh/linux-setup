#!/bin/bash

setup_ubuntu() {
    sudo snap remove firefox
    printf 'Package: * \nPin: origin packages.mozilla.org \nPin-Priority: 1000 \n' | sudo tee /etc/apt/preferences.d/mozilla
    echo -e "Done ubuntu..."
}

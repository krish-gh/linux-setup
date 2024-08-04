#!/bin/bash

setup_ubuntu() {
    echo -e "Replacing snap version of firefox with native one..."
    sudo snap remove firefox
    printf 'Package: * \nPin: origin packages.mozilla.org \nPin-Priority: 1000 \n' | sudo tee /etc/apt/preferences.d/mozilla
    echo -e "Done ubuntu..."
}

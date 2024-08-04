#!/bin/bash

setup_ubuntu() {
    echo -e "Replacing snap version of firefox with native one..."
    
    # mozilla
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
    printf 'Package: * \nPin: origin packages.mozilla.org \nPin-Priority: 1000 \n' | sudo tee /etc/apt/preferences.d/mozilla
    sudo apt-get update && sudo snap remove firefox
    echo -e "Done ubuntu..."
}

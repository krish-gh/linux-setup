#!/bin/bash

setup_specific_ubuntu() {
    # echo -e "Replacing snap version of firefox with native one..."
    # sudo install -d -m 0755 /etc/apt/keyrings
    # wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
    # printf 'Package: * \nPin: origin packages.mozilla.org \nPin-Priority: 1000 \n' | sudo tee /etc/apt/preferences.d/mozilla
    # sudo apt-get update && sudo snap remove firefox && uninstall_pkgs "*firefox*"

    # just ensuring this meta package was not uninstalled, it will wait for confirmation if it was
    sudo apt-get install ubuntu-desktop-minimal 
}

echo -e "Done ubuntu.sh..."

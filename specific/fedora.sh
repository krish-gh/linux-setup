#!/bin/bash

setup_fedora() {
    uninstall_pkgs "*abrt* mediawriter"
}

echo -e "Done fedora.sh..."

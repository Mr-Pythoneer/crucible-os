#!/usr/bin/env bash
#
# Installs Bottles — the GUI front-end for Wine prefixes, so most users
# never touch a raw `wine` command. Flatpak/Flathub is Bottles' own
# officially recommended distribution method (not a workaround), since it
# bundles the exact runtime versions Bottles is tested against.

set -euo pipefail

if ! command -v flatpak >/dev/null 2>&1; then
    echo -e "\033[36mInstalling flatpak...\033[0m"
    sudo apt-get update
    sudo apt-get install -y flatpak
fi

if ! flatpak remote-list | grep -q flathub; then
    echo -e "\033[36mAdding Flathub remote...\033[0m"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo -e "\033[36mInstalling Bottles...\033[0m"
flatpak install -y flathub com.usebottles.bottles

echo -e "\033[32mBottles installed. Launch with: flatpak run com.usebottles.bottles\033[0m"
echo "A desktop entry should also appear in your application menu after the next login."

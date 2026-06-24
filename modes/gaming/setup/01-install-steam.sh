#!/usr/bin/env bash
#
# Installs Steam (the actual Proton runtime delivery mechanism — Proton-GE
# in 04-install-proton-ge.sh layers on top of this, doesn't replace it).

set -euo pipefail

if ! grep -q "^deb.*multiverse" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo -e "\033[36mEnabling the multiverse repository (Steam lives there)...\033[0m"
    sudo add-apt-repository -y multiverse
fi

sudo dpkg --add-architecture i386
sudo apt-get update

echo -e "\033[36mInstalling Steam...\033[0m"
sudo apt-get install -y steam-installer

echo -e "\033[32mSteam installed. Launch with: steam\033[0m"

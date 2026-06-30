#!/usr/bin/env bash
#
# Installs Steam (the actual Proton runtime delivery mechanism — Proton-GE
# in 04-install-proton-ge.sh layers on top of this, doesn't replace it).

set -euo pipefail

# Match BOTH legacy one-line `deb ... multiverse` and Ubuntu 24.04's default
# DEB822 `.sources` format (Components: ... multiverse) — the old check only
# looked at *.list one-line entries, which noble no longer uses, so it always
# thought multiverse was missing. add-apt-repository is idempotent either way.
if ! grep -rqhE '(^deb[^#]*multiverse|^[[:space:]]*Components:.*multiverse)' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo -e "\033[36mEnabling the multiverse repository (Steam lives there)...\033[0m"
    sudo add-apt-repository -y multiverse
fi

sudo dpkg --add-architecture i386
sudo apt-get update

echo -e "\033[36mInstalling Steam...\033[0m"
sudo apt-get install -y steam-installer

echo -e "\033[32mSteam installed. Launch with: steam\033[0m"

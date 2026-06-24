#!/usr/bin/env bash
#
# Installs Wine (staging branch) from WineHQ's own repo for non-Steam apps.
# Steam/Proton-GE handles game compatibility separately (see 04) — this is
# for general Windows applications via Bottles (05).

set -euo pipefail

. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

sudo dpkg --add-architecture i386
sudo mkdir -p /etc/apt/keyrings

echo -e "\033[36mAdding WineHQ's signing key and repo for $CODENAME...\033[0m"
sudo wget -q -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

SOURCES_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${CODENAME}/winehq-${CODENAME}.sources"
if ! sudo wget -q -NP /etc/apt/sources.list.d/ "$SOURCES_URL"; then
    echo -e "\033[33mWineHQ has no repo for '$CODENAME' yet (common right after a new Ubuntu release — WineHQ usually lags by a few months). Check https://dl.winehq.org/wine-builds/ubuntu/dists/ for the closest supported codename, or fall back to the distro-packaged 'wine' (older version):\033[0m"
    echo "  sudo apt-get install -y wine winetricks"
    exit 1
fi

sudo apt-get update
echo -e "\033[36mInstalling winehq-staging...\033[0m"
sudo apt-get install -y --install-recommends winehq-staging winetricks

wine --version
echo -e "\033[32mWine staging installed.\033[0m"

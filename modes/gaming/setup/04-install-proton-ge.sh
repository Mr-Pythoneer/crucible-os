#!/usr/bin/env bash
#
# Installs the latest GE-Proton (community Proton build, broader game
# compatibility than vanilla Proton) into Steam's compatibility tools dir.
# Same "query latest GitHub release" pattern as modes/ai/setup/01-install-llamacpp.sh.

set -euo pipefail

INSTALL_DIR="${1:-$HOME/.steam/root/compatibilitytools.d}"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required (sudo apt-get install -y jq)." >&2
    exit 1
fi

echo -e "\033[36mQuerying latest GE-Proton release...\033[0m"
RELEASE_JSON=$(curl -fsSL -H "User-Agent: distro-setup" "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest")
TAG=$(echo "$RELEASE_JSON" | jq -r '.tag_name')
ASSET_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("\\.tar\\.gz$")) | .browser_download_url' | head -n1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
    echo "Could not find a .tar.gz asset in the latest release ($TAG). Check https://github.com/GloriousEggroll/proton-ge-custom/releases manually." >&2
    exit 1
fi

echo -e "\033[32mLatest: $TAG\033[0m"
mkdir -p "$INSTALL_DIR"
TMP_FILE=$(mktemp --suffix=.tar.gz)

echo "Downloading $ASSET_URL ..."
curl -fL -o "$TMP_FILE" "$ASSET_URL"

echo "Extracting to $INSTALL_DIR ..."
tar -xzf "$TMP_FILE" -C "$INSTALL_DIR"
rm -f "$TMP_FILE"

echo -e "\033[32m\nInstalled $TAG to $INSTALL_DIR\033[0m"
echo "Restart Steam, then enable it per-game: right-click a game -> Properties -> Compatibility -> check 'Force the use of a specific Steam Play compatibility tool' -> select $TAG."

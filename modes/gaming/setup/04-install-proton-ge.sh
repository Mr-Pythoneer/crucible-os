#!/usr/bin/env bash
#
# Installs the latest GE-Proton (community Proton build, broader game
# compatibility than vanilla Proton) into Steam's compatibility tools dir.
# Same "query latest GitHub release" pattern as modes/ai/setup/01-install-llamacpp.sh.

set -euo pipefail

# Resolve Steam's real compatibility-tools dir rather than hardcoding
# ~/.steam/root. ~/.steam/{root,steam} are SYMLINKS Steam creates on its first
# launch; if this script mkdir -p's ~/.steam/root before Steam has bootstrapped,
# it materializes it as a real dir, Steam's first run then resolves its root
# elsewhere, and the GE-Proton dropped here never shows in the per-game compat
# list. So require a completed Steam first-run (detected via the symlink /
# steamapps) unless an explicit path is passed.
if [ -n "${1:-}" ]; then
    INSTALL_DIR="$1"
else
    STEAM_ROOT=""
    for cand in "$HOME/.steam/root" "$HOME/.steam/steam" "$HOME/.local/share/Steam"; do
        if [ -L "$cand" ] || [ -d "$cand/steamapps" ]; then
            STEAM_ROOT="$cand"; break
        fi
    done
    if [ -z "$STEAM_ROOT" ]; then
        echo "Steam doesn't appear to have completed its first run yet." >&2
        echo "Launch Steam once (run: steam), let it finish setting up, then re-run this script." >&2
        echo "(Or pass an explicit compatibilitytools.d path as \$1 to override.)" >&2
        exit 1
    fi
    INSTALL_DIR="$STEAM_ROOT/compatibilitytools.d"
fi

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

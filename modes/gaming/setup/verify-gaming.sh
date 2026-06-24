#!/usr/bin/env bash
#
# Sanity-checks the Gaming mode bundle is actually installed.

set -uo pipefail

PASS=0
FAIL=0

check() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        echo -e "\033[32m[PASS]\033[0m $desc"
        PASS=$((PASS + 1))
    else
        echo -e "\033[31m[FAIL]\033[0m $desc"
        FAIL=$((FAIL + 1))
    fi
}

check "steam installed" dpkg -s steam-installer
check "lutris installed" command -v lutris
check "wine installed" command -v wine
check "winetricks installed" command -v winetricks
check "gamemode installed" command -v gamemoded
check "mangohud installed" dpkg -s mangohud
check "flatpak installed" command -v flatpak
check "bottles installed (flatpak)" flatpak info com.usebottles.bottles

PROTON_DIR="$HOME/.steam/root/compatibilitytools.d"
if [ -d "$PROTON_DIR" ] && find "$PROTON_DIR" -maxdepth 1 -iname "GE-Proton*" | grep -q .; then
    echo -e "\033[32m[PASS]\033[0m GE-Proton found in $PROTON_DIR"
    PASS=$((PASS + 1))
else
    echo -e "\033[31m[FAIL]\033[0m no GE-Proton found in $PROTON_DIR"
    FAIL=$((FAIL + 1))
fi

echo -e "\n$PASS passed, $FAIL failed."
[ "$FAIL" -eq 0 ]

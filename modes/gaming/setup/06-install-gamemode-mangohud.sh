#!/usr/bin/env bash
#
# Installs GameMode (Feral Interactive's per-launch performance daemon —
# not a system service, see modes/modectl/profiles/gaming.conf) and
# MangoHud (the performance overlay). Both are in Ubuntu's universe repo.

set -euo pipefail

sudo apt-get update
echo -e "\033[36mInstalling gamemode + mangohud...\033[0m"
sudo apt-get install -y gamemode mangohud

if ! groups "$USER" | grep -qw gamemode; then
    echo -e "\033[36mAdding $USER to the gamemode group...\033[0m"
    sudo usermod -aG gamemode "$USER"
    echo -e "\033[33mLog out and back in for the group change to take effect.\033[0m"
fi

echo -e "\033[32m\nDone. Usage:\033[0m"
echo "  gamemoderun %command%          — Steam launch options, per-game"
echo "  mangohud %command%             — Steam launch options, overlay"
echo "  gamemoderun mangohud <binary>  — both together, for non-Steam launches"

#!/usr/bin/env bash
#
# Installs/verifies AMD CPU microcode. See DESIGN.md §3.
#
# Microcode updates fix CPU-level errata (including security issues like
# Spectre variants) and are loaded by the kernel at boot — installing the
# package alone isn't enough to confirm it's active, so this also checks
# dmesg/cpuinfo after install.

set -euo pipefail

echo -e "\033[36mDetecting CPU...\033[0m"
if ! grep -qi amd /proc/cpuinfo; then
    echo "No AMD CPU detected via /proc/cpuinfo. Aborting — nothing to install." >&2
    exit 1
fi
grep -m1 "model name" /proc/cpuinfo

echo -e "\033[36mInstalling amd64-microcode...\033[0m"
sudo apt-get update
sudo apt-get install -y amd64-microcode

echo -e "\033[36mChecking whether microcode was actually loaded this boot...\033[0m"
if dmesg 2>/dev/null | grep -qiE 'microcode: (Updated early|Current revision|Reload completed)'; then
    dmesg | grep -i microcode
    echo -e "\033[32mMicrocode loaded.\033[0m"
elif command -v journalctl >/dev/null 2>&1 && journalctl -k -b 2>/dev/null | grep -qi microcode; then
    journalctl -k -b | grep -i microcode
    echo -e "\033[32mMicrocode loaded (found in current boot's kernel log).\033[0m"
else
    echo -e "\033[33mCould not confirm microcode load from this boot's logs — this is expected right after a fresh install (it takes effect on the NEXT boot). Reboot, then re-run this check:\033[0m"
    echo "  dmesg | grep -i microcode"
fi

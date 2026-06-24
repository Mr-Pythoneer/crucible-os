#!/usr/bin/env bash
#
# Installs the proprietary Nvidia driver and, if Secure Boot is enabled,
# walks through MOK (Machine Owner Key) signing so the kernel module actually
# loads instead of being silently rejected at boot. See DESIGN.md §3.
#
# This does NOT disable Secure Boot for you — that's a meaningful security
# posture change and should be the user's explicit choice, not a default
# this script makes silently.
#
# Usage: ./install-nvidia.sh [driver_version]
#   driver_version defaults to "driver-recommended" via ubuntu-drivers,
#   or pass an explicit apt package suffix like "550" for nvidia-driver-550.

set -euo pipefail

DRIVER_VERSION="${1:-}"

echo -e "\033[36mDetecting GPU...\033[0m"
if ! lspci | grep -qi nvidia; then
    echo "No Nvidia GPU detected via lspci. Aborting — nothing to install." >&2
    exit 1
fi
lspci | grep -i nvidia

SECURE_BOOT_STATE="unknown"
if command -v mokutil >/dev/null 2>&1; then
    SECURE_BOOT_STATE=$(mokutil --sb-state 2>/dev/null | grep -o "enabled\|disabled" || echo "unknown")
fi
echo "Secure Boot state: $SECURE_BOOT_STATE"

sudo apt-get update

if [ -n "$DRIVER_VERSION" ]; then
    PKG="nvidia-driver-${DRIVER_VERSION}"
    echo -e "\033[36mInstalling $PKG ...\033[0m"
    sudo apt-get install -y "$PKG"
else
    if ! command -v ubuntu-drivers >/dev/null 2>&1; then
        sudo apt-get install -y ubuntu-drivers-common
    fi
    echo -e "\033[36mInstalling ubuntu-drivers recommended Nvidia driver...\033[0m"
    sudo ubuntu-drivers install nvidia
fi

if [ "$SECURE_BOOT_STATE" = "enabled" ]; then
    cat <<'EOF'

Secure Boot is ENABLED. The Nvidia kernel module (nvidia.ko) is unsigned by
default and the kernel will refuse to load it on next boot unless you either:

  (a) Enroll a Machine Owner Key (MOK) and sign the module — recommended,
      keeps Secure Boot on:

        sudo apt-get install -y mokutil
        sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
        # You'll be asked to set a one-time password here.
        # REBOOT. At boot you'll see a blue "MOK management" screen —
        # select "Enroll MOK", enter the password you just set, then continue boot.
        # DKMS (which Ubuntu's nvidia-driver packages use) signs the module
        # automatically against this key on every kernel update afterward.

  (b) Disable Secure Boot in your BIOS/UEFI settings — simpler, but weakens
      boot-chain integrity verification. Your call, not made for you here.

Reboot is required either way before the driver actually loads.
EOF
else
    echo -e "\033[32mSecure Boot is not enabled — no MOK signing needed. Reboot to load the driver.\033[0m"
fi

echo -e "\nAfter rebooting, verify with: nvidia-smi"

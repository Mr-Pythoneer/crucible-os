#!/usr/bin/env bash
#
# Installs the WhiteSur GTK/icon/shell theme (vinceliuice/WhiteSur-*-theme —
# long-running, well-known macOS-style GNOME theme projects) into the
# invoking user's home directory (~/.themes, ~/.icons) — no sudo/system-wide
# install, which is the safer default for a per-user cosmetic theme.
#
# Must be run as the actual logged-in user, not root.

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user, not root/sudo — it installs into your home directory." >&2
    exit 1
fi

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Pinned to specific upstream commits, verified before any install.sh runs.
# This is download-and-execute of third-party code, so an upstream
# force-push / account compromise to a DIFFERENT commit must be detected and
# aborted rather than silently executed. The GTK repo's own install.sh also
# installs the GNOME Shell theme (into ~/.themes/WhiteSur*/gnome-shell) — there
# is NO separate WhiteSur-gnome-shell-theme repo (that name 404s; cloning it
# previously aborted this whole script under set -e). To update the theme,
# bump these SHAs to a newer reviewed upstream commit.
declare -A PINS=(
    [WhiteSur-gtk-theme]="a83f467e4c16b1ed1c960f3d89e2472d9639477c"
    [WhiteSur-icon-theme]="3cc051a4709e67921a9d47cd2a3e0111bbe5e2bd"
)

clone_pinned() {
    local repo="$1" want="${PINS[$1]}" dir="$WORKDIR/$1"
    echo -e "\033[36mFetching vinceliuice/$repo @ ${want:0:12} ...\033[0m"
    git init -q "$dir"
    git -C "$dir" remote add origin "https://github.com/vinceliuice/${repo}.git"
    # Fetch exactly the pinned commit (GitHub allows fetch-by-SHA), so this
    # keeps working after upstream HEAD moves on, and only the pinned tree runs.
    if ! git -C "$dir" fetch --depth 1 origin "$want" 2>/dev/null; then
        echo "ABORT: could not fetch pinned commit $want for $repo (network down, or the pin needs bumping)." >&2
        exit 1
    fi
    git -C "$dir" checkout -q FETCH_HEAD
    local got; got="$(git -C "$dir" rev-parse HEAD)"
    if [ "$got" != "$want" ]; then
        echo "ABORT: $repo HEAD ($got) != pinned ($want) — refusing to run unverified upstream code." >&2
        exit 1
    fi
}

clone_pinned WhiteSur-gtk-theme
clone_pinned WhiteSur-icon-theme

echo -e "\033[36mInstalling GTK + GNOME Shell theme...\033[0m"
"$WORKDIR/WhiteSur-gtk-theme/install.sh" -d "$HOME/.themes"

echo -e "\033[36mInstalling icon theme...\033[0m"
"$WORKDIR/WhiteSur-icon-theme/install.sh" -d "$HOME/.icons"

echo -e "\033[32m\nThemes installed under ~/.themes and ~/.icons.\033[0m"
echo "Apply with 03-apply-theme.sh (optionally reposition the dock with 02-configure-dock.sh), or set the theme via GNOME Tweaks manually."

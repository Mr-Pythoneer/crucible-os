# Normal mode

macOS-style polished default look, per DESIGN.md §4. **One-time setup**, not a per-switch toggle — run these once after install, not every time you `distro-modectl switch normal`:

```bash
./setup/01-install-whitesur-theme.sh   # clones vinceliuice/WhiteSur-*-theme, installs to ~/.themes, ~/.icons
./setup/02-configure-dock.sh           # repositions Ubuntu's built-in dock: bottom, floating, autohide
./setup/03-apply-theme.sh [theme-name] # enables GNOME's User Themes extension, applies GTK/icon/shell theme
```

All three must run as your normal logged-in user inside a real graphical session (they need `DBUS_SESSION_BUS_ADDRESS` for `gsettings`) — not over SSH, not as root.

## What's real here, and why it's safe to trust without live testing

- **Dock repositioning** (`02-configure-dock.sh`) doesn't install anything new — stock Ubuntu already ships "Ubuntu Dock," which is a rebrand of the `dash-to-dock` GNOME extension, running under the `org.gnome.shell.extensions.dash-to-dock` schema. That schema has been stable across many GNOME releases and is dash-to-dock's own public, documented API — not an internals guess.
- **Theme installer** (`01-install-whitesur-theme.sh`) fetches and runs vinceliuice's own `install.sh` for WhiteSur-gtk-theme (which installs the GNOME Shell theme too) and WhiteSur-icon-theme — long-running, well-known community projects. The clones are **pinned to specific upstream commit SHAs and verified before execution** (download-and-execute of third-party code, so an upstream force-push/compromise must abort rather than run silently — flagged by a security review). There is no separate `WhiteSur-gnome-shell-theme` repo (that name 404s — cloning it used to abort the whole script under `set -e`). The script doesn't reimplement their install logic, just invokes the pinned version.
- **Theme application** (`03-apply-theme.sh`) uses only `org.gnome.desktop.interface` (GTK/icon theme — core GNOME, not extension-dependent) and `org.gnome.shell.extensions.user-theme` (GNOME's own official "User Themes" extension, shipped in the `gnome-shell-extensions` apt package) — no third-party schema guesses.

## What's explicitly NOT attempted, and why (now web-researched, 2026-06)

A literal macOS-style **global app menu** in the top bar. The honest, verified
answer: there is **no stable, maintained GNOME 46+ extension** for this. GNOME
upstream removed the global application menu in 3.32 (2019); every global-menu
extension on extensions.gnome.org is stale (Fildem `fildemGlobalMenu@gonza.com`
is stuck at GNOME 41 on the store, with only an unmerged fork PR targeting
45–50; the others top out at GNOME 41/3.24). So this is deliberately not wired
in — it's not a "needs iteration" gap, it's "no stable option exists."

A **Mission-Control-equivalent** overview is **already built in**: GNOME's
Activities overview (Super key) is the Mission Control / Exposé analogue and is
the stable, supported option. No third-party overview extension is needed or
recommended.

For the macOS *look* (optional, cosmetic), the maintained choices are
**Open Bar** (`openbar@neuromorph`, supports GNOME 45–49) for a floating/island
top bar and **Dash to Dock** (`dash-to-dock@micxgx.gmail.com`, GNOME 45–50) for
the dock — though Ubuntu's built-in Ubuntu Dock already covers the dock (see
`02-configure-dock.sh`). These aren't auto-installed (they're EGO extensions,
not apt packages, and need a live session to enable) — documented here as the
verified path rather than guessed at.

## Known gaps / unverified

- Theme name produced by `WhiteSur-gtk-theme/install.sh` — **web-verified
  (2026-06):** a default install produces `WhiteSur-Dark` and `WhiteSur-Light`
  (capitalized) under `~/.themes`, and `WhiteSur` (base) under `~/.icons`, so
  `03-apply-theme.sh`'s assumed `WhiteSur-Dark` gtk-theme + `WhiteSur` icon-theme
  are CORRECT. (Note: GTK color suffix is capitalized `-Dark`; the icon suffix
  is lowercase `-dark` — don't cross them.) Still worth an eyeball on the real
  desktop, but the names are no longer a guess.
- Nothing in this directory has been visually verified on a real GNOME desktop — same hardware/session-availability gap as everywhere else in this repo, but specifically here it's "needs a live desktop," not "needs the GPU server."

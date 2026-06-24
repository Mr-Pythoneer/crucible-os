# Gaming mode

Compatibility stack per DESIGN.md §2/§4. Run in order:

```bash
./setup/01-install-steam.sh
./setup/02-install-lutris.sh
./setup/03-install-wine-staging.sh
./setup/04-install-proton-ge.sh
./setup/05-install-bottles.sh
./setup/06-install-gamemode-mangohud.sh
./setup/verify-gaming.sh
```

Then `distro-modectl switch gaming` (see `modes/modectl/`) applies the
performance governor/power profile and (best-effort) pins these apps to the
dock.

## What's covered

- **Steam** + **GE-Proton** (latest, auto-fetched from GitHub releases) for game compatibility
- **Lutris** (via its own PPA, not the often-stale Ubuntu universe package) for non-Steam game management and its install-script database
- **Wine-staging** (WineHQ's own repo) + **winetricks** for general Windows apps
- **Bottles** (Flatpak/Flathub — Bottles' own recommended distribution method) as the GUI front-end so most users never see raw `wine`
- **GameMode** + **MangoHud**, both per-launch tools (`gamemoderun`/`mangohud` prefixes), not system services

## Known gaps / unverified

- `03-install-wine-staging.sh` depends on WineHQ having published a repo for the current Ubuntu codename — they sometimes lag a new Ubuntu release by a few months. The script detects this and fails with a clear fallback (distro-packaged `wine`) rather than silently using a wrong repo.
- `PINNED_APPS` desktop-file IDs in `modes/modectl/profiles/gaming.conf` (`steam.desktop`, `lutris.desktop`, `com.usebottles.bottles.desktop`) are best-guess, not confirmed against a real install — check with `ls /usr/share/applications` and `flatpak list --app` once these are actually installed, and correct the profile if they don't match.
- DXVK/VKD3D are not installed standalone here — Proton-GE bundles its own, and Bottles manages its own per-prefix. A standalone installer for raw Wine prefixes outside Bottles isn't built yet (low priority — Bottles covers the common case).
- Nothing in this directory has launched an actual game yet — needs a real GPU + Steam library to verify against (see DESIGN.md operating constraints).

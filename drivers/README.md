# Drivers

Nvidia GPU + AMD CPU driver bundling, per DESIGN.md §3.

```bash
./install-nvidia.sh              # ubuntu-drivers recommended package
./install-nvidia.sh 550          # or pin an explicit version (nvidia-driver-550)
./install-amd-microcode.sh
sudo reboot
./verify-drivers.sh
```

## Secure Boot

`install-nvidia.sh` detects Secure Boot state and, if enabled, prints the MOK
enrollment steps instead of doing them silently — enrolling a MOK or
disabling Secure Boot are both meaningful security-posture changes that
should be the user's explicit action, not something a script does for them
without them watching it happen.

## Status

Not yet run on real hardware (see `modes/ai/README.md` for the hardware
timeline — same constraint applies here). Logic is straightforward apt/MOK
flows with no novel risk, but unverified is unverified:

- [ ] `install-nvidia.sh` against a real Nvidia GPU, both Secure-Boot-on and
      Secure-Boot-off paths
- [ ] `install-amd-microcode.sh` microcode-loaded detection across a reboot
- [ ] `verify-drivers.sh` pass/fail output matches reality

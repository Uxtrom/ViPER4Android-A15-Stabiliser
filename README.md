# ViPER4Android A13–A15 (KernelSU) — v1.3.0

This build removes the legacy WebUI/v4actl and replaces control with a terminal menu (`v4a-menu`) and a companion APK (V4AControl). See Usage below.

## Install
- Flash the ZIP in KernelSU Manager.
- Reboot.

 What changed
- Removed WebUI and `v4actl`.
- Kept watchdog and SELinux rules minimal.
- New `v4a-menu` with enable/disable/status/restart.

## Troubleshooting
- Ensure root via KernelSU.
- Check `logcat | grep V4A` for messages.
## Usage
- Terminal control only: `su -c v4a`
  - Enable / Disable (`persist.v4a.enabled`)
  - Status (`dumpsys media.audio_flinger` grep)
  - Restart `audioserver`
  - Heal/attach effects

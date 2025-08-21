# ViPER4Android A15 Compat (Fixed v1.2.0)

**What changed**
- Event-driven watchdog: reacts instantly to audio route/source changes (calls ↔ media, BT/wired, app switches).
- Faster fallback probe (10s) to catch silent failures.
- Expanded SELinux live rules for audioserver to read vendor/product/odm configs on Android 12–15.
- New terminal command: `v4actl` (on/off/toggle/status/restart).
- Respects property `persist.v4a.enabled` for persistent user control.

**Installation**
1. Flash this ZIP via KernelSU or Magisk (Zygisk not required).
2. Reboot.
3. Optional: use `v4actl` from a root shell to enable/disable quickly.
   - `v4actl off` — disables V4A and stops effects.
   - `v4actl on` — enables V4A and pokes the app to attach.
   - `v4actl status` — prints current state.

**Notes & assumptions**
- Compatible with Android 12–15; tested conceptually for A13/A14. Uses logcat events to react to AudioFlinger/APM route changes.
- If another effects manager (MusicFX/AudioFX) is active, the service disables them on boot.
- If SELinux denies loading libraries from non-system locations, the included live `magiskpolicy` and `sepolicy.rule` lines grant read/map access to typical config contexts.

**Rollback**
- To revert, disable or uninstall the module in KernelSU/Magisk.

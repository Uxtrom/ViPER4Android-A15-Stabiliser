## 📦 Install
1. **Flash the ZIP in KernelSU Manager** (Modules → Install from storage).
2. **Reboot**.

That’s it.

---

## ✨ What’s new in v1.4.0
- 🔥 Dropped **WebUI** and **`v4actl`** (less surface, fewer breakages).
- 🛡️ **Minimal** watchdog + **tight** SELinux rules (stays enforcing).
- 🧰 New **`v4a-menu`** with:
  - Enable/Disable toggle (`persist.v4a.enabled`)
  - Status (greps `dumpsys media.audio_flinger`)
  - `audioserver` restart
  - “Heal” / reattach effects

---

## ✅ Requirements
- **Android 13–15**
- **KernelSU root**
- Working **AudioFlinger** path for the target output (no full offload)
- (Optional but recommended) **OverlayFS mount helper** for stubborn vendor configs

---

## 🛠️ Usage

### Terminal (primary control)
```bash
su -c v4a
````

Menu actions:

* **Enable / Disable** (`persist.v4a.enabled=1|0`)
* **Status** (checks effect presence in `dumpsys media.audio_flinger`)
* **Restart** `audioserver`
* **Heal** (re-attach effect chain if the session slipped)

### Companion App

* **V4A(RE)** by WSTxda:
  👉 [https://github.com/WSTxda/ViperFX-RE-Releases](https://github.com/WSTxda/ViperFX-RE-Releases)

---

## 🧩 Supported components

* **Driver / App**: WSTxda’s **V4A(RE)**
  👉 [https://github.com/WSTxda/ViperFX-RE-Releases](https://github.com/WSTxda/ViperFX-RE-Releases)
* **Root frameworks**: KernelSU (primary) and Magisk.

---

## 🐞 Troubleshooting

### 1) “**ViPER4Android FX driver not initiated**”

This usually means your **vendor audio\_effects XML** didn’t get overlaid early enough.

**Fix (no drama, just do this):**

* Install a mount helper that overlays **/system/** and **/vendor/** early:

  * **Magisk OverlayFS** (a.k.a. *Magisk Mount Extended* by HuskyDG) — works with KernelSU too.

    * Repo mirror: `Magisk-Modules-Alt-Repo/magisk_overlayfs`
* Reboot.
* Re-flash this module (KernelSU Manager), reboot again.
* Run:


### 2) No effect on **Bluetooth / USB / Offload**

* Check **Developer options → Disable Bluetooth A2DP hardware offload**. If it exists, **disable offload** and reboot.
* Some ROMs force **deep offload** or **hardware DSP**; V4A can’t hook what never reaches AudioFlinger. **Accept it or change ROM/kernel**.
* Try **wired** or **non-offloaded** output first to validate V4A works at all.

### 3) Conflicts with other effects (Dirac, Dolby, MiSound, Sony SE, OnePlus Audio Tuner)

- Disable/uninstall vendor audio “enhancers”, or set them to **Off**.  
- If they’re baked into `/vendor`, let **Heal** try to re-prioritize V4A.  
- Worst case: overlay their XML entries to **DISABLE** or lower their priority.  
- ✅ Recommended: Install [**Audio Modification Library (AML)**](https://github.com/reiryuki/Audio-Modification-Library) by **reiryuki** to isolate V4A and prevent conflicts with other audio mods/effects.  


### 4) Quick self-checks

```bash
# See if V4A shows up in AudioFlinger effect chains
dumpsys media.audio_flinger | grep -i v4a -n

# Basic log
logcat | grep -i v4a

# Flip driver on/off
setprop persist.v4a.enabled 1   # or 0, then restart audioserver via v4a-menu
```

---

## 🚧 Known Limitations (Reality check)

* **Bluetooth/USB/offload**: Many devices won’t route through AudioFlinger → **no V4A**. That’s not “your config”, that’s **how the audio path is built**.
* **Proprietary DSP stacks** (Mi/OneUI/ColorOS): They may override/steal the session after boot or on device-specific outputs.
* **OTA updates / ROM changes**: They can silently change effect UUIDs, priorities, or pathing; re-flash and **Heal**.

---

## 🔧 Power-user tips

* Toggle driver without menu:

  ```bash
  su -c 'setprop persist.v4a.enabled 1; killall audioserver'  # enable
  su -c 'setprop persist.v4a.enabled 0; killall audioserver'  # disable
  ```
* Verify attachment on a playing stream: run `dumpsys media.audio_flinger` **while audio is playing**, then look for an effect referencing V4A in the output chain of the active track.

---

## 🗑️ Uninstall / Revert

* Disable in **KernelSU Manager → Modules → Remove**, reboot.
* If you used OverlayFS, keep it if other modules need it; otherwise remove the helper too.

---

## 📚 References

* **V4A(RE) releases** — app + driver info
  [https://github.com/WSTxda/ViperFX-RE-Releases](https://github.com/WSTxda/ViperFX-RE-Releases)
* **OverlayFS helper** (Magisk OverlayFS / “Magisk Mount Extended” by HuskyDG, KSU-compatible mirror)
  Search: `Magisk-Modules-Alt-Repo/magisk_overlayfs`

---

## 🧾 Changelog

**v1.4.0**

* Removed WebUI and `v4actl`
* Minimal watchdog & SELinux rules
* Added `v4a-menu` (enable/disable/status/restart/heal)

---

## 🙏 Credits & License

* **ViPER4Android FX** original authors and community.
* **WSTxda** for V4AControl (RE).
* **HuskyDG** for OverlayFS tooling.
* Respect upstream licenses. This repo ships only what’s allowed; app/driver belong to their respective authors.

```

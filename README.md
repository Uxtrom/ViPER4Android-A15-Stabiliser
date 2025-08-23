ViPER4Android A15 Compatibility – v1.3.0

Persistent ViPER4Android (V4A) module for KernelSU/Magisk with:

Event-driven watchdog (auto-recovers on route/source switches).

Webmenu toggle with root bridge.

CLI toggle (v4actl) with verbose and batch modes.

Idempotent re-init after disable/re-enable.

Minimal SELinux rules (no permissive).

KernelSU UI toggle integration.

📦 Features

Webmenu Control: Toggle V4A via browser (127.0.0.1:12720) with instant state sync.

Watchdog Service: Monitors audio sessions/routes, reattaches effects automatically.

CLI Control (v4actl): Reliable on/off/toggle/status/restart.

KernelSU Integration: Toggle switch in KernelSU app (via toggle.sh + ui.prop).

Idempotent Re-enable: No reboot required after disabling/enabling module.

Logging: Debug log written to log.txt in the module folder.

🚀 Installation

Flash the ZIP (V4A-A15-Compat-WATCHDOG-Auto-fixed-v1.3.0.zip) via KernelSU or Magisk.

Reboot.

Install ViPER4Android app (com.pittvandewitt.viperfx or legacy com.vipercn.viper4android_v2).

Confirm in app: Driver status: Normal, Processing: Yes while playing audio.

🕹️ Usage
CLI
v4actl on        # enable + re-init stack
v4actl off       # disable + unload effects
v4actl toggle    # switch state
v4actl status    # print enabled/disabled
v4actl restart   # restart audioserver
v4actl -v on     # verbose logging

Webmenu

Access http://127.0.0.1:12720 in a local WebView/browser.

Toggle V4A state; status updates automatically.

KernelSU App

Module exposes a toggle in KernelSU → Modules → V4A Toggle.

Linked directly to persist.v4a.enabled and v4actl.

⚙️ Properties

persist.v4a.enabled → 1 = enabled (default), 0 = disabled

persist.v4a.interval → Watchdog probe interval in seconds (default: 10)

persist.v4a.log → 1 = enable logging to log.txt, 0 = disable (default)

✅ Acceptance Tests

Webmenu toggle updates state and persists across refresh.

v4actl status matches webmenu state.

Disable/re-enable in KernelSU → V4A attaches without reboot.

Route/device changes (call ↔ YouTube, BT ↔ wired) keep V4A attached.

No SELinux denials in dmesg or logcat -b kernel | grep avc.

dumpsys media.audio_flinger shows V4A effect libs after toggles.

🛡️ SELinux

Minimal allow rules only:

audioserver → system_file, system_ext_file, vendor_file, product_file, odm_file, vendor_configs_file.

Prevents denials when reading audio effect configs on modern ROMs.

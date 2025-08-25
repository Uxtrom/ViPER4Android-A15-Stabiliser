#!/system/bin/sh
MODDIR="/data/adb/modules/v4a-a15-compat-auto"
LOG="$MODDIR/log.txt"
POL="$("/system/bin/sh" "$MODDIR/system/bin/_find_policy.sh")"
[ -n "$POL" ] && {
  "$POL" --live "allow audioserver vendor_file file { read open getattr map }" 2>>"$LOG"
  "$POL" --live "allow audioserver vendor_configs_file dir { search read open getattr }" 2>>"$LOG"
  "$POL" --live "allow audioserver vendor_configs_file file { read open getattr map }" 2>>"$LOG"
  "$POL" --live "allow audioserver product_file file { read open getattr map }" 2>>"$LOG"
  "$POL" --live "allow audioserver odm_file file { read open getattr map }" 2>>"$LOG"
}
setprop persist.v4a.enabled 1
killall audioserver >/dev/null 2>&1 || true
sleep 2
if command -v dumpsys >/dev/null 2>&1 && dumpsys media.audio_flinger 2>/dev/null | grep -qiE "v4a_fx|libv4a_fx\.so"; then
  echo "[V4A] attach: OK (effect visible)"
else
  echo "[V4A] attach: NOT visible yet"
fi

#!/system/bin/sh
MODDIR="${0%/*}"
magiskpolicy --live "allow audioserver system_file file { read open getattr map }"
magiskpolicy --live "allow audioserver system_lib_file file { read open getattr map }"
magiskpolicy --live "allow audioserver system_ext_file file { read open getattr map }"
DEFAULTS="/data/adb/v4a_app_defaults.properties"
SRC="$MODDIR/system/etc/defaults/v4a_app_defaults.properties"
if [ -f "$SRC" ] && [ ! -f "$DEFAULTS" ]; then
  cp -fp "$SRC" "$DEFAULTS"; chown 1000:1000 "$DEFAULTS"; chmod 0644 "$DEFAULTS"
fi

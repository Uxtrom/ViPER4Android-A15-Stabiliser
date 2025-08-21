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
# Extra allowances for modern vendor/product file contexts where audio_effects*.xml may live
magiskpolicy --live "allow audioserver vendor_file file { read open getattr map }"
magiskpolicy --live "allow audioserver vendor_configs_file dir { search read open getattr }"
magiskpolicy --live "allow audioserver vendor_configs_file file { read open getattr map }"
magiskpolicy --live "allow audioserver product_file file { read open getattr map }"
magiskpolicy --live "allow audioserver odm_file file { read open getattr map }"
setprop persist.v4a.enabled 1

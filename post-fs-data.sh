\
#!/system/bin/sh
MODDIR="${0%/*}"
PROP_ENABLE="persist.v4a.enabled"
PROP_LOG="persist.v4a.log"

# Ensure log file exists with safe perms
LOGF="$MODDIR/log.txt"
touch "$LOGF"
chmod 0644 "$LOGF"
chown 0:0 "$LOGF"

# Defaults
[ -z "$(getprop $PROP_ENABLE)" ] && setprop $PROP_ENABLE 1
[ -z "$(getprop $PROP_LOG)" ] && setprop $PROP_LOG 0

# Live SEPolicy (minimal and targeted)
magiskpolicy --live "allow audioserver vendor_file file { read open getattr map }"
magiskpolicy --live "allow audioserver vendor_configs_file dir { search read open getattr }"
magiskpolicy --live "allow audioserver vendor_configs_file file { read open getattr map }"
magiskpolicy --live "allow audioserver product_file file { read open getattr map }"
magiskpolicy --live "allow audioserver odm_file file { read open getattr map }"

# Disable conflicting stock effects
pm disable-user --user 0 com.android.musicfx >/dev/null 2>&1
pm disable-user --user 0 com.google.android.musicfx >/dev/null 2>&1

# Idempotent re-init helper
cat > "$MODDIR/post-fs-reinit.sh" <<'EOF'
#!/system/bin/sh
MODDIR="${0%/*}"
# Refresh overlays/symlinks if module ships them
for d in /system/etc /vendor/etc /product/etc /odm/etc; do
  [ -f "$MODDIR/audio_effects.xml" ] && cp -fp "$MODDIR/audio_effects.xml" "$d/audio_effects.xml" 2>/dev/null
  [ -f "$MODDIR/audio_effects.conf" ] && cp -fp "$MODDIR/audio_effects.conf" "$d/audio_effects.conf" 2>/dev/null
done
# Re-apply live policy in case called post-boot
magiskpolicy --live "allow audioserver vendor_file file { read open getattr map }"
magiskpolicy --live "allow audioserver vendor_configs_file dir { search read open getattr }"
magiskpolicy --live "allow audioserver vendor_configs_file file { read open getattr map }"
magiskpolicy --live "allow audioserver product_file file { read open getattr map }"
magiskpolicy --live "allow audioserver odm_file file { read open getattr map }"
# Re-disable MusicFX if ROM re-enabled it
pm disable-user --user 0 com.android.musicfx >/dev/null 2>&1
pm disable-user --user 0 com.google.android.musicfx >/dev/null 2>&1
EOF
chmod 0755 "$MODDIR/post-fs-reinit.sh"

# Ensure log file exists for WebUI status
LOGF="$MODDIR/log.txt"; touch "$LOGF"; chmod 0644 "$LOGF"

# ensure default toggle property
if [ -z "$(getprop persist.v4a.enabled)" ]; then
  setprop persist.v4a.enabled 1
fi

# relink audio_effects overlays early
mkdir -p "$MODDIR/system/vendor/etc"
cp -fp "$MODDIR/config/audio_effects_v4a.xml" "$MODDIR/system/vendor/etc/audio_effects.xml" 2>/dev/null || true

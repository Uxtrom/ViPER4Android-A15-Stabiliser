#!/system/bin/sh
MODDIR="${0%/*}"

magiskpolicy --live "allow audioserver system_file file { read open getattr map }"
magiskpolicy --live "allow audioserver system_lib_file file { read open getattr map }"
magiskpolicy --live "allow audioserver system_ext_file file { read open getattr map }"

if [ ! -d "/data/adb/modules/aml" ] || [ "$(grep -s '^enable=' /data/adb/modules/aml/module.prop | cut -d= -f2)" = "0" ]; then
  for CFG in /vendor/etc/audio_effects.xml /system/etc/audio_effects.xml /vendor/etc/audio_effects.conf /system/etc/audio_effects.conf; do
    [ ! -f "$CFG" ] && continue
    MIRROR="/sbin/.magisk/mirror$CFG"
    TARGET="$CFG"; [ -f "$MIRROR" ] && TARGET="$MIRROR"
    case "$CFG" in
      *.xml)
        SNIP="$MODDIR/system/etc/v4a_effects_snippet.xml"
        if [ -f "$SNIP" ] && ! grep -qi "libv4a_fx.so" "$TARGET"; then
          cp "$TARGET" "$TARGET.bak" 2>/dev/null
          awk -v RS= -v ORS='' -v snip="$(cat "$SNIP")" '
            { sub("</audio_effects_config>", snip "\n</audio_effects_config>"); print; }' \
            "$TARGET" > "$TARGET.tmp" && cp -f "$TARGET.tmp" "$TARGET"
        fi
        ;;
      *.conf)
        SNIP="$MODDIR/system/etc/v4a_effects_snippet.conf"
        if [ -f "$SNIP" ] && ! grep -qi "libv4a_fx.so" "$TARGET"; then
          cp "$TARGET" "$TARGET.bak" 2>/dev/null
          cat "$SNIP" >> "$TARGET"
        fi
        ;;
    esac
  done
fi

DEFAULTS="/data/adb/v4a_app_defaults.properties"
SRC="$MODDIR/system/etc/defaults/v4a_app_defaults.properties"
if [ -f "$SRC" ] && [ ! -f "$DEFAULTS" ]; then
  cp -fp "$SRC" "$DEFAULTS"
  chown 1000:1000 "$DEFAULTS"
  chmod 0644 "$DEFAULTS"
fi

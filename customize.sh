#!/system/bin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

ui_print(){ echo "$@"; }

ui_print "***** ViPER4Android A15 Compat (Auto-Find + Watchdog) *****"

SDK="$(getprop ro.build.version.sdk)"
ABI_PRIMARY="$(getprop ro.product.cpu.abi)"
ABILIST32="$(getprop ro.product.cpu.abilist32)"
ui_print "- SDK: $SDK  ABI: $ABI_PRIMARY  abilist32: $ABILIST32"

SYSROOT="/system"
SYS_EXT="/system_ext"

pick_sfx_dir() {
  if [ "$1" = "64" ]; then
    if [ -d "$SYS_EXT/lib64/soundfx" ]; then echo "$SYS_EXT/lib64/soundfx"; else echo "$SYSROOT/lib64/soundfx"; fi
  else
    if [ -d "$SYS_EXT/lib/soundfx" ]; then echo "$SYS_EXT/lib/soundfx"; else echo "$SYSROOT/lib/soundfx"; fi
  fi
}

copy_engine() {
  # $1 bitness 32/64, $2 source path, $3 filename
  local BIT="$1"; local SRC="$2"; local NAME="$3"
  [ ! -s "$SRC" ] && return 1
  local DSTDIR="$MODPATH$(pick_sfx_dir $BIT)"
  mkdir -p "$DSTDIR"
  cp -fp "$SRC" "$DSTDIR/$NAME" && chmod 0644 "$DSTDIR/$NAME"
  ui_print "- Copied $NAME ($BIT-bit) -> $DSTDIR/$NAME"
  return 0
}

try_from_zip() {
  local COP=0
  for NAME in libv4afx_r.so libv4a_fx.so; do
    [ -s "$ZIPDIR/engine/arm64-v8a/$NAME" ] && copy_engine 64 "$ZIPDIR/engine/arm64-v8a/$NAME" "$NAME" && COP=1
    [ -s "$ZIPDIR/engine/armeabi-v7a/$NAME" ] && copy_engine 32 "$ZIPDIR/engine/armeabi-v7a/$NAME" "$NAME" && COP=1
  done
  return $COP
}

# Search common locations in system and other Magisk/KSU modules
find_existing_engine() {
  local BIT="$1"
  local NAME
  local dirs=""
  if [ "$BIT" = "64" ]; then
    dirs="$SYS_EXT/lib64/soundfx $SYSROOT/lib64/soundfx /vendor/lib64/soundfx"
  else
    dirs="$SYS_EXT/lib/soundfx $SYSROOT/lib/soundfx /vendor/lib/soundfx"
  fi
  # Magisk/KernelSU mirrors and modules
  dirs="$dirs /sbin/.magisk/mirror$SYS_EXT/lib$([ "$BIT" = "64" ] && echo 64)/soundfx \
             /sbin/.magisk/mirror$SYSROOT/lib$([ "$BIT" = "64" ] && echo 64)/soundfx \
             /sbin/.magisk/mirror/vendor/lib$([ "$BIT" = "64" ] && echo 64)/soundfx"
  # Scan installed modules for libs under lib*/soundfx
  for d in /data/adb/modules/* /data/adb/modules_update/*; do
    [ -d "$d" ] || continue
    for sub in lib$([ "$BIT" = "64" ] && echo 64)/soundfx; do
      dirs="$dirs $d/system/$sub $d/system_ext/$sub $d/$sub"
    done
  done
  for NAME in libv4afx_r.so libv4a_fx.so; do
    for d in $dirs; do
      if [ -s "$d/$NAME" ]; then
        ui_print "- Found $NAME ($BIT-bit) at $d/$NAME"
        copy_engine "$BIT" "$d/$NAME" "$NAME" && return 0
      fi
    done
  done
  return 1
}

COPIED=0
if try_from_zip; then COPIED=1; fi
# If not inside zip, hunt in system/modules
if [ "$COPIED" -eq 0 ]; then
  ui_print "- No engine in zip; scanning system and installed modules..."
  find_existing_engine 64 && COPIED=1
  # Install 32-bit too if device supports it
  if [ -n "$ABILIST32" ]; then
    find_existing_engine 32 && COPIED=1
  fi
fi

if [ "$COPIED" -eq 0 ]; then
  ui_print "! Could not locate any ViPER engine (libv4afx_r.so/libv4a_fx.so). Module will install but V4A won't load."
fi

# Stage config + defaults
mkdir -p "$MODPATH/system/etc/defaults"
cat > "$MODPATH/system/etc/defaults/v4a_app_defaults.properties" <<'EOF'
legacy_mode=true
attach_session0=true
convolver_safe_mode=true
EOF
chmod 0644 "$MODPATH/system/etc/defaults/v4a_app_defaults.properties"

ui_print "- Staging complete"

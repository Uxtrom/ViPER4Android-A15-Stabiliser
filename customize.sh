#!/system/bin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

print_title() { ui_print "*******************************"; ui_print "$1"; ui_print "*******************************"; }
print_title "ViPER4Android A15 Compatibility Pack (ARM/ARM64 + Watchdog)"

SDK="$(getprop ro.build.version.sdk)"
ABI_PRIMARY="$(getprop ro.product.cpu.abi)"
ABILIST32="$(getprop ro.product.cpu.abilist32)"
ABILIST64="$(getprop ro.product.cpu.abilist64)"
SYSROOT="/system"
SYS_EXT="/system_ext"

ui_print "- Android SDK: $SDK"
ui_print "- ABI primary: $ABI_PRIMARY"
ui_print "- abilist32: $ABILIST32"
ui_print "- abilist64: $ABILIST64"

pick_sfx_dir() {
  if [ "$1" = "64" ]; then
    if [ -d "$SYS_EXT/lib64/soundfx" ]; then echo "$SYS_EXT/lib64/soundfx"; else echo "$SYSROOT/lib64/soundfx"; fi
  else
    if [ -d "$SYS_EXT/lib/soundfx" ]; then echo "$SYS_EXT/lib/soundfx"; else echo "$SYSROOT/lib/soundfx"; fi
  fi
}

install_engine_64() {
  local DST; DST="$(pick_sfx_dir 64)"
  local SRC="$ZIPDIR/engine/arm64-v8a/libv4a_fx.so"
  [ ! -s "$SRC" ] && return 1
  ui_print "- Installing arm64 engine -> $DST"
  mkdir -p "$MODPATH$DST"
  cp -fp "$SRC" "$MODPATH$DST/libv4a_fx.so"
  set_perm "$MODPATH$DST/libv4a_fx.so" 0644 root root
  return 0
}
install_engine_32() {
  local DST; DST="$(pick_sfx_dir 32)"
  local SRC="$ZIPDIR/engine/armeabi-v7a/libv4a_fx.so"
  [ ! -s "$SRC" ] && return 1
  ui_print "- Installing 32-bit (ARM) engine -> $DST"
  mkdir -p "$MODPATH$DST"
  cp -fp "$SRC" "$MODPATH$DST/libv4a_fx.so"
  set_perm "$MODPATH$DST/libv4a_fx.so" 0644 root root
  return 0
}

INSTALLED_ANY=0
case "$ABI_PRIMARY" in
  arm64-v8a)
    install_engine_64 && INSTALLED_ANY=1
    if [ -n "$ABILIST32" ]; then install_engine_32 && INSTALLED_ANY=1; fi
    ;;
  armeabi-v7a|armeabi)
    install_engine_32 && INSTALLED_ANY=1
    ;;
  *)
    install_engine_64 && INSTALLED_ANY=1
    install_engine_32 && INSTALLED_ANY=1
    ;;
esac

if [ "$INSTALLED_ANY" -eq 0 ]; then
  abort "! Missing engine binaries. Place your ViPER .so at engine/armeabi-v7a/libv4a_fx.so (and optionally engine/arm64-v8a/libv4a_fx.so) before flashing."
fi

AML_FLAG=0
if [ -d "/data/adb/modules/aml" ] && [ "$(grep -s '^enable=' /data/adb/modules/aml/module.prop | cut -d= -f2)" != "0" ]; then
  AML_FLAG=1
fi
[ "$AML_FLAG" -eq 1 ] && ui_print "- AML detected: skipping direct audio_effects edits (AML will merge)."

if [ "$AML_FLAG" -eq 0 ]; then
  mkdir -p "$MODPATH/system/etc"
  cp -fp "$ZIPDIR/config/v4a_effects_snippet.xml" "$MODPATH/system/etc/v4a_effects_snippet.xml"
  cp -fp "$ZIPDIR/config/v4a_effects_snippet.conf" "$MODPATH/system/etc/v4a_effects_snippet.conf"
  set_perm "$MODPATH/system/etc/v4a_effects_snippet.xml" 0644 root root
  set_perm "$MODPATH/system/etc/v4a_effects_snippet.conf" 0644 root root
  ui_print "- Will attempt safe merge into audio_effects*.xml/conf at boot (no AML found)."
fi

mkdir -p "$MODPATH/system/etc/defaults"
cp -fp "$ZIPDIR/config/v4a_app_defaults.properties" "$MODPATH/system/etc/defaults/v4a_app_defaults.properties"
set_perm "$MODPATH/system/etc/defaults/v4a_app_defaults.properties" 0644 root root

ui_print "- Staging complete"

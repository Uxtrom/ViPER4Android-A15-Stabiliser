#!/system/bin/sh
# Watchdog + disable conflicts
for PKG in com.android.musicfx org.lineageos.audiofx; do
  pm disable-user --user 0 "$PKG" >/dev/null 2>&1
done
INTERVAL=60; MISS_LIMIT=3; KILL_LIMIT=2
misses=0; recovers=0
logi(){ log -t V4A-Watchdog "$*"; }
is_active(){ dumpsys media.audio_flinger 2>/dev/null | grep -qiE "v4a_fx|v4afx_r|libv4a_fx\.so|libv4afx_r\.so|ViPER"; }
try_gentle_restart(){
  am broadcast -a com.pittvandewitt.viperfx.RESTART >/dev/null 2>&1
  am broadcast -a com.pittvandewitt.viperfx.START >/dev/null 2>&1
  am broadcast -a com.vipercn.viper4android_v2.RESTART >/dev/null 2>&1
  am start -W -a android.intent.action.MAIN -n com.pittvandewitt.viperfx/.MainActivity --activity-no-history --activity-exclude-from-recents >/dev/null 2>&1
}
hard_restart_audio(){ killall audioserver >/dev/null 2>&1; }
(
  logi "Watchdog started"
  while true; do
    sleep "$INTERVAL"
    if is_active; then misses=0; recovers=0; continue; fi
    misses=$((misses+1)); logi "Effect not active (miss $misses/$MISS_LIMIT)"
    if [ "$misses" -ge "$MISS_LIMIT" ]; then
      logi "Gentle restart"; try_gentle_restart; sleep 10
      if is_active; then logi "Recovered"; misses=0; recovers=0; continue; fi
      recovers=$((recovers+1)); logi "Gentle restart failed ($recovers/$KILL_LIMIT)"
      if [ "$recovers" -ge "$KILL_LIMIT" ]; then logi "Restarting audioserver"; hard_restart_audio; recovers=0; misses=0; sleep 5; fi
    fi
  done
) &

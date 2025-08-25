#!/system/bin/sh
MODDIR="${0%/*}"
LOGF="$MODDIR/log.txt"; touch "$LOGF"; chmod 0644 "$LOGF"
log(){ log -t V4A "$*"; echo "$(date '+%F %T') $*" >>"$LOGF"; }
logi(){ log "I $*"; }
# ---- simplified control (no WebUI/v4actl) ----
logi "Starting V4A watchdog (no WebUI)"
INTERVAL="$(getprop persist.v4a.interval)"
[ -z "$INTERVAL" ] && INTERVAL=10

apply_state(){
  if [ "$(getprop persist.v4a.enabled)" = "1" ]; then
    logi "V4A enabled; ensuring effects overlays and engine are active"
    "$MODDIR/common_scripts/on.sh" 2>>"$LOGF" || true
  else
    logi "V4A disabled; removing overlays"
    "$MODDIR/common_scripts/off.sh" 2>>"$LOGF" || true
  fi
}

restart_audio(){
  logi "Restarting audioserver"
  killall audioserver 2>/dev/null || setprop ctl.restart audioserver
}

apply_state
while true; do
  sleep "$INTERVAL"
  # Re-assert state and heal
  "$MODDIR/common_scripts/attach_fix.sh" 2>>"$LOGF" || true
  apply_state
done
# ---- end simplified ----

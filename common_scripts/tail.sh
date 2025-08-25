#!/system/bin/sh
LOG="/data/adb/modules/v4a-a15-compat-auto/log.txt"
[ -f "$LOG" ] || { echo "log not found at $LOG"; exit 0; }
tail -n 120 "$LOG"

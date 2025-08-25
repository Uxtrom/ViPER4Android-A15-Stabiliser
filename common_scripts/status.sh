#!/system/bin/sh
PROP="persist.v4a.enabled"
STATE="$(getprop "$PROP")"
[ -z "$STATE" ] && STATE=1
if dumpsys media.audio_flinger 2>/dev/null | grep -qiE "v4a_fx\|libv4a_fx\.so"; then
  ACTIVE="attached"
else
  ACTIVE="not attached"
fi
[ "$STATE" = "1" ] && EN="enabled" || EN="disabled"
echo "persist.v4a.enabled=$STATE ($EN)"
echo "effect: $ACTIVE"

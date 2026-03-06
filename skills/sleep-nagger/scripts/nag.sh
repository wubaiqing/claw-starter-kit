#!/usr/bin/env bash
set -euo pipefail

TZ_NAME="Asia/Shanghai"
STATE_DIR="${OPENCLAW_WORKSPACE:-.}/.state/sleep-nagger"
# If the resolved path is relative, anchor it to the script directory to avoid leaking absolute paths.
if [[ "$STATE_DIR" != /* ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  STATE_DIR="$SCRIPT_DIR/../../.state/sleep-nagger"
fi
STATE_FILE="$STATE_DIR/state.json"
mkdir -p "$STATE_DIR"

now_hour="$(TZ="$TZ_NAME" date +%H)"
now_hour=$((10#$now_hour))

# Active window: 23:00–07:59
if ! { [ "$now_hour" -ge 23 ] || [ "$now_hour" -lt 8 ]; }; then
  # Not in nag window
  exit 1
fi

# Define the "sleep night" date key: after midnight belongs to previous date until 07:59
sleep_date="$(TZ="$TZ_NAME" date +%F)"
if [ "$now_hour" -lt 8 ]; then
  sleep_date="$(TZ="$TZ_NAME" date -d 'yesterday' +%F 2>/dev/null || TZ="$TZ_NAME" python3 - <<'PY'
import datetime
from zoneinfo import ZoneInfo
now=datetime.datetime.now(ZoneInfo('Asia/Shanghai'))
print((now.date()-datetime.timedelta(days=1)).isoformat())
PY
)"
fi

count=0
if [ -f "$STATE_FILE" ]; then
  # shell-safe parse (very small json)
  last_date="$(python3 - <<PY
import json
try:
  d=json.load(open('$STATE_FILE'))
  print(d.get('sleep_date',''))
except Exception:
  print('')
PY
)"
  last_count="$(python3 - <<PY
import json
try:
  d=json.load(open('$STATE_FILE'))
  print(int(d.get('count',0)))
except Exception:
  print(0)
PY
)"
  if [ "$last_date" = "$sleep_date" ]; then
    count="$last_count"
  fi
fi

count=$((count+1))

python3 - <<PY > "$STATE_FILE"
import json
json.dump({"sleep_date": "$sleep_date", "count": $count}, open("$STATE_FILE","w"), ensure_ascii=False)
PY

# Escalation lines (cap at 5)
level=$count
if [ "$level" -gt 5 ]; then level=5; fi

case "$level" in
  1) echo "现在已经 23:00 以后了，先收工吧。去洗漱，准备睡觉。" ;;
  2) echo "别聊了，真的该睡了。明天再继续，效率更高。" ;;
  3) echo "还在发？停。把手机放下，关灯睡觉。" ;;
  4) echo "最后提醒一次：你再继续熬夜我就要更凶了。现在立刻睡。" ;;
  5) echo "够了。别发了。睡觉。" ;;
esac

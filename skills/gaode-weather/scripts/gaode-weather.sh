#!/usr/bin/env bash
set -euo pipefail

CITY_CODE="${1:-110114}"  # 昌平 110114
KEY="${AMAP_WEATHER_KEY:-}"

if [[ -z "$KEY" ]]; then
  echo "AMAP_WEATHER_KEY 未设置（请在 OpenClaw 运行环境的 .env 或环境变量中设置）" >&2
  exit 2
fi

URL="https://restapi.amap.com/v3/weather/weatherInfo?city=${CITY_CODE}&extensions=base&output=JSON&key=${KEY}"

json="$(curl -fsSL --connect-timeout 5 --max-time 8 "$URL" 2>/dev/null || true)"
if [[ -z "$json" ]]; then
  echo "高德天气接口请求失败（空响应/超时）" >&2
  exit 3
fi

# Parse with python (avoid jq dependency)
# NOTE: use python3 -c so stdin can carry JSON (python3 - with heredoc would consume stdin as script).
printf '%s' "$json" | python3 -c '
import json, sys
raw=sys.stdin.read()
try:
    data=json.loads(raw)
except Exception:
    print("高德天气解析失败（JSONDecodeError）", file=sys.stderr)
    sys.exit(4)

if str(data.get("status","")) != "1":
    info=data.get("info") or "unknown"
    infocode=data.get("infocode") or ""
    print(f"高德天气接口返回失败：{info} {infocode}".strip(), file=sys.stderr)
    sys.exit(5)

lives=data.get("lives") or []
if not lives:
    print("高德天气无 lives 数据", file=sys.stderr)
    sys.exit(6)

w=lives[0]
province=w.get("province") or ""
city=w.get("city") or ""
weather=w.get("weather") or ""
temp=w.get("temperature") or ""
hum=w.get("humidity") or ""
wd=w.get("winddirection") or ""
wp=w.get("windpower") or ""
rt=w.get("reporttime") or ""

loc="·".join([x for x in [province, city] if x]) or "天气"
parts=[f"{loc}：{weather} {temp}°C".strip()]
extra=[]
if hum:
    extra.append(f"湿度 {hum}%")
if wd or wp:
    extra.append(f"风 {wd} {wp}级".strip())
if extra:
    parts.append("｜".join(extra))
if rt:
    parts.append(f"（高德 {rt}）")

print(" ".join(parts))
'

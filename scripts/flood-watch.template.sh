#!/usr/bin/env bash
# TEMPLATE flood / overload watcher.
# Fill YOUR_* placeholders. Do NOT commit real tokens or chat IDs.
#
# Signals (tune to your host):
#   - request rate from nginx access log
#   - established TCP connections on the public port
#   - 1-minute load average
#   - count of 429/503 responses in the last window
#
# On alert: POST a short message to a webhook (Telegram Bot API example below).
set -euo pipefail

ACCESS_LOG="${ACCESS_LOG:-/var/log/nginx/access.log}"
PUBLIC_PORT="${PUBLIC_PORT:-80}"
REQ_PER_SEC_THRESH="${REQ_PER_SEC_THRESH:-80}"
CONN_THRESH="${CONN_THRESH:-200}"
LOAD_THRESH="${LOAD_THRESH:-12}"
HTTP_ERR_THRESH="${HTTP_ERR_THRESH:-40}"
COOLDOWN_SEC="${COOLDOWN_SEC:-900}"
STATE_FILE="${STATE_FILE:-/var/run/flood-watch.state}"

# Optional Telegram notify (leave empty to skip)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"   # YOUR_BOT_TOKEN
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"       # YOUR_CHAT_ID

now="$(date +%s)"
if [ -f "$STATE_FILE" ]; then
  last="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
  if [ $((now - last)) -lt "$COOLDOWN_SEC" ]; then
    exit 0
  fi
fi

# Naive samples — replace with your preferred metrics source
req_rate="$(tail -n 200 "$ACCESS_LOG" 2>/dev/null | wc -l || echo 0)"
conns="$(ss -Htan state established "( sport = :${PUBLIC_PORT} )" 2>/dev/null | wc -l || echo 0)"
load1="$(cut -d' ' -f1 /proc/loadavg)"
err_count="$(tail -n 500 "$ACCESS_LOG" 2>/dev/null | grep -cE ' (429|503) ' || true)"

signals=0
[ "$req_rate" -ge "$REQ_PER_SEC_THRESH" ] && signals=$((signals + 1))
[ "$conns" -ge "$CONN_THRESH" ] && signals=$((signals + 1))
awk -v l="$load1" -v t="$LOAD_THRESH" 'BEGIN{exit !(l+0 >= t)}' && signals=$((signals + 1))
[ "$err_count" -ge "$HTTP_ERR_THRESH" ] && signals=$((signals + 1))

if [ "$signals" -lt 2 ]; then
  exit 0
fi

msg="ALERT: possible flood on $(hostname) — req_tail=${req_rate} conns=${conns} load1=${load1} err=${err_count}"
echo "$msg"

if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
  curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${msg}" >/dev/null || true
fi

echo "$now" > "$STATE_FILE"

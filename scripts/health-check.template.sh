#!/usr/bin/env bash
# Checks services and HTTP endpoints, then alerts Telegram on failure.
# Config in /etc/health-check.env: TG_TOKEN, TG_CHAT, SERVICES, URLS (space-separated).
set -euo pipefail
# shellcheck source=/dev/null
source /etc/health-check.env
fail=()
for s in $SERVICES; do systemctl is-active --quiet "$s" || fail+=("service $s down"); done
for u in $URLS; do code=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$u" || echo 000); [[ $code =~ ^(2|3) ]] || fail+=("$u -> $code"); done
disk=$(df --output=pcent / | tail -1 | tr -dc 0-9); (( disk > 90 )) && fail+=("disk ${disk}%")
if ((${#fail[@]})); then
  msg="⚠️ $(hostname): $(printf '%s; ' "${fail[@]}")"
  printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$TG_TOKEN" \
    | curl -s -m 10 -K - -d chat_id="$TG_CHAT" --data-urlencode text="$msg" >/dev/null
  exit 1
fi

#!/usr/bin/env bash
# Refresh nginx real_ip allowlist from Cloudflare's published ranges.
# Usage: OUT=/etc/nginx/cloudflare-ips.conf ./update-cloudflare-ips.sh && nginx -t && systemctl reload nginx
# The file is replaced only if both lists download and every line is a valid CIDR,
# so a failed or tampered download never leaves nginx with a broken or empty allowlist.
set -euo pipefail

OUT="${OUT:-/etc/nginx/cloudflare-ips.conf}"
MIN_RANGES="${MIN_RANGES:-10}"
TMP="$(mktemp)"
trap 'rm -f "$TMP" "$TMP.count"' EXIT

v4_re='^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$'
v6_re='^[0-9a-fA-F:]+/[0-9]{1,3}$'

fetch() { curl -fsSL --proto '=https' --max-time 15 --retry 2 "$1"; }

emit() {
  local url="$1" re="$2" cidr n=0 body
  body="$(fetch "$url")"
  while read -r cidr; do
    [[ -z "$cidr" ]] && continue
    [[ "$cidr" =~ $re ]] || { echo "invalid range from $url: $cidr" >&2; exit 1; }
    echo "set_real_ip_from $cidr;"
    n=$((n + 1))
  done <<<"$body"
  echo "$n" >&3
}

{
  echo "# Auto-generated $(date -u +%Y-%m-%dT%H:%MZ). Do not edit by hand."
  echo
  echo "# IPv4"
  emit https://www.cloudflare.com/ips-v4 "$v4_re"
  echo
  echo "# IPv6"
  emit https://www.cloudflare.com/ips-v6 "$v6_re"
  echo
  echo "real_ip_header CF-Connecting-IP;"
  echo "real_ip_recursive on;"
} >"$TMP" 3>"$TMP.count"

total=$(awk '{s+=$1} END {print s+0}' "$TMP.count")
rm -f "$TMP.count"
if (( total < MIN_RANGES )); then
  echo "only $total ranges downloaded (expected at least $MIN_RANGES); keeping $OUT" >&2
  exit 1
fi

chmod 644 "$TMP"
mv "$TMP" "$OUT"
echo "updated $OUT ($total ranges)"

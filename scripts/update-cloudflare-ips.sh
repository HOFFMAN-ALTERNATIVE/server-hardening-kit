#!/usr/bin/env bash
# Refresh nginx real_ip allowlist from Cloudflare's published ranges.
# Usage: OUT=/etc/nginx/cloudflare-ips.conf ./update-cloudflare-ips.sh && nginx -t && systemctl reload nginx
set -euo pipefail

OUT="${OUT:-/etc/nginx/cloudflare-ips.conf}"
TMP="$(mktemp)"

{
  echo "# Auto-generated $(date -u +%Y-%m-%dT%H:%MZ) — do not edit by hand"
  echo
  echo "# IPv4"
  curl -fsSL https://www.cloudflare.com/ips-v4 | while read -r cidr; do
    [ -n "$cidr" ] && echo "set_real_ip_from $cidr;"
  done
  echo
  echo "# IPv6"
  curl -fsSL https://www.cloudflare.com/ips-v6 | while read -r cidr; do
    [ -n "$cidr" ] && echo "set_real_ip_from $cidr;"
  done
  echo
  echo "real_ip_header CF-Connecting-IP;"
  echo "real_ip_recursive on;"
} > "$TMP"

mv "$TMP" "$OUT"
chmod 644 "$OUT"
echo "updated $OUT"

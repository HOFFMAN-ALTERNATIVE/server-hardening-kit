# 0002. Generate the Cloudflare real-IP allowlist and refuse bad downloads

Status: accepted
Date: 2026-10-17

## Context
Behind Cloudflare, nginx sees Cloudflare's addresses, not the client's. Rate limits
and logs need the real client IP, which arrives in `CF-Connecting-IP`. That header is
only trustworthy from Cloudflare's own ranges, and those ranges change over time.

## Options
1. Trust `CF-Connecting-IP` from any source: one line, but any client can spoof its IP
   and walk around every rate limit.
2. Paste the current ranges into the config once: correct today, silently wrong after
   Cloudflare adds a range.
3. Download Cloudflare's published v4 and v6 lists on a timer, validate them, and
   regenerate `set_real_ip_from` lines.

## Decision
Option 3, with strict checks. The script writes to a temp file and replaces the live
file only when both downloads succeed, every line matches a CIDR pattern, and at
least `MIN_RANGES` (default 10) ranges came back.

## Consequences
- A failed or tampered download keeps the previous file, so nginx never ends up with
  an empty or broken allowlist.
- The example systemd unit runs weekly with a random delay, then `nginx -t` before
  `reload`, so a bad file never takes effect.
- The CIDR regex checks shape, not that octets are in range. A malformed but
  well-shaped line would fail at `nginx -t` instead.
- The origin must still block direct access from non-Cloudflare addresses at the
  firewall. This list only decides whose header is believed.

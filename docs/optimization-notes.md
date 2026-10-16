# Optimization notes (generic)

## nginx

- Keep static assets immutable with long `Cache-Control` when hashed; short or no-cache for HTML shells.
- Separate rate-limit zones for public pages vs auth vs expensive API routes.
- Prefer `limit_conn` together with `limit_req` so a single IP cannot open unlimited connections.
- Log real client IPs when behind Cloudflare (`real_ip` + published ranges), otherwise rate limits punish the proxy.

## systemd

- Use timers with `Persistent=true` for backups and IP-list refresh so missed windows catch up after reboot.
- `Nice` / `IOSchedulingClass` on backup jobs reduce impact on the live site.
- Keep application processes bound to `127.0.0.1` and expose only the reverse proxy.

## Containers

- `read_only: true` plus small `tmpfs` mounts for nginx cache/run directories reduce writable surface.
- Healthchecks on a cheap local `/healthz` beat scraping the public site.

## Cloudflare (edge)

- Always Use HTTPS, Bot Fight Mode, and a simple rate-limit rule for flood spikes.
- Origin should accept traffic from Cloudflare IP ranges only (firewall), not the open internet.
- Prefer Full (strict) SSL once the origin has a valid certificate; Flexible leaves origin HTTP in the clear between CF and the box.

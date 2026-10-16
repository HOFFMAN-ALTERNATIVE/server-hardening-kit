# Hardening checklist (copy into a project)

## Edge

- [ ] DNS proxied through Cloudflare (orange cloud)
- [ ] Always Use HTTPS on
- [ ] Bot Fight / WAF basics on
- [ ] Rate-limit rule for flood spikes
- [ ] Origin firewall allows only Cloudflare IP ranges on HTTP(S) ports

## Origin

- [ ] Default-deny host firewall; allow SSH from known sources only
- [ ] Application backends listen on 127.0.0.1 only
- [ ] Reverse proxy rate limits + connection limits
- [ ] Real client IP from `CF-Connecting-IP` when proxied
- [ ] fail2ban (or equivalent) on SSH and auth endpoints
- [ ] No public exposure of admin/debug/metrics ports
- [ ] TLS on origin when using Cloudflare Full (strict)

## Secrets & ops

- [ ] No secrets in git; env or secret store only
- [ ] Automated backups with retention and an off-box copy
- [ ] Alerting for flood / overload with a human kill-switch path
- [ ] Kernel and package updates scheduled

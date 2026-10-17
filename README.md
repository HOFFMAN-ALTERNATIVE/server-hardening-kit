# server-hardening-kit

[![ci](https://github.com/HOFFMAN-ALTERNATIVE/server-hardening-kit/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/HOFFMAN-ALTERNATIVE/server-hardening-kit/actions/workflows/shellcheck.yml)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

Templates for hardening and running a small Linux VPS behind Cloudflare: nginx rate limits and real-IP handling, backup rotation, flood detection with Telegram alerts, service health checks, systemd timers, a non-root static-site container and a hardening checklist.

Every environment-specific value is a `YOUR_*` placeholder or an environment variable, and no secrets live in the repo. CI runs ShellCheck on every script and builds the static-site container, runs `nginx -t`, starts it read-only with all capabilities dropped, and checks the health endpoint, security headers and that it does not run as root.

The trade-off: these are templates, not a configuration-management tool. You copy, edit and own them. For more than a few servers, move the same decisions into Ansible or similar.

## Structure

```
nginx/        site.example.conf, rate-limit.snippet.conf, cloudflare-ips.example.conf
scripts/      rotate-backups.sh, update-cloudflare-ips.sh,
              flood-watch.template.sh, health-check.template.sh
systemd/      .service / .timer examples for backups, Cloudflare IP refresh, flood watch
docker/       Dockerfile.static, static.conf and a compose example for a non-root nginx static site
checklists/   hardening.md: SSH, firewall, updates, users, logging
docs/         optimization-notes.md, systemd-patterns.md, ollama-hygiene.md
```

## Quick start

```bash
git clone https://github.com/HOFFMAN-ALTERNATIVE/server-hardening-kit.git
cd server-hardening-kit

# 1. Walk through the checklist first
less checklists/hardening.md

# 2. nginx: copy the snippets and replace YOUR_* placeholders
sudo cp nginx/rate-limit.snippet.conf /etc/nginx/snippets/
sudo ./scripts/update-cloudflare-ips.sh        # generates real-IP allowlist
sudo nginx -t && sudo systemctl reload nginx

# 3. Scripts + timers
sudo install -m 0755 scripts/rotate-backups.sh /usr/local/bin/
sudo cp systemd/backup.service.example /etc/systemd/system/backup.service
sudo cp systemd/backup.timer.example   /etc/systemd/system/backup.timer
sudo systemctl daemon-reload && sudo systemctl enable --now backup.timer
```

Alerting scripts read credentials from the environment or an env file (for example `/etc/health-check.env`, mode `0600`) and hand the bot token to curl on stdin, so it never appears in the process list.

## Principles

- Deny by default; expose only what a proxy needs.
- Internal services (databases, local LLM APIs) bind to `127.0.0.1`.
- Secrets stay out of git; configs are templates.
- Every script passes ShellCheck (`shellcheck scripts/*.sh`), enforced in [CI](.github/workflows/shellcheck.yml).
- `update-cloudflare-ips.sh` only replaces the allowlist when both lists download and every line is a valid CIDR.

## Limits

- Debian and Ubuntu with systemd and nginx are assumed.
- The flood-watch and health-check scripts are templates with thresholds you must tune; they are not tested against real traffic in CI.
- `nginx/site.example.conf` contains `YOUR_*` placeholders and will not pass `nginx -t` until you fill them in. The container uses its own `docker/static.conf`.
- Nothing here replaces a WAF or DDoS protection; it assumes Cloudflare (or similar) sits in front.

Security notes: [SECURITY.md](SECURITY.md).

## License

MIT, see [LICENSE](LICENSE).

# server-hardening-kit

![License: MIT](https://img.shields.io/badge/license-MIT-green)

Production-minded templates for hardening and operating a small Linux VPS behind Cloudflare:
nginx rate limiting and real-IP handling, backup rotation, flood detection with Telegram alerts,
service health checks, systemd timers, a minimal static-site container and a hardening checklist.

Everything is **generic**: every environment-specific value is a `YOUR_*` placeholder or an environment variable. No secrets live in this repo.

## Structure

```
nginx/        site.example.conf, rate-limit.snippet.conf, cloudflare-ips.example.conf
scripts/      rotate-backups.sh, update-cloudflare-ips.sh,
              flood-watch.template.sh, health-check.template.sh
systemd/      .service / .timer examples for backups, Cloudflare IP refresh, flood watch
docker/       Dockerfile.static + compose example for an nginx static site
checklists/   hardening.md — SSH, firewall, updates, users, logging
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

Alerting scripts read credentials from environment / an env file (e.g. `/etc/health-check.env`, mode `0600`) — never hard-code them.

## Principles

- Deny by default; expose only what a proxy needs.
- Internal services (databases, local LLM APIs) bind to `127.0.0.1`.
- Secrets stay out of git; configs are templates.
- Every script passes ShellCheck (`shellcheck scripts/*.sh`); a ready workflow lives in `ci/shellcheck.yml`.

## License

MIT — see [LICENSE](LICENSE).

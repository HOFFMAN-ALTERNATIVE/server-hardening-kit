# Security

## Reporting

Use GitHub's private "Report a vulnerability" button on this repository. I aim to reply within 72 hours.

## Threat model

- **Assets:** the VPS, its services, backups, and the Telegram bot token used for alerts.
- **Actors:** internet scanners, floods and scrapers arriving through Cloudflare or hitting the origin directly.
- **Entry points:** nginx on the origin, SSH, the Cloudflare ranges list fetched from the internet.
- **Defaults that matter:** per-IP request and connection limits, real client IP trusted only from Cloudflare ranges, strict security headers, `server_tokens off` in the container config, loopback-only binds for internal services, non-root read-only static container with all capabilities dropped, tokens kept out of argv, Cloudflare ranges validated before they reach nginx.
- **Checklist:** `checklists/hardening.md` covers SSH, firewall, updates, users and logging.

## Not provided

- Origin lock-down to Cloudflare only (firewall rules or authenticated origin pulls). Do this, or attackers can bypass the edge by hitting the origin IP.
- Secret storage beyond `0600` env files.

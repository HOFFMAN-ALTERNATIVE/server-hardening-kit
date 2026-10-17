# 0001. Ship templates with placeholders, not a config-management tool

Status: accepted
Date: 2026-10-17

## Context
The kit collects what a small VPS behind Cloudflare needs: nginx limits, real-IP
handling, backups, alerts and systemd timers. Every server has different hostnames,
thresholds and secrets. The repo is public, so nothing environment-specific may live in it.

## Options
1. An Ansible role: repeatable across hosts, but forces a tool and an inventory on
   people who run one or two servers.
2. Ready-to-run configs with example values: quick to try, but example values get
   deployed as-is, and real values tend to leak back into commits.
3. Templates where every site-specific value is a `YOUR_*` placeholder or an
   environment variable, plus a checklist that explains each step.

## Decision
Option 3. The reader copies, edits and owns each file, and the repo stays free of
anything that identifies a real system.

## Consequences
- Secrets come from the environment or an env file kept outside git. Alert scripts
  pass the bot token to curl on stdin so it does not show in the process list.
- `nginx/site.example.conf` does not pass `nginx -t` until the placeholders are filled,
  so CI tests the container config instead of the template.
- No idempotent re-apply and no drift detection. That is the job of config management.
- Revisit when the same changes have to be applied to more than a few servers.

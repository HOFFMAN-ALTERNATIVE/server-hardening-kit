# systemd patterns

- **oneshot + timer** for backups, IP refreshes, and periodic health scripts.
- Put environment in the unit (or an `EnvironmentFile=` that is *not* committed) rather than hardcoding secrets in scripts.
- `ExecStartPost=` can run `nginx -t` before reload so a bad config never takes effect.

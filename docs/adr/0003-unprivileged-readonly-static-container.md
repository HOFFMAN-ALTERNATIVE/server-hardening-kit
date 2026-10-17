# 0003. Serve static sites from a non-root, read-only nginx container

Status: accepted
Date: 2026-10-17

## Context
Many small servers host a static landing page next to other services. It should be
the least interesting target on the box: no root, no writable filesystem, no
capabilities, and reachable only through the edge proxy.

## Options
1. The official `nginx` image: familiar, but the master process starts as root and
   writes its pid and cache under paths that need a writable root filesystem.
2. A static file server such as Caddy or a small Go binary: fine, but a second web
   server to learn when the host already runs nginx.
3. `nginxinc/nginx-unprivileged`: runs as uid 101 on an unprivileged port and keeps
   pid and temp files under `/tmp`.

## Decision
Option 3. It is still nginx, so the config style matches the host, and it works with
`read_only: true`, a tmpfs on `/tmp` and `cap_drop: [ALL]` without patches.

## Consequences
- The compose example binds to `127.0.0.1` only; the edge proxy faces the internet.
- CI builds the image, runs `nginx -t`, starts it read-only with all capabilities
  dropped, and checks the health endpoint, a security header and that uid is not 0.
- Content is mounted read-only, so updating the site means replacing files on the
  host, not writing inside the container.
- Revisit if the site needs server-side code. This container serves files only.

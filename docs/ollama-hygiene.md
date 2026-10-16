# Ollama hygiene on a shared VPS

- **One config.** Keep a single systemd drop-in. Several drop-ins setting `OLLAMA_HOST` override each other silently.
- **Bind to localhost.** `OLLAMA_HOST=127.0.0.1:11434`. The API has no auth, so never expose it publicly.
- **Restrict origins.** `OLLAMA_ORIGINS=http://127.0.0.1,http://localhost` instead of `*`.
- **Honest tags.** `ollama cp` aliases share one blob. Check `ollama list` for repeated IDs and remove misleading names (`ollama rm`). Disk usage doesn't change, but the confusion goes away.
- **Know what the app uses.** Grep the code for model names before removing any tag.
- **Back up first.** Copy the drop-in directory before editing, then run `daemon-reload` and restart.
- **Verify.** `ss -ltnp | grep 11434` should show 127.0.0.1 only, then send one test `/api/generate` request.

```ini
# /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_ORIGINS=http://127.0.0.1,http://localhost"
Environment="OLLAMA_KEEP_ALIVE=-1"
Environment="OLLAMA_NUM_PARALLEL=1"
```

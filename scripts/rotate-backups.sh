#!/usr/bin/env bash
# Simple dated backup + retention for a directory tree.
# Usage: BACKUP_SRC=/var/www/site BACKUP_DST=/var/backups/site RETAIN_DAYS=14 ./rotate-backups.sh
set -euo pipefail

SRC="${BACKUP_SRC:?set BACKUP_SRC}"
DST="${BACKUP_DST:?set BACKUP_DST}"
RETAIN_DAYS="${RETAIN_DAYS:-14}"
STAMP="$(date +%Y%m%d-%H%M%S)"
NAME="${BACKUP_NAME:-backup}"

mkdir -p "$DST"
ARCHIVE="$DST/${NAME}-${STAMP}.tar.gz"
tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$(basename "$SRC")"
find "$DST" -type f -name "${NAME}-*.tar.gz" -mtime "+${RETAIN_DAYS}" -delete
echo "wrote $ARCHIVE"

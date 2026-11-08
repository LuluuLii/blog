#!/bin/bash
set -euo pipefail

VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
SITE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for directory in notes images; do
  if [[ ! -d "$VAULT/$directory" ]]; then
    echo "Missing source directory: $VAULT/$directory" >&2
    exit 1
  fi
done

placeholders="$(find "$VAULT/notes" "$VAULT/images" -name '*.icloud' -print)"
if [[ -n "$placeholders" ]]; then
  echo "Download iCloud placeholder files before syncing:" >&2
  printf '%s\n' "$placeholders" >&2
  exit 1
fi

# Sync public content only
# Excluded files are removed from the publication copy, including old copies.
rsync -av --delete --delete-excluded --exclude='.DS_Store' \
  --exclude-from="$SITE/.publishignore" "$VAULT/notes/" "$SITE/content/notes/"
rsync -av --delete --exclude='.DS_Store' "$VAULT/images/" "$SITE/content/images/"

echo "Sync complete. Preview: cd $SITE && npx quartz build --serve"

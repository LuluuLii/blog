#!/bin/bash
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
SITE="$HOME/Developer/blog"

# Sync public content only
rsync -av --delete "$VAULT/notes/"  "$SITE/content/notes/"
rsync -av --delete "$VAULT/images/" "$SITE/content/images/"

echo "Sync complete. Preview: cd $SITE && npx quartz build --serve"

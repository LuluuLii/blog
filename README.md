# Lu's Log

Personal knowledge base powered by [Quartz v4](https://quartz.jzhao.xyz/), synced from Obsidian vault.

**Live site**: https://luluulii.github.io/blog/

## Architecture

```
Obsidian Vault (iCloud)                   This Repo (~/Developers/blog)
  notes/       ──rsync──>  content/notes/
  images/      ──rsync──>  content/images/
  personal/    (not synced)
  Records/     (not synced)
  schedule/    (not synced)
  projects/    (not synced, selective later)
```

## Daily Workflow

### 1. Write in Obsidian

Edit notes as usual. For new notes, add frontmatter:

```yaml
---
date: 2026-02-25
---
```

To hide a draft from the site:

```yaml
---
date: 2026-02-25
draft: true
---
```

### 2. Sync & Publish

```bash
# Sync content from Obsidian vault
~/Developers/blog/sync.sh

# (Optional) Preview locally
cd ~/Developers/blog && npx quartz build --serve
# Then open http://localhost:8080

# Commit and push
cd ~/Developers/blog
git add -A
git commit -m "update notes"
git push
```

GitHub Actions will automatically build and deploy to Pages.

### 3. Add a project to publish (future)

Edit `sync.sh` and add a line:

```bash
rsync -av "$VAULT/projects/YourProject/" "$SITE/content/projects/YourProject/"
```

## Key Files

| File | Purpose |
|------|---------|
| `sync.sh` | Syncs public content from Obsidian vault |
| `quartz.config.ts` | Site title, locale, plugins, theme |
| `quartz.layout.ts` | Page layout (sidebar, footer, recent notes) |
| `quartz/styles/custom.scss` | Custom CSS overrides |
| `.github/workflows/deploy.yml` | CI/CD: build Quartz + deploy to Pages |
| `content/index.md` | Homepage content |

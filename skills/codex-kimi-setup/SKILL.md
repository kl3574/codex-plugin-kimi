---
name: codex-kimi-setup
description: Use when installing, enabling, or diagnosing codex-plugin-kimi.
---

# Codex Kimi Setup

Use this skill when the user asks to install, enable, or diagnose this plugin.

## Commands

- `codex-kimi-review setup`: checks Node, Git, Kimi CLI, and `kimi doctor`.
- `codex-kimi-review install-bin`: installs a `codex-kimi-review` shim into a PATH directory.
- `codex-kimi-review doctor`: checks plugin files and job directory.
- `codex-kimi-review doctor --probe-runtime`: runs a minimal real `kimi -p`.
- `codex-kimi-review enable`: registers the local plugin in Codex config.

## Verification

After configuration changes, run:

```bash
codex-kimi-review doctor --json
```

If the local helper is not installed globally, use:

```bash
node <plugin-root>/scripts/codex-kimi-review.mjs doctor --json
```

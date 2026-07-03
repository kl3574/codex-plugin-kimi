---
name: using-codex-plugin-kimi
description: Use when configuring, diagnosing, or explaining the codex-plugin-kimi Codex-to-Kimi review plugin.
---

# Using Codex Plugin Kimi

Use this skill when the user asks to run, configure, diagnose, or explain
`codex-plugin-kimi`.

## Workflow

1. Confirm the active plugin root is `/home/lkx/codex-plugin-kimi` unless the
   user names another path.
2. Use `codex-kimi-review setup` for installation checks.
3. Use `codex-kimi-review doctor` for plugin health checks.
4. Use `codex-kimi-review review` or a named review lane for read-only review.
5. Never modify repository files as part of a Kimi review command.

## Helper Fallback

If `codex-kimi-review` is not on PATH, run:

```bash
node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs <command>
```

## Notes

This plugin direction is Codex to Kimi Code. It is not a Kimi Code plugin that
calls Codex.

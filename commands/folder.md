---
description: Run a read-only Kimi Code review over a non-Git or arbitrary folder snapshot.
---

# /codex-plugin-kimi:folder

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Review an arbitrary folder by creating a bounded text snapshot and sending it
to Kimi Code. Large files and binary files are skipped by the helper.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:folder`.

- Preferred:
  `codex-kimi-review folder <path> <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs folder <path> <user-arguments>`

Useful flags:

- `--preset quick|ship|security|research|deep` - choose a review preset.
- `--exclude <basename>` - exclude a file or directory basename.
- `--background` - run detached.

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

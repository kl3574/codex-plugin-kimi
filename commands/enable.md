---
description: Register this local plugin in Codex config as a personal marketplace plugin.
---

# /codex-plugin-kimi:enable

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Ask the helper to add a local marketplace entry and enabled plugin entry to
Codex config. This only edits Codex configuration; it does not run a review.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:enable`.

- Preferred:
  `codex-kimi-review enable <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs enable <user-arguments>`

Useful flags:

- `--dry-run` - show the TOML block that would be added.
- `--json` - return machine-readable status.
- `--config <path>` - use a non-default Codex config path.

## Verification

If enable exits non-zero, report the failure exactly and stop.

## Summary

Return the helper stdout verbatim.

---
description: Install the codex-kimi-review helper shim into a PATH directory.
---

# /codex-plugin-kimi:install-bin

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is already available on PATH.
2. If it is not available, locate the installed plugin root from `codex plugin list`
   and run `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Install or refresh a small executable shim for `codex-kimi-review`. This does
not run a review and does not modify project files.

## Commands

Use the exact argument tail the user supplied after
`/codex-plugin-kimi:install-bin`.

- Preferred:
  `codex-kimi-review install-bin <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs install-bin <user-arguments>`

Useful flags:

- `--target <path>` - install the shim at a specific path.
- `--dry-run` - show the target without writing.
- `--json` - return machine-readable status.

## Verification

After install, run `command -v codex-kimi-review` and
`codex-kimi-review doctor --json`.

## Summary

Return the helper stdout verbatim.

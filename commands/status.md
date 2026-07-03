---
description: Show running and recent Kimi review jobs for the current workspace.
---

# /codex-plugin-kimi:status

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Run the helper in status mode and return the result.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:status`.

- Preferred:
  `codex-kimi-review status <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs status <user-arguments>`

Useful flags:

- `--json` - return machine-readable job data.

## Verification

Treat the helper output as the source of truth for job state.

## Summary

Return the helper stdout verbatim.

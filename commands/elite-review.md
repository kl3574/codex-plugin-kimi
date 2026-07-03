---
description: Run a ship/no-ship Kimi Code review against the current workspace.
---

# /codex-plugin-kimi:elite-review

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Run a high-rigor Kimi review that classifies findings as blocking, important,
or minor. The helper keeps the review read-only.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:elite-review`.

- Preferred:
  `codex-kimi-review elite-review <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs elite-review <user-arguments>`

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

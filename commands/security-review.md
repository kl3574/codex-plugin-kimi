---
description: Run a security-focused Kimi Code review against the current workspace.
---

# /codex-plugin-kimi:security-review

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Run a security-focused Kimi review looking for concrete exploitable issues.
The helper keeps the review read-only.

## Commands

Use the exact argument tail the user supplied after
`/codex-plugin-kimi:security-review`.

- Preferred:
  `codex-kimi-review security-review <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs security-review <user-arguments>`

Useful flags:

- `--preset security` - equivalent security preset for the default review lane.
- `--background` - run detached.

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

---
description: Run a skeptical read-only Kimi Code review against the current workspace.
---

# /codex-plugin-kimi:adversarial-review

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Run a skeptical Kimi review focused on assumptions, edge cases, regressions,
rollback risk, and test gaps. The helper keeps the review read-only.

## Commands

Use the exact argument tail the user supplied after
`/codex-plugin-kimi:adversarial-review`.

- Preferred:
  `codex-kimi-review adversarial-review <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs adversarial-review <user-arguments>`

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

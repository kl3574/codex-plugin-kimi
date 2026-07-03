---
description: Run a broad deep Kimi Code review against the current workspace.
---

# /codex-plugin-kimi:deep-review

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Run a broad Kimi review covering architecture, correctness, tests, security,
maintainability, release safety, and blind spots. The helper keeps the review
read-only.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:deep-review`.

- Preferred:
  `codex-kimi-review deep-review <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs deep-review <user-arguments>`

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

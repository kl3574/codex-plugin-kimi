---
description: Print the result for a completed Kimi review background job.
---

# /codex-plugin-kimi:result

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Print the captured stdout and stderr for one background job.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:result`.

- Preferred:
  `codex-kimi-review result <job-id> <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs result <job-id> <user-arguments>`

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

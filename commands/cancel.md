---
description: Cancel a running Kimi review background job.
---

# /codex-plugin-kimi:cancel

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Cancel one running background job through the helper.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:cancel`.

- Preferred:
  `codex-kimi-review cancel <job-id> <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs cancel <job-id> <user-arguments>`

## Verification

Treat the helper output as the source of truth for cancellation state.

## Summary

Return the helper stdout verbatim.

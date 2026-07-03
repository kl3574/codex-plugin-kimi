---
description: Check whether Kimi Code CLI and local review helper prerequisites are installed.
---

# /codex-plugin-kimi:setup

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Run setup diagnostics for the local Codex to Kimi review workflow.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:setup`.

- Preferred:
  `codex-kimi-review setup <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs setup <user-arguments>`

Useful flags:

- `--json` - return machine-readable diagnostics.

## Verification

If setup exits non-zero, report the failure exactly and stop.

## Summary

Return the helper stdout verbatim.

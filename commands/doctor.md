---
description: Run local diagnostics for the Codex to Kimi review plugin.
---

# /codex-plugin-kimi:doctor

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from the installed plugin root with
   `node <plugin-root>/scripts/codex-kimi-review.mjs`.

## Plan

Run plugin diagnostics, including manifest checks, command and skill directory
checks, job directory checks, Git availability, and Kimi Code availability.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:doctor`.

- Preferred:
  `codex-kimi-review doctor <user-arguments>`
- Fallback:
  `node <plugin-root>/scripts/codex-kimi-review.mjs doctor <user-arguments>`

Useful flags:

- `--json` - return machine-readable diagnostics.
- `--probe-runtime` - run a minimal real `kimi -p` prompt.
- `--timeout-ms <n>` - cap the optional runtime probe.

## Verification

If doctor exits non-zero, report the failure exactly and stop.

## Summary

Return the helper stdout verbatim.

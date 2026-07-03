---
description: Run a read-only Kimi Code review against the current Git workspace.
---

# /codex-plugin-kimi:review

## Preflight

1. Prefer the helper binary `codex-kimi-review` if it is available on PATH.
2. If it is not available, run it from this checkout with
   `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs`.

## Plan

Delegate review context collection and Kimi Code execution to the helper.
The helper asks Kimi to perform read-only review only.

## Commands

Use the exact argument tail the user supplied after `/codex-plugin-kimi:review`.

- Preferred:
  `codex-kimi-review review <user-arguments>`
- Fallback:
  `node /home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs review <user-arguments>`

Useful flags:

- `--path <dir>` - target directory.
- `--base <ref>` - review branch diff against a base ref.
- `--commit <sha>` - review one commit.
- `--scope auto|working-tree|branch|directory` - choose context mode.
- `--preset quick|ship|security|research|deep` - route to a review preset.
- `--background` - run detached and fetch results later.
- `--model <name>` - pass a model alias to `kimi -m`.
- `--system-prompt-extra <text>` - append reviewer guidance.
- `--exclude <basename>` - exclude names from directory snapshots.

## Verification

If the helper exits non-zero, report that failure exactly and stop.

## Summary

Return the helper stdout verbatim.

## Next Steps

For a harsher pass, suggest `/codex-plugin-kimi:adversarial-review`,
`/codex-plugin-kimi:elite-review`, `/codex-plugin-kimi:deep-review`, or
`/codex-plugin-kimi:security-review`.

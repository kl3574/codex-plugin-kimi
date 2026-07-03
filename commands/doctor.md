---
name: doctor
description: Diagnose Codex Plugin Kimi installation and runtime readiness.
---

Run this Bash command and return the full output:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" doctor $ARGUMENTS
```

Use `$ARGUMENTS` as provided. If the user asks for a real runtime probe, pass `--probe-runtime`; otherwise leave it out to avoid spending model quota.

Do not modify files.

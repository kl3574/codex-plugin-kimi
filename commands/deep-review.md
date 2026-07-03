---
name: deep-review
description: Run a deep Codex review with broad risk analysis.
---

Run this Bash command and return the full output:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" deep-review $ARGUMENTS
```

For large diffs, suggest `--background`. Do not modify files or apply fixes from the review command.

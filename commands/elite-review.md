---
name: elite-review
description: Run an exhaustive Codex ship/no-ship review.
---

Run this Bash command and return the full output:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" elite-review $ARGUMENTS
```

Do not modify files or apply fixes from the review command.

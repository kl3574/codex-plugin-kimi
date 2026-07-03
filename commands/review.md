---
name: review
description: Run a Codex review on current changes.
---

Run this Bash command and return the full output:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" review $ARGUMENTS
```

Do not modify files or apply fixes from the review command.

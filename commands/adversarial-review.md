---
name: adversarial-review
description: Run a skeptical Codex adversarial review.
---

Run this Bash command and return the full output:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" adversarial-review $ARGUMENTS
```

Do not modify files or apply fixes from the review command.

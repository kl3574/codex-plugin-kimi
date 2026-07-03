---
name: using-codex-plugin-kimi
description: Session-start guidance for the Codex Plugin Kimi review workflows.
---

# Using Codex Plugin Kimi

This plugin lets Kimi Code call the local OpenAI Codex CLI for read-only review workflows.

Use the helper script for all plugin actions:

```bash
PLUGIN_ROOT="${KIMI_PLUGIN_ROOT:-${KIMI_CODE_HOME:-$HOME/.kimi-code}/plugins/managed/codex-plugin-kimi}"
node "$PLUGIN_ROOT/scripts/codex-kimi-review.mjs" <command> [args]
```

Available commands:

- `setup`
- `doctor`
- `review`
- `adversarial-review`
- `elite-review`
- `deep-review`
- `security-review`
- `folder`
- `status`
- `result`
- `cancel`

Review commands are read-only by default. They must not apply fixes. If the user wants fixes, treat that as a separate follow-up task after reporting Codex findings.

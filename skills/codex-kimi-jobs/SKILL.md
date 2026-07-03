---
name: codex-kimi-jobs
description: Manage Codex Plugin Kimi background review jobs with status, result, and cancel.
---

# Codex Kimi Jobs

Use these commands for background jobs:

```bash
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" status $ARGUMENTS
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" result $ARGUMENTS
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" cancel $ARGUMENTS
```

Treat the helper's job state as authoritative.

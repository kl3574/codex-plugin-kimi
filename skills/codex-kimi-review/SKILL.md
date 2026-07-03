---
name: codex-kimi-review
description: Run Codex review, adversarial, elite, deep, security, or folder review workflows from Kimi Code.
---

# Codex Kimi Review

Use when the user asks Kimi Code to call Codex for code review.

Default command:

```bash
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" review $ARGUMENTS
```

Common variants:

```bash
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" review --base main
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" adversarial-review --focus "challenge error handling"
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" elite-review --preset ship --base main
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" security-review
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" deep-review --background
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" folder ./docs --preset research
```

Rules:

1. Return helper stdout directly.
2. Do not apply fixes from inside this review workflow.
3. If a background job is started, tell the user the job id and use `status` or `result` for follow-up.

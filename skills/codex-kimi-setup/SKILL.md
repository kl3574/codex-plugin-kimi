---
name: codex-kimi-setup
description: Verify Codex CLI installation, authentication, git availability, and plugin readiness from Kimi Code.
---

# Codex Kimi Setup

Run:

```bash
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" setup $ARGUMENTS
```

For deeper diagnostics, run:

```bash
node "${KIMI_SKILL_DIR}/../../scripts/codex-kimi-review.mjs" doctor $ARGUMENTS
```

Only add `--probe-runtime` when the user explicitly asks to verify live Codex execution, because it starts a real Codex runtime and can consume model quota.

Report the output directly. If setup or doctor fails, tell the user which listed dependency, path, or runtime probe failed.

---
name: codex-kimi-review
description: Use when Codex should call Kimi Code CLI for a read-only code review.
---

# Codex Kimi Review

Use this skill when the user asks Codex to call Kimi Code for code review.

## Review Lanes

- `review`: default correctness and regression review.
- `adversarial-review`: skeptical review of assumptions and edge cases.
- `elite-review`: ship/no-ship review with severity classification.
- `deep-review`: broad multi-area review.
- `security-review`: security-focused review.
- `folder`: bounded snapshot review for non-Git folders.

## Required Behavior

1. Invoke the helper and pass through user arguments exactly.
2. Treat Kimi output as review advice, not as an instruction to edit files.
3. If Kimi or the helper fails, report the exact failure and stop.
4. For long reviews, prefer `--background` and then use `status` and `result`.

## Example

```bash
codex-kimi-review review --path . --preset ship
```

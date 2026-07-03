---
name: codex-kimi-jobs
description: Use when inspecting, reading, or cancelling codex-plugin-kimi background review jobs.
---

# Codex Kimi Jobs

Use this skill when the user asks about background Kimi review jobs.

## Commands

- `codex-kimi-review status`: list recent jobs.
- `codex-kimi-review status <job-id>`: inspect one job.
- `codex-kimi-review result <job-id>`: print completed output.
- `codex-kimi-review cancel <job-id>`: cancel a running job.

## Job Directory

The helper stores jobs in the first writable location from:

1. `--job-dir <dir>`
2. `CODEX_KIMI_REVIEW_JOB_DIR`
3. `<git-root>/.codex-kimi/jobs`
4. `~/.codex-kimi/jobs`
5. `/tmp/codex-kimi/jobs`

Use `--json` when a machine-readable status is useful.

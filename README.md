# Codex Plugin Kimi

Kimi Code plugin for running OpenAI Codex CLI review workflows from inside Kimi Code.

This is the Kimi-side mirror of the `codex-plugin-cc` workflow family: where `codex-plugin-cc` lets Codex call Claude Code, this plugin lets Kimi Code call Codex.

## Requirements

- Kimi Code CLI.
- Node.js 18.18 or newer.
- Git on `PATH`.
- OpenAI Codex CLI on `PATH`.
- Codex CLI authenticated locally with `codex login`.

## Install

From local checkout:

```text
/plugins install /home/lkx/codex-plugin-kimi
/reload
```

From GitHub after sync:

```text
/plugins install https://github.com/kl3574/codex-plugin-kimi
/reload
```

Kimi Code copies local plugin installs to `$KIMI_CODE_HOME/plugins/managed/codex-plugin-kimi/`. Reinstall or use `/plugins reload` after changing the source checkout.

## Commands

```text
/codex-plugin-kimi:setup
/codex-plugin-kimi:doctor
/codex-plugin-kimi:doctor --probe-runtime
/codex-plugin-kimi:review
/codex-plugin-kimi:review --base main
/codex-plugin-kimi:review --preset ship --base main
/codex-plugin-kimi:adversarial-review --focus "challenge retry logic"
/codex-plugin-kimi:elite-review --background
/codex-plugin-kimi:deep-review --background
/codex-plugin-kimi:security-review
/codex-plugin-kimi:folder ./docs --preset research
/codex-plugin-kimi:status
/codex-plugin-kimi:result <job-id>
/codex-plugin-kimi:cancel <job-id>
```

The helper can also be run directly:

```bash
node scripts/codex-kimi-review.mjs doctor
node scripts/codex-kimi-review.mjs doctor --probe-runtime
node scripts/codex-kimi-review.mjs review --base main
```

## Review Lanes

| Lane | Implementation |
| --- | --- |
| `review` | Uses native `codex review` for plain Git diffs when possible; falls back to `codex exec` for focused prompts, directory snapshots, and known native-review runtime failures. |
| `adversarial-review` | Uses `codex exec --sandbox read-only` with a skeptical review prompt. |
| `elite-review` | Uses `codex exec --sandbox read-only` with a ship/no-ship prompt. |
| `deep-review` | Uses `codex exec --sandbox read-only` with a broad multi-pass prompt. |
| `security-review` | Uses `codex exec --sandbox read-only` with a security/CWE/OWASP prompt. |
| `folder` | Builds a bounded text snapshot and runs Codex with `--skip-git-repo-check`, so non-git folders are supported. |

## Presets

`--preset quick|ship|security|research|deep` maps to the closest review lane:

- `quick` -> `review`
- `ship` -> `elite-review`
- `security` -> `security-review`
- `research` -> `deep-review`
- `deep` -> `deep-review`

## Background Jobs

Add `--background` to any review-like command. Jobs are stored under the first writable location:

1. `--job-dir <dir>`
2. `CODEX_KIMI_REVIEW_JOB_DIR`
3. `<git-root>/.codex-kimi/jobs`
4. `~/.codex-kimi/jobs`
5. `/tmp/codex-kimi/jobs`

Manage them with `status`, `result`, and `cancel`.

## Safety Model

- Review lanes do not edit files.
- Custom lanes use `codex exec --sandbox read-only --ask-for-approval never`.
- Directory snapshots skip binary files and files larger than 1 MiB.
- Untracked files in Git working-tree reviews are included with a 64 KiB per-file cap.
- User focus text, diff text, and file contents are framed as untrusted review context.

`doctor` is intentionally lightweight and does not spend model quota. Use `doctor --probe-runtime` when you want to verify that the current shell can actually start a nested Codex runtime.

## Parity With `codex-plugin-cc`

See [docs/parity.md](docs/parity.md).

## Verification

```bash
npm test
node scripts/validate-plugin.mjs
node scripts/codex-kimi-review.mjs doctor
```

See [docs/verification.md](docs/verification.md) for current local results and known environment limits.

# Parity With codex-plugin-cc

Reference inspected locally: `/home/lkx/.npm-global/lib/node_modules/codex-plugin-cc`, version `1.0.13`.

| Upstream surface | codex-plugin-kimi status | Notes |
| --- | --- | --- |
| `setup` | Supported | Checks Codex CLI, Codex auth, Git, Node, helper version. |
| `doctor` | Supported | Adds plugin root, manifest, command/skill path, job dir, Git/non-Git readiness, plus optional `--probe-runtime`. |
| `review` | Supported | Uses native `codex review` for plain Git diffs, with `codex exec` fallback for focused/custom prompt paths and native runtime failures. |
| `adversarial-review` | Supported | Uses `codex exec` read-only with adversarial prompt. |
| `elite-review` | Supported | Uses `codex exec` read-only with ship/no-ship prompt. |
| `deep-review` | Supported | Uses `codex exec` read-only with broad multi-pass prompt. Codex has no Claude Task-equivalent inside this helper, so it is prompt-level deep review rather than explicit Claude sub-agent dispatch. |
| `security-review` | Supported | Uses `codex exec` read-only with security-focused prompt. |
| `folder <path>` | Supported | Supports Git and non-Git directories through bounded snapshots and `--skip-git-repo-check`. |
| `status` | Supported | Lists recent background jobs and one job detail. |
| `result` | Supported | Prints persisted stdout for completed jobs. |
| `cancel` | Supported | Sends SIGTERM to a running detached job. |
| `enable` | Not needed for Kimi | Kimi installs plugins through `/plugins install`; no Codex marketplace stanza is required. |
| `--background` | Supported | Detached Node worker with persisted job JSON. |
| `--job-dir` | Supported | Also supports `CODEX_KIMI_REVIEW_JOB_DIR`. |
| `--base` | Supported | Native `codex review --base` for review; manual context for custom lanes. |
| `--commit` | Supported | Native `codex review --commit` for review; manual context for custom lanes. |
| `--scope auto|working-tree|branch|directory` | Supported | `auto` prefers working tree, then branch; directory works outside Git. |
| `--preset quick|ship|security|research|deep` | Supported | Routes to the closest Codex lane. |
| `--path` | Supported | Targets another directory. |
| `--model` | Supported | Passed to Codex global `-m`. |
| `--effort` | Supported | Passed as `model_reasoning_effort`. |
| `--add-dir` | Supported for `codex exec` lanes | Native `codex review` does not need this path for ordinary Git diffs. |
| `--system-prompt-extra` | Supported for `codex exec` lanes | Native `codex review` accepts a prompt string but not the full upstream prompt-control surface. |
| `--mcp-config`, `--inherit-mcp`, `--strict-mcp` | Not implemented | Codex CLI MCP config is managed in Codex config, not passed as ad hoc JSON by this helper. |
| `--web-domain` | Not implemented | Codex web access is governed by Codex configuration and tool availability. |
| Claude-specific model/profile/long-context flags | Not applicable | This plugin calls Codex, not Claude. `--model` and `--effort` are the Codex equivalents. |
| Safe Claude tool catalog and `git-safe` wrapper | Not applicable | Codex sandboxing is enforced by `codex exec --sandbox read-only` for custom lanes. |
| Structured Claude JSON schemas and citation cross-checking | Partial | Codex returns Markdown review output. This plugin preserves output verbatim instead of enforcing Claude schemas. |

## Design Notes

`codex-plugin-cc` is a Codex plugin that registers slash commands in Codex and calls Claude Code. Kimi Code plugins use `kimi.plugin.json`, `commands`, `skills`, optional `sessionStart.skill`, and `/plugins install`. This plugin therefore mirrors the workflow and command surface, not the Codex-specific marketplace registration mechanism.

# Parity With codex-plugin-cc

This plugin mirrors the `codex-plugin-cc` workflow pattern where Codex invokes
an external reviewer runtime through a local helper.

## Equivalent Workflow

| codex-plugin-cc | codex-plugin-kimi |
| --- | --- |
| `codex-claude-review setup` | `codex-kimi-review setup` |
| `codex-claude-review doctor` | `codex-kimi-review doctor` |
| `codex-claude-review enable` | `codex-kimi-review enable` |
| `codex-claude-review review` | `codex-kimi-review review` |
| `adversarial-review` | `adversarial-review` |
| `elite-review` | `elite-review` |
| `deep-review` | `deep-review` |
| `security-review` | `security-review` |
| `status` / `result` / `cancel` | `status` / `result` / `cancel` |

## Kimi-Specific Differences

- Kimi Code is called through `kimi -p <prompt> --output-format text`.
- Claude-specific agentic controls, Task sub-agents, structured output schema,
  Opus model defaults, and budget flags do not map directly to Kimi Code.
- Compatibility flags such as `--add-dir`, `--legacy`, `--agentic`,
  `--long-context`, and `--unrestricted` are accepted where practical, but the
  helper keeps the actual review call read-only.
- MCP-specific and web-domain controls are currently compatibility inputs, not
  Kimi runtime tool grants.

## Supported Context Collection

- Git working tree, including staged, unstaged, and untracked text files.
- Branch diff with `--base <ref>`.
- Single commit review with `--commit <sha>`.
- Non-Git folder snapshots with bounded file size and binary skipping.

## Intentional Safety Boundary

The helper instructs Kimi that review context is untrusted and that it must not
edit files. Codex should treat Kimi output as external review advice.

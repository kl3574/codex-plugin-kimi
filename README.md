# codex-plugin-kimi

`codex-plugin-kimi` is a Codex plugin that lets Codex call Kimi Code CLI for
read-only review workflows. It mirrors the practical workflow shape of
`codex-plugin-cc`, but the reviewer runtime is Kimi Code.

Direction:

```text
Codex -> codex-kimi-review helper -> kimi -p -> Kimi Code review output
```

It is not a Kimi Code plugin that calls Codex.

## Requirements

- Node.js 18.18 or newer.
- Git.
- Kimi Code CLI available as `kimi`.
- A working Kimi Code login/auth setup for real runtime reviews.

When the local network requires `HTTP_PROXY` or `HTTPS_PROXY`, the helper
defaults Kimi child processes to `NODE_USE_ENV_PROXY=1` so the Node-bundled
Kimi runtime honors those proxy variables. Set `NODE_USE_ENV_PROXY=0` before
running the helper only if you explicitly need to disable that behavior.

## Commands

The plugin provides these slash-command prompt files under `commands/`:

- `/codex-plugin-kimi:setup`
- `/codex-plugin-kimi:doctor`
- `/codex-plugin-kimi:install-bin`
- `/codex-plugin-kimi:enable`
- `/codex-plugin-kimi:review`
- `/codex-plugin-kimi:adversarial-review`
- `/codex-plugin-kimi:elite-review`
- `/codex-plugin-kimi:deep-review`
- `/codex-plugin-kimi:security-review`
- `/codex-plugin-kimi:folder`
- `/codex-plugin-kimi:status`
- `/codex-plugin-kimi:result`
- `/codex-plugin-kimi:cancel`

The command files delegate to:

```bash
codex-kimi-review <command> <args>
```

The installed plugin exposes `codex-kimi-review` through the plugin package
`bin` entry. If the helper is not available on PATH in an older installation,
reinstall or upgrade the plugin. For local checkout debugging, use:

```bash
node <plugin-root>/scripts/codex-kimi-review.mjs <command> <args>
```

## Helper Examples

```bash
node scripts/codex-kimi-review.mjs setup
node scripts/codex-kimi-review.mjs install-bin
node scripts/codex-kimi-review.mjs doctor --json
node scripts/codex-kimi-review.mjs review --path .
node scripts/codex-kimi-review.mjs review --path . --preset ship
node scripts/codex-kimi-review.mjs review --path . --max-context-bytes 900000
node scripts/codex-kimi-review.mjs security-review --path . --background
node scripts/codex-kimi-review.mjs status
node scripts/codex-kimi-review.mjs result <job-id>
```

## Install in Codex from GitHub

After this repository is public, add it as a Codex marketplace source and
install the plugin:

```bash
codex plugin marketplace add kl3574/codex-plugin-kimi
codex plugin add codex-plugin-kimi@kimi-review
codex plugin list
```

You can also browse it from Codex with `/plugins` after adding the marketplace.
Start a new Codex thread after installation so the bundled skills and commands
are loaded.

## Enable a Local Checkout

From this checkout:

```bash
node scripts/codex-kimi-review.mjs enable
```

The helper adds a local marketplace entry to `~/.codex/config.toml`:

```toml
[marketplaces.kimi-review]
source_type = "local"
source = "/home/lkx/codex-plugin-kimi"

[plugins."codex-plugin-kimi@kimi-review"]
enabled = true
```

Run `--dry-run` first if you want to inspect the planned block.

This repository also includes `.agents/plugins/marketplace.json`, so the
checkout can be used directly as a local Codex marketplace source.

After the marketplace is registered, install the plugin from that marketplace:

```bash
codex plugin add codex-plugin-kimi@kimi-review
codex plugin list
```

## Install on Another Machine

Install it on another computer with:

```bash
codex plugin marketplace add kl3574/codex-plugin-kimi
codex plugin add codex-plugin-kimi@kimi-review
codex plugin list
```

Run `kimi login` first if Kimi Code CLI is not authenticated on that machine.

## Review Modes

- Working tree review: staged, unstaged, and untracked text files.
- Branch review: `--base <ref>` or `--scope branch`.
- Commit review: `--commit <sha>`.
- Folder review: `folder <path>` or `--scope directory`.

Binary files, symlinks, non-regular files, and large files are skipped in
prompt snapshots. Review context is capped before calling `kimi -p`; use
`--max-context-bytes <n>` or `CODEX_KIMI_REVIEW_MAX_CONTEXT_BYTES` to adjust the
cap. The helper never edits project files; it only builds review context and
calls `kimi -p`.

## Verification

```bash
npm run check
python3 /home/lkx/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py /home/lkx/codex-plugin-kimi
node scripts/codex-kimi-review.mjs setup --json
node scripts/codex-kimi-review.mjs doctor --json
```

See `docs/verification.md` for the latest local verification notes.

## License

Apache-2.0

# Verification Notes

This file records local verification for the active Codex to Kimi implementation.

## Expected Checks

```bash
node --check scripts/codex-kimi-review.mjs
node scripts/validate-plugin.mjs
bash tests/run-boundary-tests.sh
npm run check
python3 /home/lkx/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py /home/lkx/codex-plugin-kimi
node scripts/codex-kimi-review.mjs setup --json
node scripts/codex-kimi-review.mjs doctor --json
node scripts/codex-kimi-review.mjs doctor --probe-runtime --timeout-ms 10000 --json
CODEX_HOME=/tmp/codex-kimi-codex-home codex plugin list
```

## Runtime Caveat

The fake-Kimi boundary suite verifies local helper behavior without requiring
network access. Real `kimi -p` probes depend on the local Kimi Code auth state
and outbound network access. If OAuth token fetch fails, the helper should
surface that failure directly through `setup` or `doctor --probe-runtime`.

The current managed Codex sandbox may make `/home/lkx/.codex/config.toml`
read-only. In that case, `enable` should print the exact TOML block to add and
the plugin can still be validated with a temporary `CODEX_HOME`.

Codex marketplace registration and plugin installation are separate steps. The
plugin is only fully active after `codex plugin add
codex-plugin-kimi@kimi-review-private` reports a successful install.

## 2026-07-03 Local Results

- `npm run check`: passed. Static helper parse, local plugin validation, and
  15 fake-Kimi boundary tests passed.
- `validate_plugin.py /home/lkx/codex-plugin-kimi`: passed.
- `setup --json`: passed. `kimi` and `git` were found; `kimi doctor` exited
  successfully with no output.
- `doctor --json`: passed. Manifest, command directory, skill directory, job
  directory, Git, and non-Git folder support were all reported available.
- `doctor --probe-runtime --timeout-ms 10000 --json`: failed only at the real
  Kimi runtime probe with `spawnSync kimi ETIMEDOUT`.
- `enable --json` against `/home/lkx/.codex/config.toml`: failed because the
  managed sandbox exposed that file as read-only (`EROFS`). The helper returned
  the exact TOML `config_block` for manual use.
- Temporary Codex install check:
  `CODEX_HOME=/tmp/codex-kimi-codex-home codex plugin add codex-plugin-kimi@kimi-review-private --json`
  returned version `0.1.0`, and `codex plugin list` then reported
  `codex-plugin-kimi@kimi-review-private` as `installed, enabled`.

## 2026-07-03 Review Fixes

- Added regression coverage for untracked symlink handling. Symlinks are now
  skipped instead of followed, preventing prompt snapshots from reading targets
  outside the reviewed repository.
- Added `--max-context-bytes` and `CODEX_KIMI_REVIEW_MAX_CONTEXT_BYTES`.
  Context is truncated with an explicit `TRUNCATED` marker before invoking
  `kimi -p`.
- Review timeout failures now print `Timed out after <n> ms`, plus exit status
  or signal when available.
- Empty Kimi prompt-mode failures now print an actionable diagnostic when
  `kimi -p` exits nonzero without stdout, stderr, or an error object.
- `enable` now respects `CODEX_HOME` when choosing the Codex config path, while
  `--config <path>` still takes precedence. This keeps temporary and alternate
  Codex homes installable.

## 2026-07-03 Runtime Probe Follow-up

- `npm run check`: passed with 15 boundary tests.
- `validate_plugin.py /home/lkx/codex-plugin-kimi`: passed.
- `doctor --json --probe-runtime --timeout-ms 60000`: failed only at the real
  `kimi -p` runtime probe. Kimi exited with status 1 and produced no output;
  the helper now reports that exact condition and recommends
  `codex-kimi-review doctor --probe-runtime` or
  `kimi -p "Return ok" --output-format text` to check Kimi authentication,
  provider, and network access.

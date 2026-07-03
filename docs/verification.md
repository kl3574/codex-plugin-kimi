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

## 2026-07-03 Local Results

- `npm run check`: passed. Static helper parse, local plugin validation, and
  10 fake-Kimi boundary tests passed.
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

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
codex-plugin-kimi@kimi-review` reports a successful install.

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
- Temporary Codex install check used the earlier private marketplace name.

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

## 2026-07-03 Public Install Release

- Bumped plugin and package version to `0.1.1`.
- Renamed the public marketplace from `kimi-review-private` to `kimi-review`.
- Documented GitHub marketplace installation:
  `codex plugin marketplace add kl3574/codex-plugin-kimi`, then
  `codex plugin add codex-plugin-kimi@kimi-review`.
- Kimi child processes now default to `NODE_USE_ENV_PROXY=1`, while preserving
  an explicit user override such as `NODE_USE_ENV_PROXY=0`.
- `npm run check`: passed. Static helper parse, local plugin validation, and
  17 fake-Kimi boundary tests passed.
- `validate_plugin.py /home/lkx/codex-plugin-kimi`: passed.
- Temporary Codex install check:
  `CODEX_HOME=/tmp/codex-plugin-kimi-install-check codex plugin marketplace add /home/lkx/codex-plugin-kimi`,
  then `codex plugin add codex-plugin-kimi@kimi-review --json`, returned
  version `0.1.1`; `codex plugin list` reported
  `codex-plugin-kimi@kimi-review` as `installed, enabled`.

## 2026-07-03 Helper Bin Fix

- Bumped plugin and package version to `0.1.2`.
- Marked `scripts/codex-kimi-review.mjs` executable so the package `bin`
  entry can be exposed as the `codex-kimi-review` PATH helper by Codex.
- Added validation coverage that fails when the helper script is not executable.
- Added `codex-kimi-review install-bin` and `/codex-plugin-kimi:install-bin`
  to install a `codex-kimi-review` shim into a PATH directory when Codex cannot
  create plugin PATH aliases in a restricted session.
- Removed hardcoded local checkout helper paths from command and skill fallback
  docs; fallbacks now use `<plugin-root>/scripts/codex-kimi-review.mjs`.

## 2026-07-03 Single File Path Fix

- Bumped plugin and package version to `0.1.3`.
- `codex-kimi-review review --path <file>` now builds a `single-file` review
  context instead of treating the file path as a directory snapshot.
- Added boundary coverage for Markdown file review paths to prevent the
  `ENOTDIR: not a directory, scandir '<file>'` regression.
- `npm run check`: passed. Static helper parse, local plugin validation, and
  19 fake-Kimi boundary tests passed.
- `validate_plugin.py /home/lkx/codex-plugin-kimi`: passed.
- Source helper path regression check against
  `/home/lkx/Desktop/cejiao/UniME/docs/benchmark_requirements.md` no longer
  fails with `ENOTDIR`; with a 100 ms timeout it reached the real Kimi call and
  timed out after `SIGTERM`.

## 2026-07-03 Runtime Sandbox Diagnostic

- Bumped plugin and package version to `0.1.4`.
- `codex-kimi-review doctor --probe-runtime --json` now reports
  `proxy_connectivity`, a non-sensitive TCP probe of the configured proxy
  endpoint, so Codex sandbox network denials such as `EPERM` are visible before
  Kimi runtime failures are interpreted as authentication issues.
- `npm run check`: passed. Static helper parse, local plugin validation, and
  20 fake-Kimi boundary tests passed.
- Source helper runtime diagnostic in the current Codex sandbox reported
  `EPERM connecting to 127.0.0.1:10808`, while the Kimi prompt probe still
  exited with status 1 and no output. This confirms the active blocker is
  sandbox socket denial, not the review path handling.

## 2026-07-03 Large Prompt File Reference Transport

- Bumped plugin and package version to `0.1.5`.
- Large review prompts now use Kimi Code's documented file-reference flow:
  the full bounded review context is written to a temporary Markdown file,
  Kimi is launched with `--add-dir <context-dir>`, and the short `-p` prompt
  asks it to read `@review-context-*.md`.
- Added boundary coverage that simulates command-line prompt-size rejection and
  verifies the wrapper switches to file-reference transport instead of sending a
  huge `-p` argument.
- Background job status writes now use same-directory temp-file plus rename to
  avoid readers seeing partially written JSON.
- `npm run check`: passed. Static helper parse, local plugin validation, and
  21 fake-Kimi boundary tests passed.
- Real Kimi smoke test with a synthetic large folder context returned
  `TRANSPORT_OK`, confirming `kimi -p` can consume the temporary context through
  the `@review-context-*.md` file reference without hitting `E2BIG`.

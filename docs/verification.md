# Verification

This file records repeatable verification commands and the expected coverage.

## Local Static Checks

```bash
node scripts/validate-plugin.mjs
node --check scripts/codex-kimi-review.mjs
node --check scripts/validate-plugin.mjs
```

Expected:

- Manifest JSON parses.
- `skills` and `commands` paths exist.
- All command files exist.
- Core skills exist.
- Helper scripts pass Node syntax checks.

## Boundary Test Harness

```bash
npm test
```

The test harness uses temporary Git repositories and a fake `codex` executable to exercise deterministic boundary behavior without spending model quota on every run.

Covered cases:

- setup success with fake Codex.
- setup failure when Codex is missing.
- doctor runtime probe with fake Codex.
- non-git folder review.
- empty Git diff.
- untracked file review.
- focused review using `codex exec` compatibility path.
- invalid base ref.
- security/custom lane through `codex exec`.
- large diff handling.
- background job creation, status, result.
- cancellation path for a long-running fake Codex job.

Current result on 2026-07-03:

```text
npm run check
13 test(s) passed
```

## Live Checks

Run after deterministic tests:

```bash
node scripts/codex-kimi-review.mjs setup
node scripts/codex-kimi-review.mjs doctor
node scripts/codex-kimi-review.mjs doctor --probe-runtime --timeout-ms 10000
```

Current local results on 2026-07-03:

- `setup --json`: passed. Codex CLI `0.142.5`, authenticated with ChatGPT, Git `2.53.0`, Node `v22.22.1`.
- `doctor --json`: passed. Manifest, commands, skills, job directory, Git and non-Git readiness are present.
- `kimi doctor`: passed for `/home/lkx/.kimi-code/config.toml` and `/home/lkx/.kimi-code/tui.toml`.
- `doctor --probe-runtime --timeout-ms 10000`: failed in this Codex-managed shell with `failed to initialize in-process app-server client: Read-only file system (os error 30)`.

The runtime-probe failure is specific to launching a nested Codex runtime from the current restricted Codex session. It is surfaced by `doctor --probe-runtime` so the plugin does not silently report live-runtime readiness when the host shell cannot start Codex.

Optional quota-consuming smoke test outside this restricted Codex session:

```bash
tmp=$(mktemp -d)
git -C "$tmp" init
git -C "$tmp" config user.email test@example.com
git -C "$tmp" config user.name Test
printf 'ok\n' > "$tmp/app.txt"
git -C "$tmp" add app.txt
git -C "$tmp" commit -m init
printf 'ok\nbug\n' > "$tmp/app.txt"
node scripts/codex-kimi-review.mjs doctor --probe-runtime
node scripts/codex-kimi-review.mjs review --path "$tmp"
```

The smoke test invokes real Codex review paths; run it only when authenticated Codex access and model quota are available.

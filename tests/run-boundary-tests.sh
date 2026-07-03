#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELPER="$ROOT/scripts/codex-kimi-review.mjs"
VALIDATE="$ROOT/scripts/validate-plugin.mjs"
NODE_BIN="$(command -v node)"
REAL_GIT="$(command -v git)"
TMP="$(mktemp -d "$ROOT/.test-tmp-XXXXXX")"
FAKE_BIN="$TMP/fake-bin"
JOB_DIR="$TMP/jobs"
FAILED=0

trap 'rm -rf "$TMP"' EXIT

mkdir -p "$FAKE_BIN" "$JOB_DIR"

cat > "$FAKE_BIN/kimi" <<'EOF'
#!/bin/sh
if [ -n "${EXPECT_NODE_USE_ENV_PROXY:-}" ] && [ "${NODE_USE_ENV_PROXY:-}" != "$EXPECT_NODE_USE_ENV_PROXY" ]; then
  echo "NODE_USE_ENV_PROXY expected '$EXPECT_NODE_USE_ENV_PROXY' but got '${NODE_USE_ENV_PROXY:-}'" >&2
  exit 9
fi
if [ -n "$FAKE_KIMI_DELAY_MS" ]; then
  sleep "$(awk "BEGIN { print $FAKE_KIMI_DELAY_MS / 1000 }")"
fi
if [ -n "$FAKE_KIMI_EMPTY_FAIL" ]; then
  exit 1
fi
if [ -n "${FAKE_KIMI_MAX_PROMPT_ARG_BYTES:-}" ]; then
  previous=""
  for arg in "$@"; do
    if [ "$previous" = "-p" ] || [ "$previous" = "--prompt" ]; then
      bytes="$(printf '%s' "$arg" | wc -c | tr -d ' ')"
      if [ "$bytes" -gt "$FAKE_KIMI_MAX_PROMPT_ARG_BYTES" ]; then
        echo "prompt argv too large: $bytes" >&2
        exit 7
      fi
    fi
    previous="$arg"
  done
fi
case " $* " in
  *" --version "*) echo "kimi-code fake-0.0.0"; exit 0 ;;
  *" doctor "*) echo "Kimi doctor fake OK"; exit 0 ;;
  *" -p "*) echo "FAKE_KIMI_PROMPT $*"; exit 0 ;;
esac
echo "unexpected fake kimi args: $*" >&2
exit 2
EOF
chmod +x "$FAKE_BIN/kimi"
ln -s "$REAL_GIT" "$FAKE_BIN/git"

run_helper() {
  PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" "$NODE_BIN" "$HELPER" "$@"
}

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n%s\n' "$1" "$2" >&2
  FAILED=$((FAILED + 1))
}

contains() {
  case "$1" in
    *"$2"*) return 0 ;;
    *) return 1 ;;
  esac
}

check() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name" "command failed"
  fi
}

make_repo() {
  local dir="$TMP/$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name "Test User"
  printf 'one\n' > "$dir/app.txt"
  git -C "$dir" add app.txt
  git -C "$dir" commit -m init >/dev/null
  printf '%s\n' "$dir"
}

test_static_validation() {
  "$NODE_BIN" "$VALIDATE" >/tmp/codex-plugin-kimi-validate.out
}

test_setup_success() {
  local out
  out="$(run_helper setup --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" '"ok": true' && contains "$out" '"kimi_available": true'
}

test_setup_missing_kimi() {
  local out status
  out="$(PATH="/nonexistent" CODEX_KIMI_REVIEW_JOB_DIR="$TMP/missing-jobs" "$NODE_BIN" "$HELPER" setup 2>&1)"
  status=$?
  [ "$status" -ne 0 ] && contains "$out" "Kimi Code CLI not found"
}

test_kimi_defaults_node_env_proxy() {
  local out
  out="$(env -u NODE_USE_ENV_PROXY PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" EXPECT_NODE_USE_ENV_PROXY=1 "$NODE_BIN" "$HELPER" setup --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" '"ok": true'
}

test_kimi_preserves_node_env_proxy_override() {
  local out
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" EXPECT_NODE_USE_ENV_PROXY=0 NODE_USE_ENV_PROXY=0 "$NODE_BIN" "$HELPER" setup --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" '"ok": true'
}

test_doctor_probe_reports_proxy_connectivity() {
  local out
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" HTTPS_PROXY=http://127.0.0.1:1 https_proxy= HTTP_PROXY= http_proxy= ALL_PROXY= all_proxy= "$NODE_BIN" "$HELPER" doctor --probe-runtime --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" '"proxy_connectivity"' &&
    contains "$out" '"configured": true' &&
    contains "$out" '"host": "127.0.0.1"' &&
    contains "$out" '"runtime_probe"'
}

test_install_bin_writes_executable_shim() {
  local target out shim_out
  target="$TMP/bin/codex-kimi-review"
  out="$(run_helper install-bin --target "$target" --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  [ -x "$target" ] &&
    contains "$out" "\"target\": \"$target\"" &&
    contains "$out" '"wrote": true'
  shim_out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" "$target" setup --json 2>&1)" || {
    printf '%s\n' "$shim_out"
    return 1
  }
  contains "$shim_out" '"ok": true'
}

test_non_git_folder_review() {
  local dir out
  dir="$TMP/plain"
  mkdir -p "$dir"
  printf 'hello\n' > "$dir/notes.txt"
  out="$(run_helper folder "$dir" --preset research 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" && contains "$out" "review_context"
}

test_single_file_review_calls_kimi() {
  local file out
  file="$TMP/single.md"
  printf '# Requirement\n\nReview this file.\n' > "$file"
  out="$(run_helper review --path "$file" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" &&
    contains "$out" "single-file" &&
    contains "$out" "single.md" &&
    contains "$out" "Review this file."
}

test_empty_diff() {
  local repo out
  repo="$(make_repo empty)"
  out="$(run_helper review --path "$repo" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "No changes to review."
}

test_untracked_review_calls_kimi() {
  local repo out
  repo="$(make_repo untracked)"
  printf 'new\n' > "$repo/new.txt"
  out="$(run_helper review --path "$repo" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" && contains "$out" "working-tree"
}

test_untracked_symlink_is_not_followed() {
  local repo secret out
  repo="$(make_repo symlink)"
  secret="$TMP/outside-secret.txt"
  printf 'TOP_SECRET_DO_NOT_SEND\n' > "$secret"
  ln -s "$secret" "$repo/secret-link"
  out="$(run_helper review --path "$repo" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "secret-link" &&
    contains "$out" "skipped: symlink" &&
    ! contains "$out" "TOP_SECRET_DO_NOT_SEND"
}

test_context_budget_truncates_large_prompt() {
  local dir out
  dir="$TMP/large-folder"
  mkdir -p "$dir"
  awk 'BEGIN { for (i = 0; i < 5000; i++) print "alpha" }' > "$dir/a.txt"
  awk 'BEGIN { for (i = 0; i < 5000; i++) print "omega" }' > "$dir/b.txt"
  out="$(run_helper folder "$dir" --max-context-bytes 1200 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" && contains "$out" "TRUNCATED"
}

test_large_context_uses_file_transport() {
  local dir out
  dir="$TMP/file-transport"
  mkdir -p "$dir"
  awk 'BEGIN { for (i = 0; i < 50000; i++) print "large context" }' > "$dir/large.txt"
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" FAKE_KIMI_MAX_PROMPT_ARG_BYTES=10000 "$NODE_BIN" "$HELPER" folder "$dir" --max-context-bytes 300000 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" &&
    contains "$out" "--add-dir" &&
    contains "$out" "Read @review-context-" &&
    ! contains "$out" "prompt argv too large"
}

test_timeout_reports_actionable_diagnostic() {
  local repo out status
  repo="$(make_repo timeout)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" FAKE_KIMI_DELAY_MS=300 "$NODE_BIN" "$HELPER" review --path "$repo" --timeout-ms 50 2>&1)"
  status=$?
  [ "$status" -ne 0 ] &&
    contains "$out" "Timed out after 50 ms" &&
    contains "$out" "Kimi review failed"
}

test_empty_kimi_failure_reports_actionable_diagnostic() {
  local repo out status
  repo="$(make_repo empty-failure)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" FAKE_KIMI_EMPTY_FAIL=1 "$NODE_BIN" "$HELPER" review --path "$repo" 2>&1)"
  status=$?
  [ "$status" -ne 0 ] &&
    contains "$out" "Kimi exited with status 1 and produced no output" &&
    contains "$out" "doctor --probe-runtime"
}

test_enable_respects_codex_home() {
  local codex_home out config_path
  codex_home="$TMP/codex-home"
  config_path="$codex_home/config.toml"
  out="$(CODEX_HOME="$codex_home" run_helper enable --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "\"config\": \"$config_path\"" &&
    [ -f "$config_path" ] &&
    contains "$(cat "$config_path")" "[marketplaces.kimi-review]" &&
    contains "$out" "codex-plugin-kimi@kimi-review" &&
    ! contains "$out" "undefined"
}

test_preset_routes_to_security() {
  local repo out
  repo="$(make_repo preset)"
  printf 'password = input()\n' > "$repo/app.txt"
  out="$(run_helper review --path "$repo" --preset security 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_KIMI_PROMPT" && contains "$out" "security-focused"
}

test_invalid_base() {
  local repo out status
  repo="$(make_repo bad-base)"
  printf 'two\n' > "$repo/app.txt"
  out="$(run_helper review --path "$repo" --base does-not-exist 2>&1)"
  status=$?
  [ "$status" -ne 0 ] && contains "$out" "does-not-exist"
}

test_background_result() {
  local repo out id status_json result_out
  repo="$(make_repo background)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(run_helper security-review --path "$repo" --background 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  id="$(printf '%s\n' "$out" | sed -n 's/^Job: //p' | head -1)"
  [ -n "$id" ] || return 1
  for _ in $(seq 1 30); do
    status_json="$(cd "$repo" && run_helper status "$id" --json 2>/dev/null)"
    contains "$status_json" '"status": "completed"' && break
    sleep 0.1
  done
  contains "$status_json" '"status": "completed"' || {
    printf '%s\n' "$status_json"
    return 1
  }
  result_out="$(cd "$repo" && run_helper result "$id" 2>&1)" || {
    printf '%s\n' "$result_out"
    return 1
  }
  contains "$result_out" "FAKE_KIMI_PROMPT"
}

test_cancel_job() {
  local repo out id cancel_out cancel_jobs
  cancel_jobs="$TMP/cancel-jobs"
  repo="$(make_repo cancel)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$cancel_jobs" FAKE_KIMI_DELAY_MS=10000 "$NODE_BIN" "$HELPER" deep-review --path "$repo" --background 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  id="$(printf '%s\n' "$out" | sed -n 's/^Job: //p' | head -1)"
  [ -n "$id" ] || return 1
  cancel_out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$cancel_jobs" "$NODE_BIN" "$HELPER" cancel "$id" 2>&1)" || {
    printf '%s\n' "$cancel_out"
    return 1
  }
  contains "$cancel_out" "Status: cancelled"
}

check "static validation passes" test_static_validation
check "setup succeeds with fake kimi" test_setup_success
check "setup fails when kimi is missing" test_setup_missing_kimi
check "kimi child defaults NODE_USE_ENV_PROXY" test_kimi_defaults_node_env_proxy
check "kimi child preserves NODE_USE_ENV_PROXY override" test_kimi_preserves_node_env_proxy_override
check "doctor probe reports proxy connectivity" test_doctor_probe_reports_proxy_connectivity
check "install-bin writes executable shim" test_install_bin_writes_executable_shim
check "non-git folder review calls kimi" test_non_git_folder_review
check "single file review calls kimi" test_single_file_review_calls_kimi
check "empty diff exits cleanly" test_empty_diff
check "untracked review calls kimi" test_untracked_review_calls_kimi
check "untracked symlink is not followed" test_untracked_symlink_is_not_followed
check "context budget truncates large prompt" test_context_budget_truncates_large_prompt
check "large context uses file transport" test_large_context_uses_file_transport
check "timeout reports actionable diagnostic" test_timeout_reports_actionable_diagnostic
check "empty kimi failure reports actionable diagnostic" test_empty_kimi_failure_reports_actionable_diagnostic
check "enable respects CODEX_HOME" test_enable_respects_codex_home
check "preset routes to security review prompt" test_preset_routes_to_security
check "invalid base ref reports git error" test_invalid_base
check "background job completes and result is readable" test_background_result
check "cancel running background job" test_cancel_job

if [ "$FAILED" -ne 0 ]; then
  printf '%s test(s) failed\n' "$FAILED" >&2
  exit 1
fi

printf '21 test(s) passed\n'

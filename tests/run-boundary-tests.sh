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

mkdir -p "$FAKE_BIN" "$JOB_DIR"

cat > "$FAKE_BIN/codex" <<'EOF'
#!/bin/sh
if [ -n "$FAKE_CODEX_DELAY_MS" ]; then
  sleep "$(awk "BEGIN { print $FAKE_CODEX_DELAY_MS / 1000 }")"
fi
case " $* " in
  *" --version "*) echo "codex-cli fake-0.0.0"; exit 0 ;;
esac
if [ "$1" = "login" ] && [ "$2" = "status" ]; then
  echo "Logged in using Fake"
  exit 0
fi
case " $* " in
  *" exec"*) echo "FAKE_CODEX_EXEC $*"; exit 0 ;;
  *" review"*) echo "FAKE_CODEX_REVIEW $*"; exit 0 ;;
esac
echo "unexpected fake codex args: $*" >&2
exit 2
EOF
chmod +x "$FAKE_BIN/codex"
ln -s "$REAL_GIT" "$FAKE_BIN/git"

run_helper() {
  PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" "$NODE_BIN" "$HELPER" "$@"
}

run_helper_env() {
  env "$@" PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$JOB_DIR" "$NODE_BIN" "$HELPER"
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
  contains "$out" '"ok": true' && contains "$out" '"codex_authenticated": true'
}

test_setup_missing_codex() {
  local out status
  out="$(PATH="/nonexistent" CODEX_KIMI_REVIEW_JOB_DIR="$TMP/missing-jobs" "$NODE_BIN" "$HELPER" setup 2>&1)"
  status=$?
  [ "$status" -ne 0 ] && contains "$out" "Codex CLI not found"
}

test_doctor_runtime_probe() {
  local out
  out="$(run_helper doctor --probe-runtime --json 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" '"runtime_probe"' && contains "$out" '"ok": true' && contains "$out" "FAKE_CODEX_EXEC"
}

test_non_git_folder() {
  local dir out
  dir="$TMP/plain"
  mkdir -p "$dir"
  printf 'hello\n' > "$dir/notes.txt"
  out="$(run_helper folder "$dir" --preset research 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_CODEX_EXEC"
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

test_untracked_review() {
  local repo out
  repo="$(make_repo untracked)"
  printf 'new\n' > "$repo/new.txt"
  out="$(run_helper review --path "$repo" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_CODEX_REVIEW" && contains "$out" "--uncommitted"
}

test_review_focus_uses_exec() {
  local repo out
  repo="$(make_repo focus)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(run_helper review --path "$repo" --focus "custom focus" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_CODEX_EXEC"
}

test_invalid_base() {
  local repo out status
  repo="$(make_repo bad-base)"
  printf 'two\n' > "$repo/app.txt"
  out="$(run_helper review --path "$repo" --base does-not-exist 2>&1)"
  status=$?
  [ "$status" -ne 0 ] && contains "$out" "does-not-exist"
}

test_security_exec() {
  local repo out
  repo="$(make_repo security)"
  printf 'password = input()\n' > "$repo/app.txt"
  out="$(run_helper security-review --path "$repo" 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_CODEX_EXEC"
}

test_large_diff() {
  local repo out
  repo="$(make_repo large)"
  python3 - "$repo/large.txt" <<'PY'
import sys
with open(sys.argv[1], "w", encoding="utf-8") as f:
    line = "x" * 1024 + "\n"
    for _ in range(7000):
        f.write(line)
PY
  out="$(run_helper adversarial-review --path "$repo" --timeout-ms 30000 2>&1)" || {
    printf '%s\n' "$out"
    return 1
  }
  contains "$out" "FAKE_CODEX_EXEC"
}

test_background_result() {
  local repo out id status_json result_json result_out
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
  contains "$result_out" "FAKE_CODEX_EXEC"
}

test_cancel_job() {
  local repo out id cancel_out cancel_jobs
  cancel_jobs="$TMP/cancel-jobs"
  repo="$(make_repo cancel)"
  printf 'changed\n' > "$repo/app.txt"
  out="$(PATH="$FAKE_BIN:$PATH" CODEX_KIMI_REVIEW_JOB_DIR="$cancel_jobs" FAKE_CODEX_DELAY_MS=10000 "$NODE_BIN" "$HELPER" deep-review --path "$repo" --background 2>&1)" || {
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
check "setup succeeds with fake codex" test_setup_success
check "setup fails when codex is missing" test_setup_missing_codex
check "doctor runtime probe succeeds with fake codex" test_doctor_runtime_probe
check "non-git folder review uses codex exec" test_non_git_folder
check "empty diff exits cleanly" test_empty_diff
check "untracked file review uses native codex review" test_untracked_review
check "review with focus uses codex exec compatibility path" test_review_focus_uses_exec
check "invalid base ref reports git error" test_invalid_base
check "security review uses codex exec" test_security_exec
check "large diff does not overflow buffers" test_large_diff
check "background job completes and result is readable" test_background_result
check "cancel running background job" test_cancel_job

if [ "$FAILED" -ne 0 ]; then
  printf '%s test(s) failed\n' "$FAILED" >&2
  exit 1
fi

printf '13 test(s) passed\n'

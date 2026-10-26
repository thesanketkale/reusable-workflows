#!/usr/bin/env bash
# scripts/verify.sh: Validation runner for reusable-workflows
#
# Run by you, the git pre-commit hook, and every agent (Claude Code and Antigravity):
#   bash scripts/verify.sh fast   # Fast syntax, lint, shellcheck (< 30s)
#   bash scripts/verify.sh full   # Comprehensive checks (fast + docs, fixtures, tests)
# Exit codes: 0 ok (INCOMPLETE still exits 0, so read the last line), 1 a check failed, 3 full ran no checks at all (not green).

set -o pipefail
MODE="${1:-full}"
case "$MODE" in fast|full) ;; *) echo "usage: verify.sh [fast|full]" >&2; exit 64 ;; esac

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

# Ensure agent-team managed tools (~/.agent-team/bin) are in PATH
if [ -d "$HOME/.agent-team/bin" ]; then
  case ":$PATH:" in *":$HOME/.agent-team/bin:"*) ;; *) PATH="$HOME/.agent-team/bin:$PATH" ;; esac
fi

FAILED=""; SKIPPED=""; RAN=0
step() {
  local label="$1"; shift
  printf '\n> %s\n' "$label"; RAN=$((RAN + 1))
  if "$@"; then printf 'ok  %s\n' "$label"; else printf 'FAIL %s\n' "$label"; FAILED="$FAILED, $label"; fi
}
staged() { git diff --cached --name-only --diff-filter=ACMR -- "$@"; }
skip() {
  case "$SKIPPED," in *", $1,"*) return 0 ;; esac
  printf 'SKIPPED %s\n' "$1" >&2; SKIPPED="$SKIPPED, $1"
}
have() { if command -v "$1" >/dev/null 2>&1 || [ -x "$1" ]; then return 0; fi; skip "$1 (not installed)"; return 1; }

run_shellcheck_scripts() {
  local files
  mapfile -t files < <(find scripts -maxdepth 1 -name "*.sh" 2>/dev/null)
  if [ ${#files[@]} -gt 0 ]; then
    shellcheck "${files[@]}"
  fi
}

# ---------------------------------------------------------------- FAST ----
fast_checks() {
  # 1. actionlint
  if have actionlint; then
    step "actionlint workflow syntax" actionlint
  fi

  # 2. yamllint .github examples fixtures
  if have yamllint; then
    step "yamllint fast" yamllint -c .yamllint.yml .github examples fixtures
  fi

  # 3. shellcheck scripts/*.sh
  if have shellcheck; then
    step "shellcheck scripts" run_shellcheck_scripts
  fi

  # 4. scripts/check-workflows.sh (when present)
  if [ -f "scripts/check-workflows.sh" ]; then
    step "check workflows" bash scripts/check-workflows.sh
  fi
}

# ---------------------------------------------------------------- FULL ----
full_checks() {
  # 1. scripts/check-docs.sh (when present)
  if [ -f "scripts/check-docs.sh" ]; then
    step "documentation sync check" bash scripts/check-docs.sh
  fi

  # 2. scripts/run-fixtures.sh (when present)
  if [ -f "scripts/run-fixtures.sh" ]; then
    step "run fixtures" bash scripts/run-fixtures.sh
  fi

  # Missing tools omitted from this machine: bats, markdownlint
}

fast_checks
if [ "$MODE" = "full" ]; then
  full_checks
fi

if [ -n "$FAILED" ]; then
  printf '\nverify %s: FAILED (%s)\n' "$MODE" "${FAILED#, }"
  exit 1
fi
if [ -n "$SKIPPED" ]; then
  printf '\nverify %s: INCOMPLETE. %d checks passed, NOT VERIFIED (skipped): %s\n' "$MODE" "$RAN" "${SKIPPED#, }"
  exit 0
fi
if [ "$RAN" -eq 0 ]; then
  printf '\nverify %s: NO CHECKS RAN. Nothing is configured yet; fill fast_checks/full_checks (init-project does this).\n' "$MODE"
  if [ "$MODE" = "full" ]; then exit 3; fi
  exit 0
fi
printf '\nverify %s: OK (%d checks)\n' "$MODE" "$RAN"

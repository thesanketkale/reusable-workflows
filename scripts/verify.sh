#!/usr/bin/env bash
# scripts/verify.sh: Validation runner for reusable-workflows
#
# Usage:
#   bash scripts/verify.sh fast   # Fast syntax, lint, shellcheck (< 30s)
#   bash scripts/verify.sh full   # Comprehensive actionlint, yamllint, shellcheck, doc check
#
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

run_shellcheck_all() {
  local files
  mapfile -t files < <(find . -name "*.sh" -not -path "*/.*" 2>/dev/null)
  if [ ${#files[@]} -gt 0 ]; then
    shellcheck "${files[@]}"
  fi
}

# ---------------------------------------------------------------- FAST ----
fast_checks() {
  local wf_count
  wf_count=$(find .github/workflows -maxdepth 1 -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l)
  if [ "$wf_count" -gt 0 ]; then
    if have actionlint; then
      step "actionlint workflow syntax" actionlint
    elif have python3; then
      step "python3 yaml syntax" python3 -c "import glob, yaml; [yaml.safe_load(open(f, encoding='utf-8')) for f in glob.glob('.github/**/*.y*ml', recursive=True)]"
    fi

    if have yamllint; then
      step "yamllint fast" yamllint -c .yamllint.yml .github/
    fi
  elif [ -d ".github/actions" ]; then
    if have yamllint; then
      step "yamllint fast" yamllint -c .yamllint.yml .github/actions/
    fi
  fi

  if have shellcheck; then
    step "shellcheck scripts" run_shellcheck_scripts
  fi

  if [ -f "scripts/check-docs.sh" ] && [ -d "docs/workflows" ]; then
    step "documentation sync check" bash scripts/check-docs.sh
  fi
}

# ---------------------------------------------------------------- FULL ----
full_checks() {
  local wf_count
  wf_count=$(find .github/workflows -maxdepth 1 -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l)
  if [ "$wf_count" -gt 0 ]; then
    if have actionlint; then
      step "actionlint (full)" actionlint -color
    fi
  fi

  if have yamllint; then
    step "yamllint (full)" yamllint -c .yamllint.yml .
  fi

  if have shellcheck; then
    step "shellcheck (all shell scripts)" run_shellcheck_all
  fi
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
  printf '\nverify %s: NO CHECKS RAN. Baseline scaffold in progress.\n' "$MODE"
  if [ "$MODE" = "full" ]; then exit 0; fi
  exit 0
fi
printf '\nverify %s: OK (%d checks)\n' "$MODE" "$RAN"

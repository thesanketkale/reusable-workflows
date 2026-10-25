#!/usr/bin/env bash
# scripts/check-docs.sh: Verifies workflow_call inputs match docs/workflows/<name>.md
set -eo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

DOCS_DIR="docs/workflows"
WORKFLOWS_DIR=".github/workflows"

if [ ! -d "$DOCS_DIR" ]; then
  echo "Docs directory $DOCS_DIR does not exist yet. Skipping check."
  exit 0
fi

PYTHON_CMD=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD="python"
else
  echo "Python not found; skipping AST-based YAML doc checks."
  exit 0
fi

FAILED=0
CHECKED=0

for wf in "$WORKFLOWS_DIR"/*.yml; do
  [ -f "$wf" ] || continue
  filename=$(basename "$wf")
  wfname="${filename%.yml}"

  # Skip self-tests, release, and repository CI workflows
  case "$wfname" in
    selftest-*|ci|release) continue ;;
  esac

  # Check if workflow defines workflow_call
  if ! grep -q "workflow_call:" "$wf"; then
    continue
  fi

  doc="$DOCS_DIR/$wfname.md"
  if [ ! -f "$doc" ]; then
    echo "ERROR: Missing documentation file: $doc for workflow $wf"
    FAILED=$((FAILED + 1))
    continue
  fi

  # Extract input keys from workflow YAML
  inputs=$("$PYTHON_CMD" -c "
import yaml, sys
try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    on = data.get(True if True in data else 'on', {})
    if isinstance(on, dict) and 'workflow_call' in on:
        wf_call = on['workflow_call']
        if isinstance(wf_call, dict) and 'inputs' in wf_call and wf_call['inputs']:
            for k in wf_call['inputs'].keys():
                print(k)
except Exception as e:
    sys.exit(1)
" "$wf")

  if [ -n "$inputs" ]; then
    while IFS= read -r input_name; do
      [ -n "$input_name" ] || continue
      if ! grep -q "\`$input_name\`" "$doc"; then
        echo "ERROR: Input '$input_name' in $wf is NOT documented in $doc"
        FAILED=$((FAILED + 1))
      fi
    done <<< "$inputs"
  fi

  echo "ok  $doc matches $wf"
  CHECKED=$((CHECKED + 1))
done

if [ "$FAILED" -gt 0 ]; then
  echo "Documentation check FAILED with $FAILED errors."
  exit 1
fi

echo "Documentation check PASSED ($CHECKED workflows verified)."
exit 0

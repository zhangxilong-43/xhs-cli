#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[smoke] checking local saved session..."
if ! uv run python -m xhs_cli.cli status >/dev/null 2>&1; then
  echo "[smoke] no valid saved session. run 'uv run python -m xhs_cli.cli login' first."
  exit 1
fi

echo "[smoke] validating session usability via whoami..."
if ! uv run python -m xhs_cli.cli whoami >/dev/null 2>&1; then
  echo "[smoke] saved cookies exist but session is expired/invalid."
  echo "[smoke] run 'uv run python -m xhs_cli.cli login' to refresh auth."
  exit 1
fi

MARK_EXPR="integration and not live_mutation"
if [[ "${XHS_SMOKE_MUTATION:-0}" == "1" ]]; then
  MARK_EXPR="integration"
fi

echo "[smoke] running integration smoke tests with marker: $MARK_EXPR"
uv run pytest tests/test_integration.py -v --override-ini="addopts=" -m "$MARK_EXPR" "$@"

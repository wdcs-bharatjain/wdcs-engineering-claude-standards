#!/usr/bin/env bash
# WDCS PreToolUse guard dispatcher.
#
# Reads the hook event JSON on stdin and delegates to guard.py.
# If python3 is unavailable the guard exits 0 (no decision) so Claude Code
# falls back to the normal permission flow. The unbypassable layer is
# permissions.deny in managed settings, not this hook.
set -uo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "WDCS guard: python3 not found; secret/Git guard skipped." >&2
  exit 0
fi

exec python3 "$(dirname "${BASH_SOURCE[0]}")/guard.py"

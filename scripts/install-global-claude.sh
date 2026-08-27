#!/usr/bin/env bash
# Installs the WDCS organization-wide Claude Code instructions.
#
#   --user     (default) install for the current user, as an import from
#              ~/.claude/CLAUDE.md. Never overwrites personal instructions.
#   --managed  install as the machine-wide managed policy CLAUDE.md, which
#              users cannot exclude. Needs root; this is the fleet path.
#   --check    report what is installed and exit.
#
# Both modes are idempotent: re-running updates the WDCS content and leaves
# everything else alone.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="${ROOT}/claude/global/CLAUDE.md"
USER_DIR="${HOME}/.claude"
USER_STANDARDS="${USER_DIR}/wdcs/CLAUDE.md"
USER_ENTRYPOINT="${USER_DIR}/CLAUDE.md"
IMPORT_LINE="@wdcs/CLAUDE.md"
MODE="user"

usage() {
  cat <<'USAGE'
Installs the WDCS organization-wide Claude Code instructions.

  --user     (default) install for the current user, as an import from
             ~/.claude/CLAUDE.md. Never overwrites personal instructions.
  --managed  install as the machine-wide managed policy CLAUDE.md, which
             users cannot exclude. Needs root; this is the fleet path.
  --check    report what is installed and exit.
USAGE
}

managed_path() {
  case "$(uname -s)" in
    Darwin) echo "/Library/Application Support/ClaudeCode/CLAUDE.md" ;;
    Linux) echo "/etc/claude-code/CLAUDE.md" ;;
    MINGW* | MSYS* | CYGWIN*) echo "/c/Program Files/ClaudeCode/CLAUDE.md" ;;
    *) echo "" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user | --managed | --check) MODE="${1#--}" ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -f "${SOURCE_FILE}" ]] || {
  echo "Source not found: ${SOURCE_FILE}" >&2
  exit 1
}

if [[ "${MODE}" == "check" ]]; then
  target="$(managed_path)"
  echo "Managed policy CLAUDE.md: ${target:-unsupported platform}"
  if [[ -n "${target}" && -f "${target}" ]]; then
    echo "  installed ($(wc -l <"${target}") lines)"
  else
    echo "  not installed"
  fi
  echo "User install: ${USER_STANDARDS}"
  if [[ -f "${USER_STANDARDS}" ]]; then
    echo "  installed ($(wc -l <"${USER_STANDARDS}") lines)"
  else
    echo "  not installed"
  fi
  if [[ -f "${USER_ENTRYPOINT}" ]] && grep -qxF "${IMPORT_LINE}" "${USER_ENTRYPOINT}"; then
    echo "  imported from ${USER_ENTRYPOINT}"
  else
    echo "  not imported from ${USER_ENTRYPOINT}"
  fi
  exit 0
fi

if [[ "${MODE}" == "managed" ]]; then
  TARGET="$(managed_path)"
  [[ -n "${TARGET}" ]] || {
    echo "Unsupported platform for --managed: $(uname -s)" >&2
    exit 1
  }
  if [[ ! -w "$(dirname "${TARGET}")" && "$(id -u)" -ne 0 ]]; then
    echo "Needs root. Re-run: sudo $0 --managed" >&2
    exit 1
  fi
  mkdir -p "$(dirname "${TARGET}")"
  if [[ -f "${TARGET}" ]] && cmp -s "${SOURCE_FILE}" "${TARGET}"; then
    echo "Already current: ${TARGET}"
    exit 0
  fi
  if [[ -f "${TARGET}" ]]; then
    cp "${TARGET}" "${TARGET}.backup.$(date +%Y%m%d%H%M%S)"
  fi
  cp "${SOURCE_FILE}" "${TARGET}"
  echo "Installed managed policy CLAUDE.md at ${TARGET}"
  echo "Verify on a developer machine: run /status inside Claude Code."
  exit 0
fi

# --user
mkdir -p "$(dirname "${USER_STANDARDS}")"
if [[ -f "${USER_STANDARDS}" ]] && cmp -s "${SOURCE_FILE}" "${USER_STANDARDS}"; then
  echo "Already current: ${USER_STANDARDS}"
else
  cp "${SOURCE_FILE}" "${USER_STANDARDS}"
  echo "Installed WDCS standards at ${USER_STANDARDS}"
fi

if [[ -f "${USER_ENTRYPOINT}" ]] && grep -qxF "${IMPORT_LINE}" "${USER_ENTRYPOINT}"; then
  echo "Import already present in ${USER_ENTRYPOINT}"
  exit 0
fi

if [[ -f "${USER_ENTRYPOINT}" ]]; then
  cp "${USER_ENTRYPOINT}" "${USER_ENTRYPOINT}.backup.$(date +%Y%m%d%H%M%S)"
  printf '\n%s\n' "${IMPORT_LINE}" >>"${USER_ENTRYPOINT}"
  echo "Appended '${IMPORT_LINE}' to ${USER_ENTRYPOINT} (backup written)"
else
  printf '%s\n' "${IMPORT_LINE}" >"${USER_ENTRYPOINT}"
  echo "Created ${USER_ENTRYPOINT} importing the WDCS standards"
fi
echo "Confirm it loaded: run /context inside Claude Code and look under Memory files."

#!/usr/bin/env bash
# Fallback installer: copies the WDCS skills into ~/.claude/skills/.
#
# Prefer the plugin. It carries the hooks, versioning, and `/plugin update`:
#
#   /plugin marketplace add CodezerosDev/wdcs-engineering-claude-standards
#   /plugin install wdcs@claude-skills
#
# Use this script only where plugins are unavailable. Skills are installed
# under a `wdcs-` prefix so they never shadow a built-in or personal skill of
# the same name (for example the built-in security-review).
#
#   --dry-run   show what would change
#   --uninstall remove previously installed wdcs-* skills
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT}/claude/plugin/skills"
TARGET_DIR="${HOME}/.claude/skills"
PREFIX="wdcs-"
DRY_RUN=0
UNINSTALL=0

usage() {
  cat <<'USAGE'
Copies the WDCS skills into ~/.claude/skills/ (fallback installer).

Prefer the plugin, which carries the hooks, versioning, and /plugin update:

  /plugin marketplace add CodezerosDev/wdcs-engineering-claude-standards
  /plugin install wdcs@claude-skills

  --dry-run   show what would change
  --uninstall remove previously installed wdcs-* skills
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
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

if [[ "${UNINSTALL}" -eq 1 ]]; then
  shopt -s nullglob
  removed=0
  for dir in "${TARGET_DIR}/${PREFIX}"*; do
    [[ -d "${dir}" ]] || continue
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "would remove ${dir}"
    else
      rm -rf "${dir}"
      echo "removed ${dir}"
    fi
    removed=$((removed + 1))
  done
  [[ "${removed}" -eq 0 ]] && echo "No ${PREFIX}* skills installed."
  exit 0
fi

echo "Note: the plugin is the supported path; see --help." >&2
mkdir -p "${TARGET_DIR}"

for skill_dir in "${SOURCE_DIR}"/*; do
  [[ -d "${skill_dir}" ]] || continue
  name="$(basename "${skill_dir}")"
  target="${TARGET_DIR}/${PREFIX}${name}"

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "would install ${skill_dir} -> ${target}"
    continue
  fi

  if [[ -d "${target}" ]]; then
    backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "${target}" "${backup}"
    echo "Backed up existing ${target} to ${backup}"
  fi

  cp -R "${skill_dir}" "${target}"

  # Keep the frontmatter name aligned with the prefixed directory name.
  skill_file="${target}/SKILL.md"
  if [[ -f "${skill_file}" ]]; then
    awk -v new="${PREFIX}${name}" '
      /^name:[[:space:]]/ && !done { print "name: " new; done = 1; next }
      { print }
    ' "${skill_file}" >"${skill_file}.tmp" && mv "${skill_file}.tmp" "${skill_file}"
  fi

  echo "Installed skill: ${PREFIX}${name}"
done

echo "Restart Claude Code, then run /context to confirm the skills are listed."

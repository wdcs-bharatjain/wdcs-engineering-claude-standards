#!/usr/bin/env bash
# Validates this repository. Run from anywhere; paths resolve to the repo root.
#
# Checks: JSON syntax, shell syntax, plugin/marketplace manifests, skill
# frontmatter, hook guard behaviour, and accidental secrets.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}" || exit 1

FAILURES=0
fail() { echo "  FAIL $*"; FAILURES=$((FAILURES + 1)); }
pass() { echo "  ok   $*"; }
section() { echo; echo "== $1"; }

repo_files() {
  # Tracked *and* untracked-but-not-ignored files: CI must see a file that a
  # developer has created and not yet committed.
  if git -C "${ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "${ROOT}" ls-files -z --cached --others --exclude-standard
  else
    find . -type f -not -path './.git/*' -not -path '*/node_modules/*' -print0
  fi
}

section "JSON syntax"
if ! command -v python3 >/dev/null 2>&1; then
  fail "python3 not found; cannot validate JSON"
else
  while IFS= read -r -d '' f; do
    case "${f}" in
      *.json)
        if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "${f}" 2>/dev/null; then
          pass "${f}"
        else
          fail "${f} is not valid JSON"
        fi
        ;;
    esac
  done < <(repo_files)
fi

section "Shell scripts"
while IFS= read -r -d '' f; do
  case "${f}" in
    *.sh)
      if bash -n "${f}" 2>/dev/null; then pass "${f}"; else fail "${f} has a syntax error"; fi
      if command -v shellcheck >/dev/null 2>&1; then
        shellcheck -S warning "${f}" || fail "${f} failed shellcheck"
      fi
      ;;
  esac
done < <(repo_files)

section "Python scripts"
if command -v python3 >/dev/null 2>&1; then
  while IFS= read -r -d '' f; do
    case "${f}" in
      *.py)
        if python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "${f}" 2>/dev/null; then
          pass "${f}"
        else
          fail "${f} has a syntax error"
        fi
        ;;
    esac
  done < <(repo_files)
fi

section "Plugin and marketplace manifests"
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate ./claude/plugin --strict >/dev/null 2>&1; then
    pass "claude/plugin (claude plugin validate --strict)"
  else
    fail "claude/plugin manifest rejected:"
    claude plugin validate ./claude/plugin --strict 2>&1 | sed 's/^/       /'
  fi
  if claude plugin validate . --strict >/dev/null 2>&1; then
    pass ".claude-plugin/marketplace.json (claude plugin validate --strict)"
  else
    fail "marketplace manifest rejected:"
    claude plugin validate . --strict 2>&1 | sed 's/^/       /'
  fi
else
  echo "  note: claude CLI not installed; running manifest checks in Python"
  python3 - <<'PY' || FAILURES=$((FAILURES + 1))
import json, re, sys

KEBAB = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
errors = []

plugin = json.load(open("claude/plugin/.claude-plugin/plugin.json"))
if not KEBAB.match(plugin.get("name", "")):
    errors.append(f"plugin name {plugin.get('name')!r} is not kebab-case")

market = json.load(open(".claude-plugin/marketplace.json"))
for key in ("name", "owner", "plugins"):
    if key not in market:
        errors.append(f"marketplace.json missing required key {key!r}")
if not KEBAB.match(market.get("name", "")):
    errors.append(f"marketplace name {market.get('name')!r} is not kebab-case")
names = {p.get("name") for p in market.get("plugins", [])}
if plugin.get("name") not in names:
    errors.append(f"marketplace does not list plugin {plugin.get('name')!r}")

for e in errors:
    print(f"  FAIL {e}")
sys.exit(1 if errors else 0)
PY
  [[ "${FAILURES}" -eq 0 ]] && pass "manifests (python fallback)"
fi

section "Skill frontmatter"
python3 - <<'PY' || FAILURES=$((FAILURES + 1))
import re, sys
from pathlib import Path

KEBAB = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
errors = []
skills = sorted(Path("claude").rglob("SKILL.md"))
if not skills:
    errors.append("no SKILL.md files found")

for path in skills:
    text = path.read_text()
    if not text.startswith("---\n"):
        errors.append(f"{path}: missing frontmatter")
        continue
    end = text.find("\n---", 4)
    if end == -1:
        errors.append(f"{path}: unterminated frontmatter")
        continue
    front = text[4:end]
    fields = dict(
        (k.strip(), v.strip())
        for k, _, v in (line.partition(":") for line in front.splitlines())
        if k.strip() and not k.startswith(" ")
    )
    name = fields.get("name", "")
    desc = fields.get("description", "")
    if not name:
        errors.append(f"{path}: missing name")
    elif not KEBAB.match(name):
        errors.append(f"{path}: name {name!r} is not kebab-case")
    elif name != path.parent.name:
        errors.append(f"{path}: name {name!r} does not match directory {path.parent.name!r}")
    if not desc:
        errors.append(f"{path}: missing description")
    elif len(desc) < 30:
        errors.append(f"{path}: description too short to trigger reliably")
    elif len(desc) > 1024:
        errors.append(f"{path}: description over 1024 characters")
    if not errors or all(str(path) not in e for e in errors):
        print(f"  ok   {path}")

for e in errors:
    print(f"  FAIL {e}")
sys.exit(1 if errors else 0)
PY

section "Hook guard behaviour"
HOOK_LOG="$(mktemp)"
trap 'rm -f "${HOOK_LOG}"' EXIT
if bash "${ROOT}/scripts/test-hooks.sh" >"${HOOK_LOG}" 2>&1; then
  pass "$(tail -1 "${HOOK_LOG}")"
else
  fail "hook guard tests failed:"
  sed 's/^/       /' "${HOOK_LOG}"
fi

section "Accidental secrets"
# Patterns intentionally narrow: this repo is policy text that discusses
# secrets, so match credential *values*, not the words describing them.
PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{22,}'
  'sk-[A-Za-z0-9]{32,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}'
  '(0x)?[a-fA-F0-9]{64}'
)
SECRET_HITS=0
while IFS= read -r -d '' f; do
  case "${f}" in
    *.png|*.jpg|*.jpeg|*.gif|*.pdf|*.ico|*.woff*) continue ;;
  esac
  for pattern in "${PATTERNS[@]}"; do
    if grep -HnEq -- "${pattern}" "${f}" 2>/dev/null; then
      echo "  FAIL possible secret in ${f}: pattern ${pattern}"
      grep -HnE -- "${pattern}" "${f}" | head -3 | cut -c1-160 | sed 's/^/       /'
      SECRET_HITS=$((SECRET_HITS + 1))
    fi
  done
done < <(repo_files)
if [[ "${SECRET_HITS}" -gt 0 ]]; then
  FAILURES=$((FAILURES + SECRET_HITS))
else
  pass "no credential-shaped strings found"
fi
if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks detect --no-banner --redact -s "${ROOT}" >/dev/null 2>&1; then
    pass "gitleaks detect"
  else
    fail "gitleaks reported findings (run: gitleaks detect -v)"
  fi
else
  echo "  note: gitleaks not installed; relying on pattern scan and CI"
fi

echo
if [[ "${FAILURES}" -gt 0 ]]; then
  echo "Validation FAILED: ${FAILURES} problem(s)."
  exit 1
fi
echo "Validation passed."

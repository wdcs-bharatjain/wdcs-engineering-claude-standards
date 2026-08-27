#!/usr/bin/env bash
# Behavioural tests for the WDCS plugin PreToolUse guard.
#
# Feeds hook event JSON to claude/plugin/scripts/guard.sh and asserts the
# exit code: 2 = tool call blocked, 0 = no decision (normal permission flow).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD="${ROOT}/claude/plugin/scripts/guard.sh"
DOTENV=".env"
FAILURES=0

expect() {
  local want="$1" label="$2" payload="$3" got output
  output="$(printf '%s' "${payload}" | bash "${GUARD}" 2>/dev/null)"
  got=$?
  if [[ "${got}" -ne "${want}" ]]; then
    echo "FAIL ${label}: expected exit ${want}, got ${got}"
    FAILURES=$((FAILURES + 1))
  else
    echo "ok   ${label}"
  fi
  [[ "${want}" -eq 2 && -z "${output}" ]] && {
    echo "FAIL ${label}: block produced no deny payload"
    FAILURES=$((FAILURES + 1))
  }
  return 0
}

file_event() {
  printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2"
}

bash_event() {
  printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

echo "Testing secret-file access..."
expect 2 "read dotenv"            "$(file_event Read "/app/${DOTENV}")"
expect 2 "read dotenv.production" "$(file_event Read "/app/${DOTENV}.production")"
expect 0 "read dotenv.example"    "$(file_event Read "/app/${DOTENV}.example")"
expect 2 "write private key"      "$(file_event Write "/app/certs/server.pem")"
expect 2 "edit signing key"       "$(file_event Edit "/app/keys/deploy.key")"
expect 0 "read public key"        "$(file_event Read "/home/dev/.ssh/id_rsa.pub")"
expect 2 "read ssh private key"   "$(file_event Read "/home/dev/.ssh/id_rsa")"
expect 2 "read aws credentials"   "$(file_event Read "/home/dev/.aws/credentials")"
expect 0 "read source file"       "$(file_event Read "/app/src/index.ts")"

echo "Testing shell commands..."
expect 2 "cat dotenv"             "$(bash_event "cat ${DOTENV}")"
expect 2 "grep secret in dotenv"  "$(bash_event "grep API_KEY ${DOTENV}.local")"
expect 0 "cat dotenv.example"     "$(bash_event "cat ${DOTENV}.example")"
expect 2 "commit --no-verify"     "$(bash_event 'git commit --no-verify -m fix')"
expect 2 "push --no-verify"       "$(bash_event 'git push --no-verify origin feature/x')"
expect 2 "force push main"        "$(bash_event 'git push --force origin main')"
expect 2 "force push mirror"      "$(bash_event 'git push -f --mirror backup')"
expect 0 "force-with-lease topic" "$(bash_event 'git push --force-with-lease origin feature/x')"
expect 0 "normal commit"          "$(bash_event 'git commit -m \"fix(api): reject duplicates\"')"
expect 0 "run tests"              "$(bash_event 'npm test')"

echo "Testing malformed input..."
expect 0 "invalid json"           'not json at all'
expect 0 "missing tool_input"     '{"hook_event_name":"PreToolUse","tool_name":"Bash"}'

if [[ "${FAILURES}" -gt 0 ]]; then
  echo "${FAILURES} hook test(s) failed."
  exit 1
fi
echo "All hook tests passed."

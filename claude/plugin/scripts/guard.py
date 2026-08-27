#!/usr/bin/env python3
"""WDCS PreToolUse guard.

Blocks, regardless of what the model decides:

  * reads and writes of secret-bearing files (dotenv files, private keys,
    cloud credentials, SSH/GPG material, kubeconfig)
  * shell commands that read those same files
  * `git commit --no-verify` / `git push --no-verify` (hook bypass)
  * force-pushes to a protected branch

Contract: reads the PreToolUse event JSON on stdin. To block, prints the
deny payload on stdout and exits 2. Otherwise exits 0 with no output, which
leaves the normal permission flow untouched.

Extend SECRET_BASENAMES / SECRET_SUFFIXES / SECRET_PATH_PARTS for your own
sensitive paths. Keep the lists tight: an over-broad rule trains developers
to disable the plugin.
"""

import json
import os
import re
import sys

DOTENV = ".env"

ALLOWED_DOTENV_BASENAMES = {
    DOTENV + ".example",
    DOTENV + ".sample",
    DOTENV + ".template",
    DOTENV + ".defaults",
    DOTENV + ".dist",
}

SECRET_BASENAMES = {
    "credentials.json",
    "service-account.json",
    "serviceaccount.json",
    "gha-creds.json",
    "kubeconfig",
    "id_rsa",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
}

SECRET_SUFFIXES = (
    ".pem",
    ".key",
    ".p12",
    ".pfx",
    ".jks",
    ".keystore",
    ".mnemonic",
)

# Normalised (forward-slash) path fragments that always carry credentials.
SECRET_PATH_PARTS = (
    "/.ssh/",
    "/.gnupg/",
    "/.aws/credentials",
    "/.config/gcloud/",
    "/.kube/config",
    "/.docker/config.json",
    "/.npmrc",
)

READ_COMMANDS = (
    "cat", "bat", "less", "more", "head", "tail", "strings", "xxd", "od",
    "nl", "cp", "mv", "base64", "openssl", "gpg", "sed", "awk", "grep",
    "rg", "jq", "dotenv", "source", "printenv",
)

PROTECTED_BRANCHES = ("main", "master", "develop", "release", "production")

DOC_HINT = (
    "WDCS security baseline (standards/secrets.md). If this file is genuinely "
    "not a secret, rename it to the .example variant or ask a human to run the "
    "command."
)


def deny(reason: str) -> None:
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.stdout.write("\n")
    sys.exit(2)


def is_secret_path(path: str) -> bool:
    if not path:
        return False
    normalised = path.replace("\\", "/")
    base = os.path.basename(normalised).lower()

    if base == DOTENV or base.startswith(DOTENV + "."):
        return base not in ALLOWED_DOTENV_BASENAMES
    if base in SECRET_BASENAMES:
        return True
    if base.endswith(".pub"):  # public half of a keypair
        return False
    if base.endswith(SECRET_SUFFIXES):
        return True

    lowered = "/" + normalised.lstrip("/").lower()
    return any(part in lowered for part in SECRET_PATH_PARTS)


def check_file_tool(tool_input: dict) -> None:
    candidates = [
        tool_input.get("file_path"),
        tool_input.get("notebook_path"),
        tool_input.get("path"),
    ]
    for edit in tool_input.get("edits") or []:
        if isinstance(edit, dict):
            candidates.append(edit.get("file_path"))

    for candidate in candidates:
        if isinstance(candidate, str) and is_secret_path(candidate):
            deny(
                "Blocked by WDCS guard: {0} holds credentials and must not be "
                "read or written by an agent. {1}".format(candidate, DOC_HINT)
            )


def check_bash(command: str) -> None:
    if not command:
        return
    lowered = command.lower()

    # Hook/verification bypass.
    if re.search(
        r"\bgit\b[^|;&]*\b(commit|push|merge)\b[^|;&]*"
        r"(--no-verify|(?<!\w)-n(?!\w))",
        lowered,
    ):
        deny(
            "Blocked by WDCS guard: --no-verify skips commit-time lint, type, "
            "secret-scan, and test hooks. Fix the failing check instead."
        )

    # Force-push to a protected branch.
    if re.search(r"\bgit\b[^|;&]*\bpush\b", lowered) and re.search(
        r"(--force(?!-with-lease)|(?<!\w)-f(?!\w))", lowered
    ):
        hits_protected = re.search(
            r"\b(" + "|".join(PROTECTED_BRANCHES) + r")\b", lowered
        )
        if hits_protected or re.search(r"--all\b|--mirror\b", lowered):
            deny(
                "Blocked by WDCS guard: force-push rewrites shared history on a "
                "protected branch. Push a topic branch and open a PR."
            )

    # Reading or overwriting secret files through the shell.
    touches_reader = bool(
        re.search(r"(^|[|;&\s])(" + "|".join(READ_COMMANDS) + r")(\s|$)", lowered)
    ) or ">" in command
    if not touches_reader:
        return
    for token in re.findall(r"[^\s\"'`|;&<>()]+", command):
        if is_secret_path(token):
            deny(
                "Blocked by WDCS guard: this command touches {0}, which holds "
                "credentials. {1}".format(token, DOC_HINT)
            )


def main() -> None:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)  # Never block on a payload we cannot parse.

    tool_name = event.get("tool_name") or ""
    tool_input = event.get("tool_input") or {}
    if not isinstance(tool_input, dict):
        sys.exit(0)

    if tool_name == "Bash":
        command = tool_input.get("command")
        check_bash(command if isinstance(command, str) else "")
    else:
        check_file_tool(tool_input)

    sys.exit(0)


if __name__ == "__main__":
    main()

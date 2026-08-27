# Security

## Reporting

Report a vulnerability in this repository, in the plugin hooks, or in the managed policy privately to the security owner named in `.github/CODEOWNERS`. Do not open a public issue and do not include real credentials in a report.

If a report concerns a bypass of the guardrail hooks or a managed permission rule, include the exact tool call or shell command that got through.

## What this repository is not

- Not a control that stops a determined developer. Managed settings and hooks bind Claude Code on that machine; a developer with local admin rights can edit the managed source, and any other tool calling the API is outside these rules.
- Not a substitute for branch protection, required status checks, secret scanning, dependency scanning, or production access control.
- Not an audit. A review performed by Claude covers the checks it ran and nothing more.

## Layers, and what each one guarantees

| Layer | Guarantee |
| --- | --- |
| `standards/`, `claude/global/CLAUDE.md`, plugin skills | Guidance. Followed most of the time; not enforced |
| Plugin `PreToolUse` hooks | The tool call is blocked, whatever the model decided — while the plugin is enabled and `python3` is present |
| `permissions.deny` in managed settings | Blocked by the client. A developer cannot override it, and it applies before workspace trust |
| CI, branch protection, secret scanning | The only layer that binds code arriving from anywhere |

The hook and the managed deny list intentionally overlap on secret paths: if the hook cannot run, the deny rule still holds.

## Handling secrets in this repository

`scripts/validate.sh` scans for credential-shaped strings and CI runs gitleaks over full history. If a real credential is ever committed here, rotate it first and rewrite history second — a redaction commit alone leaves it in the object database and in every clone.

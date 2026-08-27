# Standards Index

## Core

- [general.md](general.md) — design, naming, error handling, configuration, API design, concurrency.
- [git.md](git.md) — branches, Conventional Commits, PR content, branch protection.
- [testing.md](testing.md) — test levels, quality, security negative tests, blockchain invariants.
- [dependencies.md](dependencies.md) — adding a dependency, ecosystem tooling, CI gates.
- [observability.md](observability.md) — structured logging, metrics, safe client errors.
- [documentation.md](documentation.md) — what every project documents.

## Security

- [security-baseline.md](security-baseline.md) — mandatory principles, prohibitions, review triggers.
- [web-security.md](web-security.md) — OWASP-aligned input, output, auth, and transport rules.
- [csp.md](csp.md) — Content Security Policy baseline and prohibited shortcuts.
- [secrets.md](secrets.md) — what must never be committed, runtime secret management.
- [ai-security.md](ai-security.md) — treating repository and generated content as untrusted, agent permissions.

## Technology

- [nextjs.md](nextjs.md)
- [nestjs.md](nestjs.md)
- [rust.md](rust.md)
- [solidity.md](solidity.md)
- [move.md](move.md)

## How these are applied

| Where | Mechanism |
| --- | --- |
| Claude Code sessions | `claude/global/CLAUDE.md` and the `wdcs` plugin skills |
| Tool calls Claude attempts | Plugin `PreToolUse` hooks, `permissions.deny` in managed settings |
| Code arriving in a repository | CI, branch protection, CODEOWNERS, secret and dependency scanning |

`POLICY.md` says which rules are required versus recommended. Project repositories may add stricter rules; they must not weaken these.

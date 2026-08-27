---
name: git-review
description: Reviews the current Git state and prepares a clean Conventional Commit or pull-request summary. Use before committing or opening a PR.
disable-model-invocation: true
---

# Git Review

Inspect:

- `git status`
- `git diff`
- `git diff --staged`

Check for:

- unrelated changes
- secrets
- generated files
- debugging code
- missing tests
- formatting-only noise
- security-sensitive changes

Recommend a Conventional Commit:

`type(scope): description`

Do not commit automatically unless the user explicitly asks.

Provide:
- summary of changes
- recommended commit message
- tests/checks still needed
- security impact

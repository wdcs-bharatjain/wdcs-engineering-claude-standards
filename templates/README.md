# Templates

Baseline configuration for a WDCS project repository. Copy what applies; a project owns its own copy afterwards.

| Template | Install as | Notes |
| --- | --- | --- |
| `project-CLAUDE.md.example` | `CLAUDE.md` at the project root | Project architecture, commands, and security-sensitive areas. Keep it under ~200 lines; move procedures into `.claude/skills/` |
| `editorconfig` | `.editorconfig` at the project root | Note the leading dot: `cp templates/editorconfig <project>/.editorconfig` |
| `commitlint.config.cjs` | `commitlint.config.cjs` at the project root | Matches the commit types in `standards/git.md`. Needs `@commitlint/cli` and `@commitlint/config-conventional`, plus a `commit-msg` hook or a CI job to run it |
| `github/pull_request_template.md` | `.github/pull_request_template.md` | Testing, security, deployment, and risk sections |
| `github/CODEOWNERS.example` | `.github/CODEOWNERS` | Replace the placeholder teams, then require Code Owner review in branch protection |

A project also needs, and this repository does not template: CI workflows, secret scanning, dependency scanning, and branch protection. `POLICY.md` lists which of those are required.

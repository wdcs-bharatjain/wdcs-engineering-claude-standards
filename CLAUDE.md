# WDCS Engineering Standards Repository

This repository contains organization-wide development standards and Claude Code configuration. It is also the `claude-skills` plugin marketplace, so a broken manifest here breaks installs across the organization.

## Rules

- Keep organization-wide rules generic and technology-independent where possible.
- Do not put project-specific architecture in this repository.
- Do not put secrets, credentials, production configuration, or private tokens in this repository.
- Changes to security policy require security/engineering-owner review.
- Prefer executable enforcement through CI, hooks, linters, and branch protection over prose-only rules.
- A rule listed as Required in `POLICY.md` must name the mechanism that enforces it.

## Structure

- `standards/` — engineering and security policy.
- `claude/global/CLAUDE.md` — instructions deployed to the managed policy path.
- `claude/plugin/` — the `wdcs` plugin: skills plus the `PreToolUse` guard hooks.
- `claude/managed-settings.json` — the managed policy (permission denies, marketplace, plugin).
- `.claude-plugin/marketplace.json` — marketplace manifest; the repository root is the marketplace root.
- `templates/` — baseline configuration for project repositories.
- `scripts/` — installers, validation, hook tests.
- `docs/rollout.md` — rollout, verification, rollback.

## Validation

Run before every commit:

```bash
scripts/validate.sh
```

It checks JSON and shell/Python syntax, the plugin and marketplace manifests (`claude plugin validate --strict`), skill frontmatter, hook behaviour (`scripts/test-hooks.sh`), and credential-shaped strings. It resolves paths from the repository root, so it can be run from anywhere.

When touching the guard, add or update a case in `scripts/test-hooks.sh` in the same change: a deny rule with no test is a rule nobody will notice breaking.

## Change checklist

1. `scripts/validate.sh` passes.
2. Plugin content changed → bump `version` in `claude/plugin/.claude-plugin/plugin.json`.
3. `CHANGELOG.md` entry added.
4. Managed settings or hooks changed → say so in the PR description; those changes ship to a pilot team first.
5. Review the final diff.

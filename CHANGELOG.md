# Changelog

Versions refer to the `wdcs` plugin (`claude/plugin/.claude-plugin/plugin.json`). Standards text changes that do not touch the plugin are listed under the release they shipped with.

## 1.1.0 — 2026-08-26

Made the repository installable organization-wide.

### Added

- `.claude-plugin/marketplace.json`: this repository is now the `claude-skills` marketplace, so `/plugin marketplace add` works against it. Without this file the plugin could not be installed at all.
- Plugin guardrail hooks (`claude/plugin/hooks/hooks.json`, `claude/plugin/scripts/guard.{sh,py}`): a `PreToolUse` guard that denies secret-file access, `git commit|push --no-verify`, and force-push to a protected branch.
- `scripts/test-hooks.sh`: 22 behavioural assertions over the guard's deny/allow decisions.
- `.github/workflows/validate.yml`: repository validation, gitleaks, and commitlint in CI.
- `docs/rollout.md`: phased rollout, managed policy paths per OS, verification, rollback, version pinning.
- `SECURITY.md`, `LICENSE`, `.github/CODEOWNERS`, this changelog.

### Changed

- Plugin renamed `WDCS-engineering` → `wdcs`. `claude plugin validate --strict` rejects the old name: marketplace sync requires kebab-case. Skills are now invoked as `/wdcs:<skill>`.
- `claude/managed-settings.json` is a working policy instead of a stub: `permissions.deny` for secret paths and unsafe Git commands, `disableBypassPermissionsMode`, `disableSideloadFlags`, the real marketplace source, and a startup announcement. The `_comment` key was removed (it is not in the schema).
- `scripts/install-global-claude.sh` no longer overwrites `~/.claude/CLAUDE.md`. It installs `~/.claude/wdcs/CLAUDE.md` and appends one import line, adds `--managed` for the machine-wide managed policy path, and `--check`.
- `scripts/install-user-skills.sh` installs skills under a `wdcs-` prefix so they cannot shadow a built-in or personal skill (notably `security-review`), backs up rather than deletes an existing directory, and gained `--dry-run` / `--uninstall`.
- `scripts/validate.sh` resolves paths from the repository root instead of the working directory. Run from elsewhere it previously validated nothing and still printed "Validation passed". It now also checks Python syntax, manifest schemas, skill name/description quality, hook behaviour, and credential-shaped strings, and exits non-zero with a count.
- Skill descriptions for `architecture-review`, `csp-review`, and `dependency-review` state their trigger conditions, so the model can pick them up.
- `README.md` and `claude/README.md` describe the three deployment layers, what each one actually enforces, and the rollout traps (`enabledPlugins` does not install; allow rules wait for workspace trust; managed settings bind Claude Code only).
- `standards/README.md` entries are links.
- Marketplace source and plugin identity point at `CodezerosDev/wdcs-engineering-claude-standards`; the plugin id is `wdcs@claude-skills`.
- `claude/managed-settings.json` also distributes `superpowers@claude-plugins-official` and `caveman@caveman`; `claude/README.md` documents the supply-chain review those need. `ponytail@ponytail` (`DietrichGebert/ponytail`, hooks only) is registered the same way.

## 1.0.0

Initial standards, skills, and templates.

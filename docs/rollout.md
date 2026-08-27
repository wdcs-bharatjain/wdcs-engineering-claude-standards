# Organization Rollout Runbook

Audience: whoever owns Claude Code configuration for WDCS. Assumes the repository at `CodezerosDev/wdcs-engineering-claude-standards` is readable by every developer account.

## Before you start

- Decide the repository's final home. The marketplace source appears in three places: `.claude-plugin/marketplace.json` (`owner.url`), `claude/managed-settings.json` (`extraKnownMarketplaces`), and the install commands in `README.md`. Moving the repository later means re-running `/plugin marketplace add` on every machine.
- Decide who owns the policy. Fill in `.github/CODEOWNERS` and the security review owner in `POLICY.md`.
- Confirm the Claude Code version floor. The policy in this repository assumes v2.1.208 or later (a `Read` deny rule covering `Edit`) and v2.1.228 or later (covering `Write`).

## Phase 1 — pilot, one team

1. Merge this repository to its default branch and protect it (required PR, required `validate` check, required review).
2. On one machine:
   ```bash
   scripts/validate.sh
   sudo scripts/install-global-claude.sh --managed
   sudo cp claude/managed-settings.json /etc/claude-code/managed-settings.json   # adjust path per OS
   ```
3. Restart Claude Code and verify:
   ```text
   /status     # "Enterprise managed settings (file)" plus the managed CLAUDE.md
   /context    # memory files include the managed CLAUDE.md
   ```
   ```bash
   claude doctor   # lists any managed entry that failed validation and was dropped
   ```
4. Install the plugin and check the guardrails actually fire: ask Claude to read a project's dotenv file, and to commit with `--no-verify`. Both should be denied with a WDCS reason string.
5. Run the pilot team for a week. Collect every false positive against the hook and the `permissions.deny` list; each one is either a pattern to narrow or a workflow to fix.

## Phase 2 — fleet

1. Package the two managed files for your device tooling. Starter templates for Jamf, Intune, and Group Policy are in the Anthropic [MDM examples](https://github.com/anthropics/claude-code/tree/main/examples/mdm).

   | OS | Directory |
   | --- | --- |
   | macOS | `/Library/Application Support/ClaudeCode/` |
   | Linux and WSL | `/etc/claude-code/` |
   | Windows | `C:\Program Files\ClaudeCode\` |

   Windows can also carry the same JSON as a `REG_SZ` value named `Settings` under `HKLM\SOFTWARE\Policies\ClaudeCode`; macOS can carry it in the `com.anthropic.claudecode` managed preferences domain. If more than one managed source delivers a policy key, Claude Code uses the highest-priority source and silently ignores the rest — remote settings, then MDM/OS policy, then the file.
2. Announce the plugin install commands. `enabledPlugins` alone does not install a plugin from a GitHub marketplace; either each developer runs `/plugin install wdcs@claude-skills` once, or device management runs it for them.
3. Spot-check `/status` on a sample of machines after the next poll (MDM: 30 minutes; file: on change).
4. If the policy distributes third-party plugins (`superpowers`, `caveman`, `ponytail`), announce their install commands too, and record who reviewed their hooks. `claude/README.md` has the review checklist and the pinning options.

## Phase 3 — enforcement outside Claude Code

Managed settings bind Claude Code only. The same rules need a home in the repository and in CI, or they are advisory:

| Standard | Enforcement mechanism |
| --- | --- |
| No secrets in source control | GitHub secret scanning + push protection, gitleaks in CI |
| Conventional Commits | commitlint (`templates/commitlint.config.cjs`) in CI and a commit-msg hook |
| Lint, types, tests, build | Required status checks on the default branch |
| Dependency vulnerabilities | Dependabot or equivalent, plus a blocking audit step |
| PR review, CODEOWNERS | Branch protection (`templates/github/CODEOWNERS.example`) |
| Security review triggers | PR template checkboxes (`templates/github/pull_request_template.md`) + CODEOWNERS on sensitive paths |

## Version pinning and updates

- `version` in `claude/plugin/.claude-plugin/plugin.json` is the plugin's version. Bump it with every content change and record it in `CHANGELOG.md`.
- `claude plugin tag ./claude/plugin` creates a `wdcs--v<version>` git tag and checks that `plugin.json` and the marketplace entry agree.
- Developers update with `/plugin update wdcs`, then restart the session.

## Rollback

| Symptom | Action |
| --- | --- |
| A hook blocks legitimate work | Narrow the pattern in `guard.py`, bump the version, ship. Emergency stop for one developer: `/plugin disable wdcs` |
| A managed permission rule blocks legitimate work | Remove the rule and redeploy. Developers cannot override it locally |
| Managed settings are not applying | `/status` shows the selected source; a higher-priority source (remote, MDM) wins over the file. `claude doctor` shows dropped entries |
| A bad policy push | Redeploy the previous `managed-settings.json`. `requiredMinimumVersion` fails open by design, so a bad value there cannot brick startup |

## Ownership

Record here, before rollout: who owns this repository, who approves security policy changes, and where developers report a false positive.

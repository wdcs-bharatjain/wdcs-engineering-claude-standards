# WDCS Engineering Standards

Organization-wide engineering standards for human developers and for Claude Code, plus the machinery to install them across the organization.

- `standards/` — the policy text (engineering, security, per-technology).
- `claude/` — how that policy reaches Claude Code: managed instructions, the org plugin, managed settings.
- `templates/` — baseline configuration a project repository can copy.
- `scripts/` — installers and repository validation.

Policy that can be enforced by a machine lives in the plugin hooks, the managed settings, or CI. Prose is for the parts that cannot.

## Developer setup

Two commands inside Claude Code:

```text
/plugin marketplace add CodezerosDev/wdcs-engineering-claude-standards
/plugin install wdcs@claude-skills
```

That installs the skills and the guardrail hooks. Then confirm:

```text
/context     # skills and memory files loaded in this session
/status      # setting sources, including managed policy
```

If your organization has not yet deployed the managed instructions (below), also run:

```bash
scripts/install-global-claude.sh          # user scope, adds an import to ~/.claude/CLAUDE.md
scripts/install-global-claude.sh --check  # what is installed
```

The user-scope install never overwrites your own `~/.claude/CLAUDE.md`: it writes `~/.claude/wdcs/CLAUDE.md` and appends one `@wdcs/CLAUDE.md` import line.

## What the plugin gives you

| Component | Invoke | Purpose |
| --- | --- | --- |
| `engineering-standards` | model-invoked, or `/wdcs:engineering-standards` | Code structure, naming, testing, dependency, and secure-development rules |
| `security-review` | model-invoked, or `/wdcs:security-review` | Security review of a diff or codebase, findings classified CRITICAL→INFORMATIONAL |
| `csp-review` | model-invoked, or `/wdcs:csp-review` | CSP and security-header review |
| `architecture-review` | `/wdcs:architecture-review` | Boundaries, data flow, failure modes, migration strategy |
| `dependency-review` | `/wdcs:dependency-review` | Package identity, licence, vulnerabilities, transitive risk |
| `git-review` | `/wdcs:git-review` | Pre-commit/PR review and a Conventional Commit message |
| Guardrail hooks | automatic | Block secret-file access, `--no-verify`, and force-push to a protected branch |

The three review skills that only respond to an explicit call carry `disable-model-invocation: true`, so they never fire on their own.

### The hooks

`claude/plugin/hooks/hooks.json` registers one `PreToolUse` guard (`claude/plugin/scripts/guard.py`) that denies, regardless of what the model decides:

- reading or writing dotenv files (except `.example` / `.sample` / `.template` variants), private keys, cloud credentials, SSH and GPG material, kubeconfig;
- shell commands that read those same files;
- `git commit --no-verify` and `git push --no-verify`;
- force-push to `main`, `master`, `develop`, `release`, `production`, or with `--all` / `--mirror`. `--force-with-lease` on a topic branch is allowed.

`scripts/test-hooks.sh` asserts each of those decisions. Extend the pattern lists at the top of `guard.py`; keep them tight, because an over-broad rule teaches developers to disable the plugin.

## Organization rollout

Three independent layers. Deploy them in this order; each one works without the others.

| Layer | File in this repo | Deployed to | Enforcement |
| --- | --- | --- | --- |
| Managed instructions | `claude/global/CLAUDE.md` | Managed policy path (below) | Guidance. Users cannot exclude it, but Claude is not bound by it |
| Org plugin | `claude/plugin/` | Installed by each developer from this marketplace | Skills are guidance; hooks are enforcement |
| Managed settings | `claude/managed-settings.json` | Managed policy path (below) | Hard: nothing a developer sets overrides it |

Managed policy paths, per OS:

| OS | Directory |
| --- | --- |
| macOS | `/Library/Application Support/ClaudeCode/` |
| Linux and WSL | `/etc/claude-code/` |
| Windows | `C:\Program Files\ClaudeCode\` |

Place `CLAUDE.md` and `managed-settings.json` there with the tooling that already manages your fleet (MDM, Jamf, Intune, Group Policy, Ansible, or a base image). `C:\ProgramData\ClaudeCode\` is a legacy path and is no longer read.

For a single machine:

```bash
sudo scripts/install-global-claude.sh --managed
```

`docs/rollout.md` has the full runbook: phasing, verification, rollback, and version pinning.

The same two managed keys distribute third-party plugins. `superpowers`, `caveman`, and `ponytail` are wired into `claude/managed-settings.json`; all three ship hooks that run on every developer machine, so review them as dependencies first — `claude/README.md` has the checklist.

Three things that bite during rollout:

- **`enabledPlugins` does not install the plugin.** A plugin from a GitHub marketplace still needs each developer to install it once, or a device-management step that does it for them.
- **`extraKnownMarketplaces` and permission `allow` rules wait for workspace trust.** `deny` and `ask` rules apply immediately, trusted or not.
- **Managed settings bind Claude Code only.** They do not constrain a developer using the API from another tool, and they are not a substitute for branch protection, CI, or production access control.

## Validation

```bash
scripts/validate.sh
```

Checks JSON syntax, shell and Python syntax (shellcheck where installed), the plugin and marketplace manifests (`claude plugin validate --strict`, with a Python fallback), skill frontmatter, hook behaviour, and credential-shaped strings. Exits non-zero on the first failure it finds and prints a summary; `.github/workflows/validate.yml` runs the same script plus gitleaks and commitlint.

## Changing the standards

1. Branch, edit, run `scripts/validate.sh`.
2. Bump `version` in `claude/plugin/.claude-plugin/plugin.json` when plugin content changes, and add a `CHANGELOG.md` entry.
3. Open a PR. Security policy changes need security/engineering-owner review (`POLICY.md`).
4. After merge, developers pick up plugin changes with `/plugin update wdcs`.

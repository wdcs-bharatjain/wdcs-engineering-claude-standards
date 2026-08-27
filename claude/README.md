# Claude Code Organization Setup

Three layers. They are independent: any one of them works without the other two.

| Layer | Source | Deployed as | What it actually enforces |
| --- | --- | --- | --- |
| 1. Managed instructions | `claude/global/CLAUDE.md` | `CLAUDE.md` at the managed policy path | Nothing by itself. It is context, so Claude follows it most of the time and cannot be told to ignore it by a project file |
| 2. Org plugin | `claude/plugin/` | Installed by each developer from the `claude-skills` marketplace | Skills are context. The `PreToolUse` hooks are enforcement: they block the tool call |
| 3. Managed settings | `claude/managed-settings.json` | `managed-settings.json` at the managed policy path | Hard enforcement by the client. Nothing a developer sets overrides it |

Managed policy path: `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux and WSL), `C:\Program Files\ClaudeCode\` (Windows).

Rule of thumb: behavioural guidance goes in layer 1 or 2, "must not happen" goes in layer 2's hooks and layer 3's `permissions.deny`.

## 1. Managed instructions

`claude/global/CLAUDE.md` is the organization baseline: priorities, secure-development rules, dependency rules, Git conventions, and what to report when work is done.

Deploy it to the managed policy path. It then loads before every user and project `CLAUDE.md`, in every repository on the machine, and `claudeMdExcludes` cannot skip it.

```bash
sudo scripts/install-global-claude.sh --managed   # one machine
scripts/install-global-claude.sh                  # user scope, for a dev without the fleet policy
```

The user-scope mode writes `~/.claude/wdcs/CLAUDE.md` and appends `@wdcs/CLAUDE.md` to `~/.claude/CLAUDE.md`. It never overwrites personal instructions; earlier versions of this script did, which is why the import indirection exists.

Alternative to a file: put the same text in the `claudeMd` key of `managed-settings.json`. Same precedence, one fewer file to deploy, but it has to be JSON-escaped.

## 2. Org plugin

This repository is itself the marketplace: `.claude-plugin/marketplace.json` at the root declares the `claude-skills` marketplace and points at `./claude/plugin`.

```text
/plugin marketplace add CodezerosDev/wdcs-engineering-claude-standards
/plugin install wdcs@claude-skills
```

Contents:

```text
claude/plugin/
├── .claude-plugin/plugin.json   # name: wdcs (kebab-case is required)
├── hooks/hooks.json             # PreToolUse guard registration
├── scripts/guard.sh             # dispatcher; no-ops if python3 is missing
├── scripts/guard.py             # the deny decisions
└── skills/                      # six skills, invoked as /wdcs:<skill>
```

Skills stay out of the managed `CLAUDE.md` on purpose: a skill body loads only when it is relevant, so the always-on context stays small.

The hooks are the part that does not depend on the model cooperating. They deny secret-file access, `--no-verify`, and force-push to a protected branch, and `scripts/test-hooks.sh` asserts every one of those decisions. If `python3` is absent the guard exits without a decision and the normal permission flow applies — which is why `permissions.deny` in layer 3 repeats the same secret paths.

Updates: `/plugin update wdcs`. Pin a release with `claude plugin tag` and a matching `version` in `plugin.json`.

## 3. Managed settings

`claude/managed-settings.json` is a working policy, not a placeholder. It:

- denies reads of dotenv files, private keys, cloud credentials, SSH/GPG material, and kubeconfig, and denies edits to key material;
- denies `git commit --no-verify`, `git push --no-verify`, and force-push;
- removes `bypassPermissions` mode;
- registers the `claude-skills` marketplace and marks `wdcs` enabled;
- rejects the sideload flags (`--plugin-dir`, `--plugin-url`, `--agents`, `--mcp-config`);
- shows a one-line announcement pointing at the security baseline.

Deploy it to the managed policy path, or deliver the same JSON through MDM, the HKLM registry, or the claude.ai console. Split it per owning team with `managed-settings.d/10-*.json` if more than one team owns part of the policy.

Optional hardening, deliberately not enabled here because each one has real friction:

| Key | Effect | Cost |
| --- | --- | --- |
| `allowManagedPermissionRulesOnly: true` | Only managed permission rules apply | Project `.claude/settings.json` allow rules stop working; expect more prompts |
| `strictKnownMarketplaces: [{"source":"github","repo":"…"}]` | Plugins may come only from listed marketplaces | Blocks every other marketplace a team already uses |
| `requiredMinimumVersion: "2.1.208"` | Refuses to start on older builds | Blocks developers mid-rollout until they update |
| `sandbox.enabled: true` | OS-level isolation for commands | Needs per-project network and write allowlists |

Things to know before you deploy:

- `enabledPlugins` marks a plugin enabled; it does not install one from a GitHub marketplace. Each developer still runs `/plugin install` once, or device management does it for them.
- `extraKnownMarketplaces` and permission `allow` rules take effect only after the developer trusts the folder. `deny` and `ask` rules apply immediately.
- Bash deny rules that constrain arguments are prefix matches and can be worked around by reordering flags. That is why the plugin hook checks the same things structurally.
- Read deny rules also cover Edit and Write on the same path, but not `NotebookEdit`; the policy therefore lists `Edit(...)` rules for key material explicitly.
- Managed settings bind Claude Code, not a developer calling the API from another tool.

Verify a deployment: `/status` names the source (`Enterprise managed settings (file)`), and `claude doctor` lists any entry that failed schema validation and was dropped.

## Third-party plugins, organization-wide

The same two managed keys distribute any plugin, not just this one: `extraKnownMarketplaces` registers the source, `enabledPlugins` marks it enabled. What is wired up here:

| Plugin | Marketplace | Source | Notes |
| --- | --- | --- | --- |
| `superpowers` | `claude-plugins-official` | `github.com/obra/superpowers` | Listed in the marketplace Claude Code already knows, so no `extraKnownMarketplaces` entry is needed. Third-party code distributed through Anthropic's index |
| `caveman` | `caveman` | `github.com/JuliusBrussee/caveman` | Community repository, registered explicitly |
| `ponytail` | `ponytail` | `github.com/DietrichGebert/ponytail` | Plugin source is the repository root. v4.9.0 ships hooks only (`hooks/claude-codex-hooks.json`), no skills or MCP servers |

Before adding a third-party plugin to the managed policy, treat it as a dependency, because that is what it is — `standards/dependencies.md` applies:

- **It ships executable hooks.** A plugin's `PreToolUse`/`SessionStart` hooks run on every developer machine with that developer's permissions. Read them. All three plugins above ship hooks that change how Claude behaves; `ponytail` ships nothing but hooks.
- **It can conflict with the WDCS baseline.** `caveman` changes output style globally; `superpowers` mandates a skill-first workflow before any other action; `ponytail` pushes for the shortest solution and against abstractions. None weakens the security rules, but `ponytail`'s bias and this repository's "add tests for behavioral changes" and input-validation rules will pull in opposite directions on some tasks — the security baseline wins, and that needs saying out loud to the pilot team.
- **Enabling is not installing.** `enabledPlugins` marks a plugin enabled; a plugin from a GitHub marketplace is still installed once per developer:
  ```text
  /plugin install superpowers@claude-plugins-official
  /plugin marketplace add JuliusBrussee/caveman
  /plugin install caveman@caveman
  /plugin marketplace add DietrichGebert/ponytail
  /plugin install ponytail@ponytail
  ```
- **Version drift.** `/plugin install` pins whatever the source has at that moment, and `/plugin update` moves it with no review step. For anything you need to hold steady, fork it into an internal repository, pin it there, and register that fork instead.
- **Locking the set down.** `strictKnownMarketplaces` limits installs to an allowlist of marketplaces, and `disableSideloadFlags` (already set) blocks `--plugin-dir` / `--plugin-url`. Together they stop developers adding an unreviewed marketplace — at the cost of blocking every marketplace not on the list.

## Project-level configuration

A project repository owns:

```text
CLAUDE.md                          # start from templates/project-CLAUDE.md.example
.claude/skills/<skill>/SKILL.md    # project architecture, commands, APIs, workflows
.claude/settings.json              # project permissions and hooks
```

Project rules may be stricter than the organization baseline. They must not weaken it. Keep project-specific architecture out of this repository.

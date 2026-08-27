# WDCS Engineering Policy

## Enforcement levels

### Required

Must be enforced by CI, branch protection, managed settings, or repository tooling. A rule in this list that has no mechanism behind it is a gap, not a policy.

| Requirement | Mechanism |
| --- | --- |
| No secrets in source control | GitHub secret scanning with push protection, gitleaks in CI, `permissions.deny` on secret paths, plugin guard hook |
| Secret scanning | CI job on every push and PR |
| Dependency/security scanning | Dependabot or equivalent, plus a blocking audit step for high/critical |
| Formatting, lint, type checks where supported | Required status checks |
| Tests for behavioral changes | Required status checks, PR review |
| PR review | Branch protection, CODEOWNERS on sensitive paths |
| Conventional Commits | commitlint in CI (`templates/commitlint.config.cjs`) and a commit-msg hook |
| Commit hooks are not bypassed | Plugin guard hook and `permissions.deny` block `--no-verify` |
| Shared history is not rewritten | Branch protection (no force-push), plugin guard hook |
| No weakening of security controls without explicit approval | CODEOWNERS review on security paths, `standards/security-baseline.md` |

### Strongly recommended

- Architecture review for large changes (`/wdcs:architecture-review`).
- Security review for security-sensitive changes (`/wdcs:security-review`); the triggers are listed in `standards/security-baseline.md`.
- Fuzz/invariant testing for financial and blockchain logic.
- CODEOWNERS for sensitive directories.
- Sandboxed command execution on machines that handle production credentials.

### Project-specific

Project teams may add stricter rules based on their architecture and risk profile.

Project rules must not weaken the required security baseline.

## Changing this policy

1. Open a PR against this repository; `scripts/validate.sh` must pass.
2. Security policy changes — anything under `standards/` marked Security, `claude/managed-settings.json`, or the plugin hooks — need review from the security owner in `.github/CODEOWNERS`.
3. Record the change in `CHANGELOG.md` and bump the plugin version when plugin content changed.
4. A change that adds a hard block (a hook deny or a managed permission rule) ships to a pilot team first; `docs/rollout.md` describes the phasing.

## Exceptions

An exception must be time-boxed, recorded in the PR that relies on it, and approved by the owner of the standard being excepted. "The build was failing" is not an exception.

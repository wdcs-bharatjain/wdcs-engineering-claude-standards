# Git and GitHub Standards

## Branches

Use:

- `feature/<short-description>`
- `fix/<short-description>`
- `security/<short-description>`
- `refactor/<short-description>`
- `hotfix/<short-description>`
- `chore/<short-description>`

Keep branch names short and descriptive.

## Conventional Commits

Use:

`type(scope): description`

Allowed types:

- `feat`
- `fix`
- `security`
- `refactor`
- `perf`
- `test`
- `docs`
- `build`
- `ci`
- `chore`

Examples:

- `feat(wallet): add network switcher`
- `fix(api): reject duplicate transaction submission`
- `security(auth): enforce admin authorization`
- `perf(indexer): optimize event query`

## Commits

- Keep commits logically focused.
- Do not mix formatting-only changes with functional changes.
- Do not commit generated files unless the repository explicitly requires them.
- Never commit secrets, credentials, private keys, `.env` files, or local machine configuration.
- Do not rewrite shared history unless the team explicitly agrees.

## Pull requests

Every PR should explain:

1. What changed.
2. Why it changed.
3. How it was tested.
4. Security impact.
5. Migration/deployment impact.

For security-sensitive changes, explicitly identify authentication, authorization, cryptography, secrets, CSP, smart-contract, or infrastructure impact.

## GitHub

Protect default branches with:

- Required PRs.
- Required CI checks.
- Required review(s).
- CODEOWNERS for sensitive areas.
- No force-push.
- No direct push for normal development.

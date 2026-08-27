# Secret Management

Never commit:

- API keys.
- Private keys.
- Wallet seed phrases.
- JWT signing secrets.
- Database passwords.
- Cloud credentials.
- OAuth client secrets.
- TLS private keys.
- `.env` files containing real credentials.

Use runtime secret management.

Claude Code must not be instructed to print or expose secrets. If a task requires a secret, use the minimum necessary scope and prefer an existing environment/secret-manager integration.

CI should include secret scanning such as GitHub secret scanning and/or Gitleaks.

# Organization Security Baseline

Security is a release requirement, not an optional code-quality improvement.

## Mandatory principles

- Treat all external input as untrusted.
- Authenticate before authorization.
- Enforce authorization server-side.
- Validate input at trust boundaries.
- Encode/escape output appropriately.
- Use parameterized queries.
- Use secure cryptographic libraries; do not implement primitives yourself.
- Protect secrets with a secret manager.
- Use TLS for sensitive network traffic.
- Apply secure cookie attributes where cookies are used.
- Apply security headers.
- Maintain dependency/security scanning.
- Keep production debugging and verbose error output disabled.
- Use least privilege for users, services, CI, and AI agents.

## Never

- Hardcode credentials.
- Commit private keys.
- Disable TLS verification to fix a development issue.
- Disable security scanners to make CI pass.
- Add `unsafe-inline` or `unsafe-eval` to CSP as a shortcut.
- Trust client-side authorization.
- Use dynamic SQL concatenation with untrusted input.
- Expose internal admin endpoints without authentication and authorization.
- Use weak/random non-cryptographic values for security decisions.

## Security review triggers

A security review is mandatory for changes involving:

- Authentication.
- Authorization.
- Sessions/cookies.
- Cryptography.
- Wallet/key handling.
- Smart contracts.
- Token transfers.
- Payment/financial logic.
- Admin APIs.
- Infrastructure/IAM.
- CSP/security headers.
- CORS.
- File uploads.
- SSRF-sensitive integrations.
- Secrets.

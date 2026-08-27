# Content Security Policy Standard

CSP is a defense-in-depth control and must be treated as a security boundary.

## Baseline

Prefer a nonce/hash-based CSP for applications that need inline framework-generated scripts/styles.

Typical directives:

- `default-src 'self'`
- `script-src 'self' 'nonce-<per-request-value>'`
- `style-src 'self' 'nonce-<per-request-value>'` where needed
- `img-src 'self' data: https:`
- `font-src 'self' https:`
- `connect-src 'self' <approved API origins>`
- `object-src 'none'`
- `base-uri 'self'`
- `frame-ancestors 'none'`
- `form-action 'self'`
- `upgrade-insecure-requests`

The exact policy must be adapted to the application.

## Prohibited shortcuts

Do not add:

- `script-src *`
- `script-src 'unsafe-inline'`
- `script-src 'unsafe-eval'`

unless a security owner has explicitly approved the exception and documented why it is unavoidable.

## Changes

Any CSP change should:

1. Identify the new origin/script/style requirement.
2. Verify whether a nonce/hash or self-hosting can avoid a broader source.
3. Test production behavior.
4. Review for unintended script execution paths.
5. Update security documentation if the trust boundary changes.

Use CSP reporting/monitoring where practical.

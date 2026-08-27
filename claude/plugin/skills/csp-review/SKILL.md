---
name: csp-review
description: Reviews Content Security Policy and web security headers for unsafe directives, overly broad origins, and accidental weakening of the security boundary. Use when adding or changing CSP, security headers, CORS, an external script or iframe origin, or when a build/runtime error points at CSP.
---

# CSP Review

Inspect application security headers and CSP configuration.

## Reject unsafe shortcuts

Flag:

- `script-src *`
- `script-src 'unsafe-inline'`
- `script-src 'unsafe-eval'`
- broad `connect-src`
- broad `frame-src`
- unnecessary `data:` or `blob:`
- missing `object-src 'none'`
- missing `base-uri`
- missing `frame-ancestors` where applicable

Prefer:

- `'self'`
- nonces
- hashes
- explicit trusted origins

For every external origin, identify why it is needed.

Check whether the change could allow attacker-controlled JavaScript execution.

Do not weaken CSP solely to resolve a frontend build/runtime error.

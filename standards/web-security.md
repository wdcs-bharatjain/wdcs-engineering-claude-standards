# Web Security Baseline

Apply OWASP-aligned secure development practices.

## Input

Validate:

- type.
- length.
- format.
- range.
- allowed values.

Do not trust client-side validation.

## Output

- Escape HTML where needed.
- Avoid raw HTML injection.
- Avoid dangerous DOM sinks.
- Treat URLs as untrusted data.

## Authentication

- Secure session lifecycle.
- Appropriate session expiration.
- Secure cookies where applicable.
- CSRF protection where applicable.
- Do not expose credentials to client-side JavaScript.

## Authorization

Every privileged API must enforce authorization on the server.

Do not rely on:

- hidden UI controls.
- client-side roles.
- route obscurity.
- frontend checks.

## CORS

Use explicit allowlists. Avoid wildcard origins for credentialed APIs.

## SSRF

When server-side code fetches user-controlled or partially controlled URLs:

- validate schemes.
- restrict destinations.
- block private/internal ranges where appropriate.
- prevent redirects from bypassing destination restrictions.
- apply timeouts and response size limits.

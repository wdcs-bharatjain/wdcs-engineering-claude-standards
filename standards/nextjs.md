# Next.js Standards

## Architecture

Prefer the App Router and Server Components by default.

Use Client Components only when client-side interactivity/browser APIs/state require them.

Avoid adding `"use client"` at high-level boundaries unnecessarily.

## Security

- Never expose secrets through `NEXT_PUBLIC_*`.
- Do not place privileged operations exclusively in client components.
- Validate authorization on the server.
- Treat route parameters, search parameters, headers, cookies, form data, and request bodies as untrusted.
- Avoid `dangerouslySetInnerHTML`; if unavoidable, sanitize trusted content and document the reason.
- Validate redirect destinations.
- Avoid exposing internal errors.
- Use secure headers and CSP.

## Data access

Keep privileged data access on the server.

Do not send sensitive server-side data to the browser merely because it is convenient.

## Performance

- Prefer server rendering where appropriate.
- Avoid unnecessary client-side JavaScript.
- Use caching deliberately.
- Avoid unbounded server work.
- Apply timeouts to external calls.

## Quality

Use strict TypeScript.

Run:

- formatter.
- ESLint.
- type checking.
- unit/integration tests.
- production build where appropriate.

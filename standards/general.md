# General Engineering Standards

## Design

- Prefer simple, explicit designs over unnecessary abstraction.
- Reuse existing patterns before introducing new patterns.
- Keep modules cohesive and dependencies directional.
- Avoid unrelated changes in the same pull request.
- Do not introduce a framework/library solely for a small utility.

## Naming

- Variables/functions: `camelCase` where idiomatic.
- Types/classes/interfaces: `PascalCase`.
- Constants: `UPPER_SNAKE_CASE` when they are true constants/configuration identifiers.
- Booleans should communicate state or capability: `isActive`, `hasPermission`, `canExecute`.
- Database identifiers: `snake_case`.
- API paths: lowercase kebab-case.
- Avoid abbreviations unless they are established domain terms.

Language-specific idioms take precedence over generic naming rules.

## Error handling

- Handle errors at meaningful boundaries.
- Do not silently swallow errors.
- Never expose stack traces, secrets, tokens, SQL, internal hostnames, or infrastructure details to untrusted clients.
- Use stable machine-readable error codes for APIs where appropriate.
- Log enough context for diagnosis without logging secrets or sensitive payloads.

## Configuration

- Configuration belongs in environment/runtime configuration, not source code.
- Validate required configuration at startup.
- Fail closed when security-critical configuration is missing.

## API design

- Validate all untrusted input.
- Authenticate before authorization.
- Authorize every privileged operation.
- Use consistent response/error formats.
- Apply pagination and limits to unbounded collection endpoints.
- Apply request size, timeout, and rate limits appropriate to the endpoint.

## Concurrency

- Identify race conditions when modifying shared state, queues, balances, caches, or transaction processing.
- Use idempotency for operations that may be retried.
- Database transactions must cover the complete consistency boundary.

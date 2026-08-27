# NestJS Standards

## Modules

Keep modules cohesive and define clear dependency boundaries.

Avoid a giant shared module that becomes a dumping ground.

## Controllers

Controllers should be thin:

- validate input.
- authenticate/authorize.
- delegate business logic.
- map responses.

Business logic belongs in services/domain modules.

## Validation

Use DTO validation and reject unexpected properties.

Recommended baseline:

- `whitelist: true`
- `forbidNonWhitelisted: true`
- `transform: true`

## Security

- Authentication guards for protected routes.
- Explicit authorization checks for privileged actions.
- Rate limits for abuse-sensitive endpoints.
- Explicit CORS allowlist.
- Security headers.
- Request/body size limits.
- Timeouts on external calls.
- Safe error responses.

## Database

Use parameterized queries/ORM APIs.

Transactions should cover consistency boundaries.

Do not expose database entities directly if doing so leaks internal fields or creates an unstable API contract.

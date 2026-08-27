# Logging and Observability

## Logging

- Use structured logging.
- Use appropriate log levels.
- Include correlation/request IDs where available.
- Never log passwords, private keys, seed phrases, session tokens, API keys, authorization headers, or full sensitive payloads.
- Avoid logging raw user data unless necessary.

## Metrics

Track meaningful operational metrics:

- request latency.
- error rates.
- queue depth.
- transaction/indexing lag.
- database health.
- external dependency failures.

## Errors

Errors returned to clients should be safe and stable.

Internal logs may contain diagnostic context, but must still respect secret and privacy rules.

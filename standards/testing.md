# Testing Standards

## General

Behavioral changes require tests unless there is a documented reason not to.

Prefer:

1. Unit tests for deterministic business logic.
2. Integration tests for boundaries.
3. End-to-end tests for critical user journeys.
4. Property/invariant tests for financial and blockchain logic.

## Test quality

Tests should:

- Be deterministic.
- Avoid dependence on wall-clock time where possible.
- Avoid production services unless explicitly intended.
- Assert behavior, not implementation details.
- Include failure and authorization cases.

## Security testing

For security-sensitive code, include negative tests:

- unauthenticated request.
- authenticated but unauthorized request.
- malformed input.
- boundary values.
- replay/duplicate request.
- rate-limit behavior where relevant.
- invalid signature/nonce where relevant.

## Blockchain

Financial and smart-contract code should include invariants where meaningful.

Examples:

- total supply remains consistent.
- vault balance equals the sum of tracked balances.
- unauthorized accounts cannot mutate protected state.
- a proposal cannot execute twice.

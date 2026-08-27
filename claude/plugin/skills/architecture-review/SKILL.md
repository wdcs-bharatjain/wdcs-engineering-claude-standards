---
name: architecture-review
description: Reviews a proposed implementation for architecture, module boundaries, coupling, data flow, scalability, failure handling, and security boundaries. Use before a large refactor, a new subsystem or service, a data-model change, or any change that moves a trust boundary.
disable-model-invocation: true
---

# Architecture Review

Review before large refactors or new subsystems.

Check:

- module ownership
- dependency direction
- public/private boundaries
- data flow
- state ownership
- transaction boundaries
- failure modes
- retries/idempotency
- caching
- concurrency
- observability
- security boundaries
- migration/rollback strategy

Prefer the smallest architecture that solves the actual problem.

Do not introduce abstractions without a concrete reuse or boundary benefit.

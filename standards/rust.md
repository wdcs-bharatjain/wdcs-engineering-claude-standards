# Rust Standards

Use ecosystem tooling:

- `cargo fmt`
- `cargo clippy`
- `cargo test`
- `cargo audit`
- `cargo deny` where adopted

## Unsafe

Avoid `unsafe`.

If `unsafe` is necessary:

1. Isolate it.
2. Document safety invariants.
3. Minimize the unsafe surface.
4. Add focused tests.
5. Require code-owner/security review where appropriate.

## Error handling

Prefer explicit typed errors and propagation.

Avoid `unwrap()`/`expect()` on attacker-controlled or production-critical paths unless the invariant is genuinely guaranteed and documented.

## Concurrency

Review ownership, locking, cancellation, task lifecycle, and shared-state behavior.

## Crypto

Use established audited crates. Never implement cryptographic primitives yourself.

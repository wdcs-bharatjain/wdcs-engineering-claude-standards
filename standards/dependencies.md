# Dependency Standards

Dependencies are part of the attack surface.

Before adding a dependency:

1. Verify the package/repository identity.
2. Prefer established, maintained packages.
3. Check license compatibility.
4. Check known vulnerabilities.
5. Check transitive dependencies.
6. Avoid packages that duplicate existing functionality without a clear benefit.
7. Record why the dependency is needed.

Never install a package solely because an AI model suggested its name.

Use ecosystem tooling where applicable:

- Node.js: lockfile + dependency audit/dependency review.
- Rust: `cargo audit`, `cargo deny` where adopted.
- Solidity: prefer established audited libraries such as OpenZeppelin where appropriate.
- Move: prefer well-maintained ecosystem modules and review dependency source.

CI should fail or require explicit review for high/critical dependency vulnerabilities.

# Move Standards

Review:

- signer authorization.
- capability design.
- resource ownership.
- resource acquisition/release.
- module visibility.
- friend relationships.
- object ownership.
- abort conditions.
- integer boundaries.
- transaction invariants.
- upgrade compatibility.
- privileged capability storage.

Prefer explicit capabilities over ad-hoc authorization.

For financial logic, define invariants and test unauthorized and boundary cases.

Use compiler checks, unit tests, and Move Prover where appropriate.

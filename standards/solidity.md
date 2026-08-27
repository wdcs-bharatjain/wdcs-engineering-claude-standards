# Solidity Standards

Smart contracts are security-critical by default.

## Required review areas

- Access control.
- Reentrancy.
- Checks-effects-interactions.
- External calls.
- Oracle manipulation.
- Flash-loan interactions.
- Price/slippage assumptions.
- Signature replay.
- Nonces and domain separation.
- EIP-712 correctness where used.
- Upgradeability and initializer protection.
- Proxy/storage layout.
- Delegatecall.
- Token compatibility.
- Callback behavior.
- Denial of service/gas griefing.
- Emergency/pause controls.
- Privileged role management.

## Development

Prefer Foundry where adopted:

- `forge fmt`
- `forge build`
- `forge test`
- fuzz tests
- invariant tests

Use static analysis such as Slither where available.

Prefer established audited libraries.

## Financial logic

Write invariants before implementation when possible.

Never rely only on happy-path tests.

## Review language

Do not state "secure" or "audit complete" based solely on automated or AI review.

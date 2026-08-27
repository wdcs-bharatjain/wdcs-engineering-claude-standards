---
name: security-review
description: Performs a security-focused review of current changes or a codebase. Use for authentication, authorization, secrets, CSP, CORS, APIs, wallets, blockchain, smart contracts, dependencies, infrastructure, or before completing a risky change.
---

# WDCS Security Review

Review the current diff first.

## Check

### Input and injection
- SQL/NoSQL injection
- command injection
- XSS
- template injection
- SSRF
- path traversal
- unsafe deserialization

### Authentication
- session lifecycle
- credential handling
- cookie security
- CSRF where applicable

### Authorization
- server-side authorization
- object-level authorization
- admin/privileged operations
- tenant/account isolation

### Secrets
- hardcoded credentials
- leaked environment variables
- private keys
- wallet seed phrases
- tokens in logs

### Web security
- CSP
- CORS
- security headers
- redirects
- file uploads
- request limits

### Dependencies
- new packages
- suspicious package names
- known vulnerabilities
- unnecessary dependency additions

### Blockchain
- signatures/replay
- nonce handling
- access control
- reentrancy
- external calls
- oracle assumptions
- invariant violations
- authorization/capability design

## Output

Classify findings:

- CRITICAL
- HIGH
- MEDIUM
- LOW
- INFORMATIONAL

For every finding provide:
1. Location.
2. Why it matters.
3. Exploit/impact scenario.
4. Recommended remediation.

Do not claim the code is secure. State that the review only covers the checks performed.

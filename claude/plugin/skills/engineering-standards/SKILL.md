---
name: engineering-standards
description: Applies WDCS organization-wide engineering standards for code structure, naming, maintainability, testing, Git, dependencies, and secure development. Use when designing, implementing, refactoring, or reviewing code in any WDCS project.
---

# WDCS Engineering Standards

Apply the organization-wide standards.

## Always

- Inspect existing architecture before changing it.
- Prefer existing patterns over introducing new abstractions.
- Keep changes focused.
- Use idiomatic conventions for the language/framework.
- Validate untrusted input.
- Handle errors explicitly.
- Add tests for behavioral changes.
- Do not introduce dependencies without justification.
- Never weaken security controls to make a task pass.

## Naming

- Use idiomatic language naming.
- Use descriptive booleans such as `isActive`, `hasPermission`, `canExecute`.
- Avoid unclear abbreviations.
- Keep API and database naming consistent with the project's established conventions.

## Completion

Before declaring completion, run relevant formatter, linter, type checks, tests, build, and security checks.

If a check cannot be run, report that clearly.

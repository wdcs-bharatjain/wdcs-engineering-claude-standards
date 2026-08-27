---
name: dependency-review
description: Reviews proposed dependency additions or upgrades for package identity, maintenance, license, vulnerabilities, transitive risk, and unnecessary dependencies. Use before installing a new package, bumping a major version, or acting on a package name suggested by an AI model.
disable-model-invocation: true
---

# Dependency Review

For every added dependency:

1. Verify exact package name and ecosystem.
2. Check whether it is an official/expected package.
3. Check maintenance/activity.
4. Check license compatibility.
5. Check known vulnerabilities.
6. Inspect transitive dependency impact.
7. Check whether the repository already has an equivalent capability.
8. Explain why the dependency is justified.

AI-generated package names must be independently verified.

Never install a package merely because a model suggested it.

---
name: audit-backend-naming
description: >
  Audits Java backend class and method names against their actual responsibilities, effects, and
  caller expectations. Proposes precise renames and optionally applies them across a Spring Boot project.
argument-hint: "[--dir=<path>] [--apply]"
---

# Audit Backend Naming

Find names that give callers the wrong mental model or make them read the implementation to
understand an important distinction. Favor a short, evidence-backed list over broad style churn.

## Arguments

- **`--dir=<path>`** limits the audit to a backend directory or module. Default to the backend
  scope of the current project. Look outside it when checking references to in-scope symbols.
- **`--apply`** applies high-confidence renames. By default, report candidates without editing.

```text
$audit-backend-naming
$audit-backend-naming --dir=backend/core/application
$audit-backend-naming --apply
$audit-backend-naming --dir=backend/public-api --apply
```

## Audit

Read applicable project instructions and established naming conventions. Follow representative
controller, service, repository, and scheduled flows through their callers. For each candidate,
check what it returns, what it can change, which layer owns it, and how callers use it.

- **Classes** should name a coherent responsibility or the value they represent. Distinguish an
  ID resolver from a general content service, or an image uploader from an image reader, when
  the distinction helps readers find the right entry point. Use package context to keep names short.
- **Methods** should start with a verb that tells callers what happens. Prioritize side effects and
  distinctions that matter at the call site. For example, `findOrCreateCommunityId` signals a
  possible insert, `lockByPublicId` signals a row lock, `markVerified` records a completed check,
  and `scheduleRetry` sets up a future attempt. Preserve idiomatic record accessors, predicates,
  conversions, and framework or interface methods.
- **Terms** should match the domain and existing contracts. Check whether names confuse a public
  ID with an internal ID, a provider's acceptance with delivery, or a database mutation with
  application validation. Leave conventional short names where the surrounding type supplies
  the meaning.

Report each worthwhile candidate with its source location, current name, proposed name, and what
the new name tells the caller. Lead with misleading behavior. Flag renames that affect a published
or runtime contract and explain the dependency. An empty shortlist is a valid result.

## Apply and Verify

With `--apply`, make the high-confidence renames within scope. Update declarations, source
filenames, callers, imports, tests, and directly affected docs. Check non-compiler references where
relevant, including Spring bean names and qualifiers, SpEL expressions, reflection, serialization,
and generated OpenAPI operation IDs. Keep external names stable unless the change explicitly
includes them.

Compile the affected modules and their callers using the project's checks. Search for stale
references and verify affected framework wiring when compilation alone cannot catch a rename.
Summarize the renames and the checks performed.

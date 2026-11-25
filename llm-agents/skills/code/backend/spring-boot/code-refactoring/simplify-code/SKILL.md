---
name: simplify-code
description: >
  Audits Java backend code for duplicated behavior and substantial handwritten mechanisms.
  Proposes and optionally applies simpler implementations using shared logic or existing APIs.
argument-hint: "[--dir=<path>] [--apply]"
---

# Simplify Code

Find focused refactoring opportunities in a Java or Spring Boot backend. Favor changes that leave
callers easier to read, reduce the number of places a rule can drift, or hand a well-defined
mechanism to an API that already handles it.

## Arguments

- **`--dir=<path>`** limits the pass to a backend directory or module. Default to the backend scope
  of the current project. Inspect related callers and module dependencies as needed.
- **`--apply`** applies high-confidence refactors. By default, report candidates without editing.

```text
$simplify-code
$simplify-code --dir=backend/core/application
$simplify-code --apply
$simplify-code --dir=backend/core/email --apply
```

## Find Candidates

Read local instructions, map module and feature boundaries, and inspect the build and managed
dependency versions. Sample code paths where Java handles parsing, mapping, encoding, I/O, query
results, or external requests by hand. Trace candidates back to real callers before proposing a
change.

- For **duplication**, check that the implementations express the same rule and should evolve
  together. Differences in defaults, visibility, error handling, or lifecycle may be intentional.
  Identify which part is actually shared and which decisions belong with each caller.
- For **handwritten mechanisms**, identify what the block does and which edge cases it owns.
  Prioritize repeated boilerplate, brittle conversions, or maintenance-heavy code with a concrete
  replacement. File length and the number of similar-looking lines are weak evidence by themselves.

## Choose the Simplest Fit

- First look for existing project code that already owns the behavior. Consolidate within the
  closest meaningful owner. A private helper may be enough within one class. Across features, give
  shared logic a specific responsibility and place it where dependency direction stays clear. For
  example, a cursor codec can share URL-safe encoding while repositories own fields and validation.
- Prefer the JDK and existing framework APIs for standard work. In a Spring project, a typed
  Jackson request can clarify a provider payload, and jOOQ can map grouped query results directly.
  Keep provider retry rules, visibility filters, and other product decisions explicit.
- Consider an established library when it materially replaces handwritten code across real call
  sites or handles difficult edge cases. Check the exact API in official documentation against the
  project's Java version and managed dependencies. Compare the readability gain with the build,
  transitive dependency, and maintenance cost. Commons Codec can replace repeated digest
  boilerplate. MapStruct is a better fit for repeated structural mappings than for mappings
  dominated by redaction or business rules. Declare a library in the module that imports its
  types, following the build's dependency management and exposure conventions.
- Keep local code when it already expresses the rule clearly. Prefer an abstraction that removes
  decisions from callers over one that moves the same branches into a new file.

## Apply and Verify

With `--apply`, make the smallest coherent set of changes that addresses the evidence. Preserve
existing API contracts, persisted and wire formats, transaction boundaries, and resource limits.
Compare old and new behavior where the replacement is subtle. Examples include exact bytes for
existing hashes and cursors, omitted versus empty JSON fields, and ordering, null handling, or
counts in query results.

Use the project's build and focused checks for the touched paths. After verification, surface
larger or uncertain ideas as follow-ups. In the default audit, cite the concrete locations and give
the proposed extraction or API, why it helps, and the behavior it must preserve. With `--apply`,
summarize the changes, any dependency added, and the verification results.

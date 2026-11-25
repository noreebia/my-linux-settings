---
name: update-docs
description: >
  Reconciles canonical project documentation with recent implementation and product changes. Use
  for end-of-work documentation housekeeping, not broad documentation reorganization or an
  ordinary one-file writing request.
---

# Update Documentation

Bring the project's existing documentation into alignment with what the product and code now do.
Treat restraint as part of accuracy: record durable behavior and decisions, not every edit made
during implementation.

## Establish the Change Surface

Read applicable repository instructions and inventory the canonical product, technology,
operational, and contributor documentation. Inspect the working tree, recent commits or branch
diff, and the implementation behind claims that may have changed. Use the repository's actual
behavior and configuration as evidence; commit subjects and old plans are only discovery aids.

Determine which changes materially affect one or more of the following:

- customer-visible behavior, supported workflows, routes, or terminology;
- public contracts, configuration, setup, deployment, or maintenance procedures;
- architectural boundaries, data models, security assumptions, or durable technical decisions;
- implemented versus deferred scope;
- contributor instructions that would otherwise send future work to the wrong place or workflow.

Do not document incidental styling adjustments, mechanical refactors, temporary debugging,
file-by-file implementation detail, or internal names that do not help a future reader understand
or maintain the system.

## Reconcile the Canonical Sources

Update the smallest set of authoritative documents that resolves the drift. Preserve each
document's purpose and the project's existing organization, metadata, terminology, and formatting
conventions.

- Put present product behavior in canonical product documentation.
- Put current implementation and operating guidance in the relevant technical or contributor
  documentation.
- Keep future work clearly separate from implemented behavior.
- Preserve durable historical rationale in decision history, but do not make historical documents
  the source of truth for current behavior.
- Correct nearby contradictions discovered while verifying the changed subject, even if they
  predate the latest implementation. Do not turn that allowance into an unbounded rewrite.
- Prefer a concise canonical explanation plus links over repeating the same detail in several
  places.

Do not create a dated audit report merely to describe the edits. Modify canonical documentation
directly. Do not reorganize the documentation tree, rename files, or delete historical material
unless that is necessary to resolve actual drift and the request authorizes the broader cleanup;
use a documentation-refinement workflow for a repository-wide information-architecture overhaul.

## Stopping Rule

Perform one implementation-to-documentation reconciliation pass, then one verification scan for
stale terminology, paths, status claims, and references related to the changed areas. Fix concrete
contradictions found by that scan and stop. Do not repeatedly search for new prose to improve once
the canonical sources are accurate and discoverable.

## Validate

Use the repository's documentation formatter or checks when available. Validate local Markdown
links, search for superseded terminology and paths relevant to the update, run `git diff --check`,
and review the final diff for accidental churn or unsupported claims. Run code checks only when
the documentation change also modifies executable or generated files.

Report:

- which canonical subjects were updated;
- any stale guidance corrected outside the immediate change surface;
- validation performed;
- any material claim that could not be verified.

If the implementation caused no meaningful documentation drift, say so and leave the files
unchanged.

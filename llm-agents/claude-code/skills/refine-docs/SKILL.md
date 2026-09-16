---
name: refine-docs
description: >
  Audits and refines a project's canonical documentation by organizing it, removing stale or duplicated material, clarifying sources of truth, and repairing references. Use for documentation housekeeping rather than an ordinary one-file copy edit.
---

# Refine Documentation

Turn the project's documentation into a coherent, current body of knowledge. Improve the existing information architecture rather than imposing a generic folder template.

## Audit

Read the repository instructions, inventory the documentation, and inspect inbound links before editing. Read enough of the implementation and current configuration to verify load-bearing claims; filenames and old plans are not evidence that a document is still accurate.

Classify content by purpose:

- canonical current product or technical guidance;
- durable decision history whose rationale or rollback boundary remains useful;
- operational or deferred-area documentation;
- temporary plans, handoffs, generated notes, and superseded material.

Identify conflicting claims, stale status statements, unclear ownership, duplicated explanations, broken links, opaque filenames, and documents that mix current truth with historical rationale.

## Refine

- Preserve one canonical home for each subject. Replace repeated implementation detail elsewhere with a concise summary and link.
- Keep present behavior in canonical product or technology documentation. Keep historical tradeoffs and reversal instructions in clearly labeled decision history.
- Organize files into a small number of meaningful directories only when that improves discovery. Add or update an index when readers otherwise have to infer the structure.
- Use short, readable, context-rich filenames. Canonical filenames should not depend on timestamps or an agent's storage convention.
- Preserve useful content before removing a redundant file. Delete documents only when the housekeeping request authorizes it and their unique, still-current information has been merged or proven obsolete.
- Respect the repository's metadata, formatting, and naming conventions. Avoid broad prose rewrites that do not improve accuracy or navigation.
- Update references outside the documentation only as needed to keep links and source-of-truth pointers correct.

Do not convert every historical artifact into canonical documentation. A completed plan may be safely retired; a consequential decision may deserve a compact history record; an active roadmap belongs with current documentation rather than decision history.

## Validate

Check every local Markdown link after moves or renames, search for stale old paths and superseded terminology, run the repository's documentation formatter when one exists, and run `git diff --check`. Review the final tree and diff for accidental churn or lost content.

Report the new organization, canonical sources established, material merged or removed, and any claims that could not be verified.

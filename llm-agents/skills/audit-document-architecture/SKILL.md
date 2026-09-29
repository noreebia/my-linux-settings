---
name: audit-document-architecture
description: >
  Audits whether one document has the right scope and level of detail within a project's broader
  documentation architecture. Optionally applies a focused slimming or redistribution of content
  without turning the task into a repository-wide reorganization.
argument-hint: "--file-path=<path> [--apply]"
---

# Audit Document Architecture

Evaluate a target document as one part of the project's documentation system. Determine whether it
orients its intended readers efficiently, owns the right information, and points to deeper sources
without duplicating them.

## Arguments

- **`--file-path=<path>`** *(required)*: The document to assess.
- **`--apply`** *(optional flag)*: Apply the high-confidence recommendations. Without this flag,
  stay read-only and report the assessment.

Examples:

```text
/audit-document-architecture --file-path=README.md
/audit-document-architecture --file-path=frontend/README.md --apply
$audit-document-architecture --file-path=docs/contributing.md
$audit-document-architecture --file-path=docs/architecture/README.md --apply
```

## Establish the Document's Job

Read the target completely, along with applicable repository instructions. Identify its intended
audience, the task that brings readers to it, and the minimum information they need before following
links or opening neighboring files.

Inventory the documentation that the target links to, duplicates, summarizes, or should route to.
Inspect inbound links and nearby indexes so recommendations preserve discoverability. Verify
technical or product claims against canonical documentation and, when necessary, implementation;
do not infer ownership from filenames alone.

Judge the target relative to its role:

- Entry-point documents should orient readers, expose essential commands or constraints, and route
  them to authoritative detail.
- Topic documents should explain one coherent subject deeply enough to be useful without requiring
  unrelated context.
- Directory READMEs should explain that directory only when the directory represents a meaningful
  ownership or navigation boundary.
- Code comments should preserve local invariants and reasoning, not absorb project-level guidance
  merely to shorten a document.
- Decision history should retain durable rationale and reversal boundaries without becoming the
  source of truth for current behavior.

## Classify the Content

For each substantial section, choose the smallest sound treatment:

- **Keep:** essential to the target's immediate purpose.
- **Compress:** important orientation whose current detail exceeds what readers need at entry.
- **Link:** already owned by a canonical source that the target should summarize and reference.
- **Move:** useful information with a clear, better owner elsewhere.
- **Retire:** stale, duplicated, incidental, or no longer useful material.

Consider context cost alongside discoverability, uniqueness, volatility, and maintenance risk. A
long section is not automatically misplaced, and a short document is not automatically good. Do
not split content merely to reduce line count; a new file or nested README must create a clearer
ownership boundary and remain findable from the paths readers actually use.

Preserve one authoritative home for each subject. When duplication is serving a distinct audience,
prefer a concise audience-specific summary plus a canonical link rather than eliminating all local
context.

## Scope Boundary

This is a target-first audit, not a general documentation cleanup. Follow connections far enough to
judge the target responsibly, but do not silently reorganize the whole documentation tree.

If the target can be improved through focused edits and a small number of necessary companion
changes, keep the work here. If the evidence instead shows that several peer documents lack clear
ownership, canonical sources conflict, or the navigation hierarchy itself needs redesign, report
that as a repository-wide concern and recommend `refine-docs`. Do not expand into that broader work
unless the user authorizes it.

## Apply and Validate

With `--apply`, preserve all unique, current, and operationally important information. Make the
target concise enough for its role, move material only to an established or clearly justified home,
and update the minimum necessary links or indexes. Respect unrelated working-tree changes and the
repository's naming, metadata, and formatting conventions.

Validate local Markdown links affected by the edits, search for stale paths introduced by moves,
run the repository's documentation formatter when one exists, and run `git diff --check`. Review
the final diff for lost information, accidental scope expansion, and needless prose churn.

## Report

Lead with whether the document is appropriately scoped. Explain what should remain local, what is
costly or duplicative, where displaced detail belongs, and why the proposed structure improves the
reader path and maintenance model. Distinguish focused recommendations from repository-wide issues.

When `--apply` is used, summarize the resulting responsibility of the target, any companion files
changed, and the validation performed. Do not use reduced word or line count as proof of success.

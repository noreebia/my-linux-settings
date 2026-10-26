---
name: housekeep-agent-docs
description: >
  Assesses agent-produced documentation, merges worthwhile knowledge into maintained sources,
  retains useful working documents, and prunes completed, superseded, or redundant artifacts.
---

# Housekeep Agent Documentation

Reduce the maintenance and context burden of temporary agent documentation while preserving
knowledge that remains useful. Promotion, retention, and deletion are all valid outcomes. Accurate
information alone does not justify keeping a document.

## Establish Context

Read repository instructions and inventory the requested documentation scope, defaulting to
`$AGENT_DIR` (`agents/` at the repository root unless configured otherwise). Read each candidate
before deciding its fate, along with relevant maintained documentation and inbound references.
Verify consequential claims and implementation status against current code, schema, configuration,
or other reliable evidence. Treat filenames, age, and completion labels as discovery aids.

Leave runtime agent instructions, configuration, executable helpers, raw transcripts, and other
non-document artifacts alone unless explicitly included. Respect unrelated working-tree changes
and ongoing work from other sessions. An assessment-only request stays read-only; a cleanup
request includes pruning artifacts whose disposition can be established confidently.

## Assess the Information, Then the File

Judge substantial content by its future usefulness, uniqueness, evidential support, and maintenance
owner. Favor information that helps someone operate, change, or understand the project: meaningful
constraints, decisions, unresolved requirements, and reproducible procedures. Execution checklists,
intermediate outputs, and temporary reasoning often lose their purpose after the work concludes.

A document can contain several kinds of material. A completed plan may have obsolete steps, useful
rationale, and an open verification requirement. Give each a disposition before deciding whether
the source file still serves an independent purpose:

- **Prune:** remove temporary byproducts, completed checklists, superseded proposals, or intermediate
  reports when they have no remaining value. No replacement document or archive is required.
- **Remove redundancy:** delete an artifact whose useful information is already covered accurately
  in maintained sources.
- **Extract and merge:** preserve unique, durable guidance or consequential rationale in its proper
  home, then remove the source when it has no independent purpose.
- **Retain or slim:** keep active plans, investigations, and coordination notes useful to ongoing
  work. Preserve unresolved requirements even when the implementation is largely complete. An
  agent's working checklist can remain here without becoming an official roadmap.
- **Retain with uncertainty:** leave material whose status or unique value cannot be established,
  and report the specific uncertainty.

## Distribute Worthwhile Knowledge

Prefer merging the minimum useful material into an existing authoritative source. Follow the
project's ownership: module-specific guidance can live near its source; shared subjects belong at
a meaningful shared boundary; project-wide knowledge belongs in central documentation. Create a
new maintained document only when its coherent, lasting purpose justifies one.

Reconcile extracted content with current evidence and destination guidance. Preserve important
invariants, rationale, operating constraints, and remaining verification work while removing
conversational framing and obsolete execution detail. Distinguish current behavior, proposals,
and historical decisions. Unsupported claims should not gain authority through relocation.

Use readable canonical filenames and preserve historically meaningful decision dates. Link to
authoritative detail rather than leaving competing explanations in retained working notes.

Verify the destination before removing a source that contributed unique information. Repair inbound
links and indexes affected by removals or moves. Remove empty documentation-only directories when
safe; preserve directories containing unrelated or non-document artifacts.

Keep the work scoped to agent documents and the destination edits needed to absorb their useful
content. Broader documentation restructuring is a separate task.

## Validate

Validate affected local Markdown links, including heading fragments and inbound references, search
for retired paths and filenames, run the available documentation formatter, and run
`git diff --check`. Review the final diff for lost requirements and accidental scope expansion.

Report what was merged and where, what was deleted and why, what remains useful as working
documentation, and any unresolved uncertainty. Stop once the requested scope and its affected
references have been reconciled and verified.

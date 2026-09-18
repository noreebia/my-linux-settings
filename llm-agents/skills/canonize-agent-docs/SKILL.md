---
name: canonize-agent-docs
description: >
  Audits generated documentation under $AGENT_DIR and promotes durable decisions or current guidance into the project's canonical docs while retiring redundant agent artifacts. Use when exporting or canonizing agent-produced documents, not for copying runtime agent configuration.
---

# Canonize Agent Documentation

Promote useful generated documents from `$AGENT_DIR` into the project's maintained documentation. This is a selective editorial migration, not a bulk copy.

## Establish Context

Read repository instructions, the canonical documentation tree, and every candidate document under `$AGENT_DIR` before deciding its fate. Check current code, schema, configuration, or product docs when a generated artifact makes a load-bearing claim that may have gone stale.

Ignore runtime agent configuration, executable helpers, transcripts, and other non-document artifacts unless the user explicitly includes them. Preserve unrelated work from other agents.

## Classify Each Document

Choose the destination by what the content is now, not by its source directory:

- **Current canonical guidance:** merge it into the appropriate product, technology, operations, or roadmap document.
- **Durable decision history:** preserve it when the rationale, tradeoffs, monitoring signals, or rollback instructions remain useful. Put it in the project's established decision-history area, or `docs/notable-decision-history/` when none exists.
- **Active plan or remaining work:** move its still-current requirements into a maintained roadmap or relevant canonical document; do not mislabel it as history merely because an agent authored it.
- **Superseded, completed, or duplicated artifact:** harvest any unique current information, then remove it.
- **Unclear artifact:** retain it until its unique value and current accuracy can be established.

## Canonize, Do Not Duplicate

- Prefer merging and moving over leaving parallel copies in `agents/` and `docs/`.
- Give promoted files readable, context-rich names without timestamp prefixes. Preserve an original decision date in metadata when historically meaningful.
- Normalize conversational or agent-specific wording, but retain substantive rationale and rollback detail.
- Correct stale claims during promotion and link to the canonical current document instead of repeating large implementation descriptions.
- Add or update a decision-history index when history records are retained.
- Update all inbound links, documentation indexes, and repository maps affected by the migration.

After verifying the destination, remove the redundant source document. Remove empty documentation-only agent directories when safe, but never delete `$AGENT_DIR` wholesale if it contains non-document artifacts or unrelated agent work. State what was removed and that tracked files remain recoverable through Git history.

## Validate

Verify every local Markdown link, search for old `$AGENT_DIR` paths and retired filenames, run the available formatter, and run `git diff --check`. Review the final diff to ensure that each source document was deliberately retained, merged, or removed and that no unique current requirement disappeared.

Report the classification decisions, canonical destinations, retired artifacts, and any unresolved ambiguity.

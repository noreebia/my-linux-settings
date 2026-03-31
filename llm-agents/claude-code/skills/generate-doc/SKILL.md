---
name: generate-doc
description: >
  Convert the agent's last response into a saved markdown document for future reference, sharing,
  or passing to another agent. Use this skill whenever the user wants to save, export, or persist
  a response — triggered by phrases like "save that", "turn that into a doc", "generate a document
  from your last response", "write that to a file", "export this", or any time the output of a
  previous response should be preserved for reuse. Also trigger proactively after producing long
  analyses, plans, or reports when the user will clearly want to keep the output.
---

# Generate Document

Convert the agent's last response into a well-structured markdown file for future reference, sharing with collaborators, or passing to another agent. If the last response was a short acknowledgment or question, look back further for the most recent meaningful output.

---

## Process

### 1. Choose a filename and location

Derive the filename from the content — short, lowercase, hyphenated, descriptive (e.g., `system-analysis.md`, `implementation-plan.md`, `auth-research.md`).

Save to `$AGENT_LOCAL_DIR/` unless the user specifies otherwise or there's a more natural place in the project (e.g., `docs/`).

### 2. Write the document

Do a light editorial pass — don't just dump the raw response:

- Add a title if the response didn't have one
- Add a header: `*Generated: <datetime> | Author: <agent-name> | Source: <brief context>*`
- Clean up conversational artifacts ("Sure!", "Great question", "As I mentioned")
- Preserve all structure (headings, lists, code blocks, tables, diagrams)
- Don't summarize or compress — keep the full content

Tell the user where the file was saved. If it's ready to pass to another skill (e.g., `review-doc`), mention that.

**Author name**: The `<agent-name>` identifies which agent produced the document (e.g., `Claude`, `Codex`, `Gemini`).

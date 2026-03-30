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

Convert the agent's last response into a well-structured markdown file for future reference, sharing with collaborators, or passing to another agent.

---

## Process

### 1. Identify the content

The source is your most recent substantive response in this conversation. If the last response was a short acknowledgment or question, look back further for the most recent meaningful output.

If it's unclear what should go into the document, ask the user before proceeding.

---

### 2. Choose a filename and location

**Filename:** Derive it from the content — short, lowercase, hyphenated, descriptive.

| Content type | Example filename |
|---|---|
| System / codebase analysis | `system-analysis.md` |
| Implementation plan | `implementation-plan.md` |
| Situation or problem analysis | `situation-analysis.md` |
| Meeting notes / summary | `meeting-notes-<date>.md` |
| Research or investigation | `<topic>-research.md` |

**Location:** Save to `$AGENT_DIR/` unless the user specifies otherwise or there is a more natural place in the project (e.g., `docs/`).

---

### 3. Write the document

Don't just dump the raw response. Treat this as a light editorial pass:

- **Add a title** (`# Title`) if the response didn't have one
- **Add a brief header block** with the datetime, author, and origin context — e.g.:
  ```
  *Generated: 2024-01-15 14:30 | Author: <agent-name> | Source: system analysis conversation*
  ```
  The author name identifies which agent produced the document (e.g., `claude`, `codex`, `gemini`).
- **Preserve all structure** — headings, lists, code blocks, tables, diagrams
- **Clean up conversational artifacts** — remove phrases like "Sure!", "Great question", "As I mentioned", or any text that only made sense as a chat reply
- **Don't summarize or compress** — the document should be the full content, not a shortened version of it

---

### 4. Confirm with the user

Tell the user where the file was saved and what it contains in one sentence. If the document will be used as input to another skill (e.g., `review-doc`), mention that it's ready to pass along.

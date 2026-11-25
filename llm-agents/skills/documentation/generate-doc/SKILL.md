---
name: generate-doc
description: >
  Converts the agent's last meaningful response into a saved markdown document for future reference, sharing, or passing to another agent.
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
- Add a metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <what was converted, e.g. "system analysis response" or "auth refactor plan">*`
- Clean up conversational artifacts ("Sure!", "Great question", "As I mentioned")
- Preserve all structure (headings, lists, code blocks, tables, diagrams)
- Don't summarize or compress — keep the full content

Tell the user where the file was saved.

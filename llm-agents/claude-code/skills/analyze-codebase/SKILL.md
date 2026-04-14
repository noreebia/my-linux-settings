---
name: analyze-codebase
description: >
  Analyzes an unfamiliar codebase and generates developer documentation in $AGENT_LOCAL_DIR/system-analysis.
  Scales output to project complexity.
argument-hint: "[focus]"
---

# Analyze Codebase

Explore a codebase and produce documentation that gives a new developer a genuine mental model — not just a file tree tour, but how the system works, why it's structured that way, and how to navigate it.

Output lives in `$AGENT_LOCAL_DIR/system-analysis/`.

---

## Arguments

- **focus** *(optional)*: Narrow the analysis to a specific area — e.g., `auth`, `data pipeline`, `payments`. When omitted, analyzes the full codebase.

---

## Process

### 1. Check existing docs

Check `$AGENT_LOCAL_DIR/system-analysis/` for existing documentation. If a **focus** was provided, look for files or sections that already cover it. If existing docs are already thorough and accurate, tell the user and stop — don't regenerate for its own sake.

### 2. Explore the codebase

Start with the big picture (project type, dependencies, structure, entry points), then go deeper where it matters. If a focus was provided, go deep on that area after getting oriented — trace its imports, find where it plugs into the rest of the system.

### 3. Plan and write the output

**Output structure:**

| Situation | Output |
|---|---|
| Full analysis, simple project | `system-analysis/overview.md` |
| Full analysis, complex project | `system-analysis/` with numbered files (e.g., `01-overview.md`, `02-architecture.md`) |
| Focus, small topic | `system-analysis/<focus>.md` |
| Focus, large topic | `system-analysis/<focus>/` with files inside |
| Existing docs for this topic | Augment in place — update stale content, add new sections |

Write for a developer on day one. Give them the mental model to be productive: what the system does, how to run it, how it's structured (responsibilities, not file trees), how data/requests flow through it, external dependencies, etc .

For focused analysis, also cover how the component fits into the broader system and what common dev tasks look like in that area.

Use Mermaid diagrams when they genuinely clarify something prose can't — architecture, request flows, data models. Keep them focused; a diagram with 15 nodes teaches nothing.

---

## Constraints

- **Read-only**: Do not modify source files. Only write to `$AGENT_LOCAL_DIR/system-analysis/`.
- **Create the output folder** if it doesn't exist: `mkdir -p $AGENT_LOCAL_DIR/system-analysis`
- **Don't pad**: If the project is small, one well-written file is better than five thin ones.
- **Metadata header**: Include a header in each generated file: `*Analyzed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Repository: <repo name or path> | Focus: <focus area if provided>*`.

---
name: analyze-codebase
description: >
  Analyzes an unfamiliar codebase and explains its architecture and developer workflows.
  Optionally saves the analysis as developer documentation.
argument-hint: "[--file]"
---

# Analyze Codebase

Explore a codebase and produce an analysis that gives a new developer a genuine mental model — not just a file tree tour, but how the system works, why it's structured that way, and how to navigate it.

---

## Arguments

- **`--file`** *(optional flag)*: Write the analysis to `$AGENT_LOCAL_DIR/system-analysis/` instead of outputting it inline.

Examples:

```text
/analyze-codebase
/analyze-codebase --file
$analyze-codebase
$analyze-codebase --file
```

---

## Process

### 1. Check existing docs

If `--file` was given, check `$AGENT_LOCAL_DIR/system-analysis/` for existing documentation. If existing docs are already thorough and accurate, tell the user and stop — don't regenerate for its own sake.

### 2. Explore the codebase

Start with the big picture (project type, dependencies, structure, entry points), then go deeper where it matters. Trace the important execution paths and how the major components fit together.

### 3. Present the analysis

By default, present the analysis inline. Scale its depth to the project's complexity and lead with the mental model a new developer needs.

If `--file` was given, write the analysis using this structure:

| Situation | Output |
|---|---|
| Full analysis, simple project | `system-analysis/overview.md` |
| Full analysis, complex project | `system-analysis/` with numbered files (e.g., `01-overview.md`, `02-architecture.md`) |
| Existing analysis | Augment in place — update stale content, add new sections |

Write for a developer on day one. Give them the mental model to be productive: what the system does, how to run it, how it's structured (responsibilities, not file trees), how data/requests flow through it, external dependencies, etc .

Use Mermaid diagrams when they genuinely clarify something prose can't — architecture, request flows, data models. Keep them focused; a diagram with 15 nodes teaches nothing.

---

## Constraints

- **Read-only by default**: Do not modify any files unless `--file` was given.
- **File output scope**: With `--file`, only write to `$AGENT_LOCAL_DIR/system-analysis/`, creating the directory if needed.
- **Don't pad**: If the project is small, one well-written file is better than five thin ones.
- **Metadata header**: Include a header in each generated file: `*Analyzed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Repository: <repo name or path>*`.

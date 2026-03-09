---
name: analyze-codebase
description: Analyze an unfamiliar codebase and generate documentation in $DOCS_BASE/system-analysis that helps a new developer understand the system. Scales output to match the complexity of the project.
user-invocable: true
argument-hint: "[focus]"
---

# Analyze Codebase

Perform a thorough analysis of the current codebase and produce developer-friendly documentation in a `$DOCS_BASE/system-analysis` folder at the repository root. The goal is simple: a developer who has never seen this codebase should be able to read your output and understand how the system works, how it's organized, and how to work in it.

## Arguments

- **focus** (1st argument, optional): A specific area to focus the analysis on (e.g., "backend", "auth", "data pipeline"). If omitted, analyzes the entire codebase.

## Process

### 1. Check Existing Documentation (when focus argument is provided)

If a **focus** argument was provided, first check whether related documentation already exists under `$DOCS_BASE/system-analysis/`:

- Search for files and directories matching the focus topic: look for `$DOCS_BASE/system-analysis/<focus>.md`, `$DOCS_BASE/system-analysis/<focus>/`, and any files whose names or contents are clearly related to the focus argument (use fuzzy matching — e.g., focus "auth" should match `authentication.md`, `auth/`, `security.md` sections about auth, etc.).
- If existing documentation is found, read it thoroughly so you can build on it rather than replace it.
- Record what you found (or didn't find) — this informs step 3.

### 2. Reconnaissance

Explore the codebase thoroughly before writing anything. Read config files, entry points, directory structures, READMEs, and anything else that helps you build a mental model of the system. If a **focus** argument was provided, prioritize that area but still capture enough surrounding context.

### 3. Determine Scope & Output Format

#### When a focus argument is provided

Decide the output format based on the complexity of the focused topic:

**Small scope** (the topic can be covered in a single well-structured document):
- If an existing `.md` file covers this topic → **augment it in place** with your new findings. Preserve existing content that is still accurate; update or expand sections as needed.
- If no existing doc covers this topic → **create a single file** at `$DOCS_BASE/system-analysis/<focus>.md`.

**Large scope** (the topic spans multiple sub-topics):
- If an existing `.md` file covers this topic but the scope has grown beyond what fits in one file → **promote it to a directory**: create `$DOCS_BASE/system-analysis/<focus>/`, move/split the existing content into appropriately named files within it, add new content, and create a `README.md` inside that directory as a table of contents.
- If an existing directory covers this topic → **augment the existing directory**: update existing files and add new files as needed.
- If no existing doc covers this topic → **create a directory** at `$DOCS_BASE/system-analysis/<focus>/` with appropriately named files and a `README.md` table of contents.

When augmenting existing docs, do not delete information that is still correct. Add, update, and reorganize — but preserve prior work.

#### When no focus argument is provided (full codebase analysis)

Based on what you learned in reconnaissance, decide what documentation this particular project needs. Let the codebase drive the structure — write about whatever is important to understand the system. A simple project might need a single file; a complex one might need several. Only create files and sections that carry real, specific value for this project.

If `$DOCS_BASE/system-analysis/` already exists, inform the user and ask whether to overwrite, merge, or use a different directory.

### 4. Write Documentation

Write for a developer who has never seen this codebase. Be specific — reference actual file paths, function names, class names, and config keys. Every sentence should tell the reader something specific to this project, not generic advice. Use diagrams (Mermaid) only when they genuinely clarify relationships.

When generating multiple files, prefix filenames with a two-digit number to establish a reading order that builds understanding incrementally (e.g., `01-overview.md`, `02-architecture.md`). Include a `$DOCS_BASE/system-analysis/README.md` as a table of contents if there are multiple files.

### 5. Final Review

- Re-read each file and remove anything that is generic filler or duplicated across files.
- Verify file paths and names referenced in the docs actually exist.
- Ensure the docs are proportional to the project's complexity.
- If you augmented existing docs, verify the result reads coherently.

## Important

- Create the `$DOCS_BASE/system-analysis` folder at the repository root if it doesn't exist.
- Do not modify any source code. This skill is read-only except for the `$DOCS_BASE/` output.
- If the codebase is a monorepo, focus on the top-level structure and summarize each sub-project. Do not try to deeply document every sub-project unless the focus argument targets one.

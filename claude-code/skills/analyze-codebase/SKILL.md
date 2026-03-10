---
name: analyze-codebase
description: Analyze an unfamiliar codebase and generate documentation in $DOCS_BASE/system-analysis that helps a new developer understand the system. Scales output to match the complexity of the project.
user-invocable: true
argument-hint: "[focus]"
---

# Analyze Codebase

Perform a thorough analysis of the current codebase and produce developer-friendly documentation in a `$DOCS_BASE/system-analysis` folder at the repository root. The goal is simple: a brand new developer who has started to work on this project should be able to read your output and gain a good understanding of the system and how to work in it.

## Arguments

- **focus** (1st argument, optional): A specific area to focus the analysis on (e.g., "backend", "auth", "data pipeline"). If omitted, analyzes the entire codebase.

## Process

### 1. Check Existing Documentation (when focus argument is provided)

If a **focus** argument was provided, first check whether related documentation already exists under `$DOCS_BASE/system-analysis/`:

- Search for files and directories matching the focus topic: look for `$DOCS_BASE/system-analysis/<focus>.md`, `$DOCS_BASE/system-analysis/<focus>/`, and any files whose names or contents are clearly related to the focus argument (use fuzzy matching — e.g., focus "auth" should match `authentication.md`, `auth/`, `security.md` sections about auth, etc.).
- If existing documentation is found, read it thoroughly so you can build on it rather than replace it.
- Record what you found (or didn't find) — this informs step 3.

### 2. Reconnaissance

Explore the codebase thoroughly before writing anything. Read config files, entry points, directory structures, READMEs, and anything else that helps you understand the system. If a **focus** argument was provided, prioritize that area but still capture enough surrounding context.

### 3. Determine Scope & Output Format

#### When a focus argument is provided

First, compare the existing documentation (if any) against what you learned in reconnaissance. If the existing docs already thoroughly cover the focused topic and are accurate, inform the user that the documentation is already sufficient and stop — do not augment for the sake of augmenting.

If the docs are insufficient or outdated, decide the output format based on the complexity of the focused topic:

**Small scope** (the topic can be covered in a single well-structured document):
- If an existing `.md` file covers this topic → **augment it in place** with your new findings. Preserve existing content that is still accurate; update or expand sections as needed.
- If no existing doc covers this topic → **create a single file** at `$DOCS_BASE/system-analysis/<focus>.md`.

**Large scope** (the topic spans multiple sub-topics):
- If an existing `.md` file covers this topic but the scope has grown beyond what fits in one file → **promote it to a directory**: create `$DOCS_BASE/system-analysis/<focus>/`, move/split the existing content into appropriately named files within it and add content as necessary.
- If an existing directory covers this topic → **augment the existing directory**: update existing files and add new files as needed.
- If no existing doc covers this topic → **create a directory** at `$DOCS_BASE/system-analysis/<focus>/` with appropriately named files.

#### When no focus argument is provided (full codebase analysis)

Based on what you learned in reconnaissance, decide what documentation this particular project needs. Let the codebase drive the structure — write about whatever is important to understand the system. A simple project might need a single file; a complex one might need several.

### 4. Write Documentation

Write for a developer who has never seen this codebase. Use diagrams (Mermaid) when they genuinely provide value.

When generating multiple files, prefix filenames with a two-digit number to establish a reading order that builds understanding incrementally (e.g., `01-overview.md`, `02-architecture.md`). 

### 5. Final Review

- Verify file paths and names referenced in the docs actually exist.

## Important

- Create the `$DOCS_BASE/system-analysis` folder at the repository root if it doesn't exist.
- Do not modify any source code. This skill is read-only except for the `$DOCS_BASE/` output.

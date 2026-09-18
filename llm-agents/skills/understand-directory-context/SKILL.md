---
name: understand-directory-context
description: >
  Explores and understands a project directory to build a working mental model for the current
  session. Use when broad project context is needed before subsequent work, without producing
  a formal codebase analysis or changing files.
argument-hint: "[--dir=<path>]"
---

# Understand Directory Context

Explore the target directory deeply enough to understand it as a working project and carry that
understanding into the rest of the current session. The outcome is contextual readiness, not a
written report.

## Arguments

- **`--dir=<path>`** *(optional)*: Directory to understand. The path may be absolute or relative
  to the current directory. When omitted, use the current directory.

Examples:

```text
/understand-directory-context
/understand-directory-context --dir=src
$understand-directory-context
$understand-directory-context --dir=/path/to/project
```

## Scope

Use the directory supplied with `--dir`, or the current directory when the argument is omitted.
Treat the working tree as the source of truth, including relevant uncommitted changes. Follow all
applicable repository and directory-local instructions.

Stay read-only. Do not edit files, generate documentation, install dependencies, or run commands
that mutate project state.

## Exploration

Begin by orienting yourself: inspect the directory structure, local instructions, primary project
documentation, manifests, build and tool configuration, and version-control state when available.
Identify the project's purpose, languages, entry points, major components, and normal development
workflows.

Scale the investigation to the project:

- For a small directory, read all substantive human-authored files when practical. Skip binary,
  generated, vendored, dependency, cache, and other machine-produced content unless it is directly
  informative.
- For a large project, map the whole repository but read selectively. Prioritize entry points,
  component boundaries, core domain logic, shared abstractions and types, configuration, tests,
  automation, and representative implementations. Trace important relationships and execution or
  data flows far enough to understand how the pieces cooperate. Do not inspect every file merely
  for completeness.

Let discoveries guide the next reads. Resolve important references across files, compare tests with
the code they exercise, and inspect history only when it materially clarifies current structure or
intent. Prefer breadth first, then deepen around the paths that define the project.

Build a mental model that covers, as applicable:

- what the project is for and who or what uses it;
- how its major areas divide responsibility and depend on one another;
- how control, requests, or data move through the system;
- how it is configured, run, tested, built, and maintained;
- the conventions that should shape future changes;
- relevant current work and any material uncertainty that remains.

Stop when you can explain the project's spirit, predict where typical changes belong, and navigate
its important paths without another broad discovery pass. The goal is confident working context,
not exhaustive memorization.

## Completion

Respond briefly. State that the directory context has been understood, summarize the project's spirit
and shape in one to three sentences, and say that you are ready for what comes next. Mention a
material limitation only if it affects that readiness. Do not turn the completion message into a
file-tree tour or full analysis unless the user asks for one.

A natural closing is:

> Directory context understood. <Succinct project summary>. Ready to work on whatever comes next.

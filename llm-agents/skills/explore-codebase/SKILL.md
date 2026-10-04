---
name: explore-codebase
description: >
  Explores an unfamiliar codebase at repository scale to build the agent's working model of its
  architecture, behavior, conventions, and workflows. The outcome is context for subsequent work.
argument-hint: "[--dir=<path>]"
---

# Explore Codebase

Explore the target codebase deeply enough to reason about it confidently in later work. The primary
outcome is the agent's understanding carried through the current session.

## Arguments

- **`--dir=<path>`** *(optional)*: Codebase to explore. The path may be absolute or relative to the
  current directory. When omitted, use the current directory.

Examples:

```text
/explore-codebase
/explore-codebase --dir=../another-project
$explore-codebase
$explore-codebase --dir=/path/to/project
```

## Boundaries

Treat the selected working tree as the source of truth, including relevant uncommitted changes, and
follow all applicable repository and directory-local instructions.

Stay read-only. Do not edit files, generate documentation, install dependencies, or run commands
that mutate project state. Exploration prepares the agent for future work; it does not authorize
that work or expand the user's request.

## Build the Working Model

Orient at repository scale first. Inspect the structure, primary documentation, manifests, build and
tool configuration, entry points, tests, automation, and version-control state when available. Infer
what the system is for, who or what uses it, and how it is normally run, tested, built, and maintained.

Then follow the code rather than merely cataloguing it:

- identify the major areas of responsibility and the boundaries between them;
- trace representative control, request, and data flows from entry point to meaningful effect;
- understand state, persistence, external integrations, configuration, and important shared types or
  abstractions;
- connect tests to the behavior and invariants they protect;
- notice conventions, coupling, generated boundaries, and other constraints that should shape later
  changes;
- account for relevant current work without turning the exploration into a code review.

Scale the investigation to the codebase. In a small repository, read all substantive human-authored
files when practical. In a large repository, map the whole system but read selectively, deepening
around architectural boundaries, core domain logic, representative implementations, and paths most
likely to matter later. Skip vendored, generated, dependency, cache, binary, and build output unless
it directly explains the system.

Let each discovery determine the next useful read. Resolve important references across files and use
history only when it materially clarifies present intent or structure. Prefer a causal model of how
the system behaves over exhaustive file coverage.

Test the working model by checking whether you can locate where representative changes belong, anticipate their important downstream effects, explain the key execution paths to yourself, and distinguish established facts from material unknowns. Stop when another broad discovery pass would add little to future decision quality.

## Completion

Respond briefly: confirm the scope explored, summarize the codebase's purpose and shape in one or two
sentences, and state that you are ready for the next task. Mention only limitations that materially
reduce that readiness.

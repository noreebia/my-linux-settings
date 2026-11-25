---
name: audit-frontend-architecture
description: >
  Audits frontend component boundaries, reuse, coupling, and duplicated UI or behavior. Optionally
  applies high-confidence cleanup while resisting speculative abstraction and refactoring loops.
argument-hint: "[--apply]"
---

# Audit Frontend Architecture

Evaluate whether a frontend is modular at the level the product actually needs. Find concrete
sources of drift and coupling, while treating restraint as part of good architecture.

## Arguments

- **`--apply`** *(optional flag)*: Implement high-confidence improvements after the audit. Without
  this flag, stay read-only and report findings.

Examples:

```text
/audit-frontend-architecture
/audit-frontend-architecture --apply
$audit-frontend-architecture
$audit-frontend-architecture --apply
```

## What Good Looks Like

Judge the code in its own framework and project context. A healthy frontend generally has:

- components whose responsibilities and reasons to change are coherent;
- shared behavior or presentation where multiple consumers need the same contract;
- feature, route, data-access, and cross-feature utility boundaries that point in clear directions;
- one authoritative implementation for domain formatting, interaction state, and recurring
  accessibility behavior;
- deliberate differences between similar screens instead of accidental divergence;
- local code that stays local when an abstraction would add more concepts than it removes.

The goal is not maximum component count, minimum line count, or universal reuse. The goal is lower
change cost and fewer opportunities for related experiences to drift.

## Audit Method

First read applicable repository instructions and identify the frontend's framework, routing, state,
styling, data-access, and test conventions. Map the main boundaries, then inspect representative
routes, large interactive components, shared controls, hooks, utilities, and feature modules. Use
searches and comparisons to confirm duplication rather than relying on filenames or intuition.

Trace important repeated concepts end to end, especially:

- interaction logic implemented in more than one visual component;
- selectors, dialogs, tabs, forms, cards, metadata rows, and other recurring UI patterns;
- formatting, parsing, validation, error handling, and navigation rules repeated across features;
- route components that perform feature-level transport or domain work;
- shared components accumulating unrelated modes, flags, or feature knowledge;
- state and accessibility behavior that looks similar but differs between call sites.

Read enough surrounding code to preserve intentional differences. Similar markup does not by itself
prove that two components should share an abstraction.

## Signal Test

Treat a finding as high signal when there is concrete evidence such as:

- two implementations of the same product behavior have already diverged;
- a routine change must be repeated across multiple files to remain consistent;
- a dependency crosses an established project boundary and makes ownership unclear;
- duplicated state, lifecycle, or accessibility logic is difficult to keep correct;
- a component contains independently evolving responsibilities with a clean extraction seam;
- an abstraction would remove concepts or branching from its consumers, not merely relocate code.

Treat these as low signal unless stronger evidence exists:

- file length or component size alone;
- two short fragments that only look alike;
- a hypothetical future reuse case with no current consumer;
- personal preference for a different folder structure or state library;
- extracting a wrapper that still exposes every implementation detail;
- a generic component requiring many booleans, render branches, or configuration props;
- moving code between files without clarifying ownership or reducing change cost.

Before recommending a refactor, identify the concrete call sites or boundary violation, explain the
failure mode, and describe the smallest useful seam. If that evidence is missing, leave the code
alone.

## Choosing the Response

Prefer the least powerful change that resolves the demonstrated problem:

1. Keep cohesive one-off code local.
2. Extract a pure helper for duplicated domain transformations.
3. Extract a hook or controller for shared behavior while preserving distinct visuals.
4. Extract a small presentation primitive for genuinely shared UI chrome or accessibility behavior.
5. Move transport or domain logic behind the project's existing feature boundary.
6. Split a component only where the resulting pieces have clear ownership and independent reasons
   to change.

Do not merge distinct product concepts merely because their current markup is similar. Do not build
a new design system, state layer, or generic framework unless the audit uncovers a present need of
that scale.

## Applying Changes

With `--apply`, implement only findings whose benefit is clear from current code. Preserve product
behavior, styling, accessibility, and public interfaces unless correcting a demonstrated defect.
Respect unrelated working-tree changes and validate with the project's established checks.

Use this stopping rule:

1. Establish the initial evidence-backed findings.
2. Apply the agreed high-confidence set.
3. Perform one verification scan for regressions and obvious remnants of the same duplication.
4. Stop.

The verification scan is not a new invitation to redesign the resulting abstractions. Report any
new judgment-call opportunities without applying them. Do not recursively refactor callers,
abstractions, then abstractions of abstractions. If no high-signal issue remains, explicitly say the
architecture is sufficiently clean for now.

## Reporting

Lead with the overall verdict. Group findings by severity and give each one concrete locations, its
maintenance or drift consequence, and the smallest recommended change. Distinguish:

- changes worth doing now;
- useful follow-ups when the affected area is next modified;
- observations that do not justify refactoring.

Also identify what is already well-factored so future work preserves it. If the audit finds no
meaningful issue, say so and stop rather than manufacturing work.

When `--apply` is used, summarize what was consolidated, what was deliberately left local, and the
validation performed. Do not use line-count reduction as proof of architectural improvement.

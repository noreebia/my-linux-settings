---
name: produce-guide
description: >
  Produces a tech support guide from code changes — translating diffs into user-facing impact,
  behavioral changes, and support-relevant information. Works with commits, branches, or the
  current branch diff.
argument-hint: "[--commit=<hash>] [--branch=<branch>] [--lang=<language>]"
---

# Produce Guide

Analyze code changes and produce a guide for the tech support team. The audience is non-developer — they need to understand what changed from the user's perspective, not how the code works.

The guide should answer the questions support will actually get: "What's new?", "What changed?", "Will this affect existing users?", "What should I tell a customer who notices X?"

---

## Arguments

- **`--commit=<hash>`** *(optional)*: Analyze a specific commit.
- **`--branch=<branch>`** *(optional)*: Analyze changes on a specific branch against its parent.
- **`--lang=<language>`** *(optional, default: English)*: Language to write the guide in.
- If neither `--commit` nor `--branch` is provided, analyze the current branch against its parent.

## Examples

    /produce-guide
    /produce-guide --commit=abc1234
    /produce-guide --branch=feature/new-billing
    /produce-guide --lang=korean
    /produce-guide --branch=feature/new-billing --lang=japanese

---

## Process

### 1. Gather the changes

**If `--commit` was given:** use `git show <hash> --stat` and `git show <hash>`.

**Otherwise**, detect the parent branch before diffing. Never hardcode or assume `main`, `master`, or any default — always run the detection:

1. List every candidate base branch that exists locally — at minimum `develop`, `main`, `master`, plus any others like `staging` or `release`.
2. For each candidate, run `git rev-list --count <candidate>..<target>` (where `<target>` is the branch from `--branch` or `HEAD`).
3. The candidate with the **lowest count** is the parent — it's the branch the target diverged from most recently.
4. If candidates tie or none exist, ask the user. Do not fall back to a guess.

Then diff: `git diff <parent>...<target>` and `git diff --stat <parent>...<target>`.

Read key changed files in full to understand intent — the diff alone often doesn't reveal user-facing impact.

### 2. Identify user-facing impact

Think from the end user's perspective. For each change, determine:

- Is this visible to users? (UI changes, new features, changed behavior, error messages)
- Is this invisible but operationally relevant? (performance improvements, security fixes, backend changes that alter timing or limits)
- Is this purely internal? (refactors, dev tooling) — mention briefly or skip

Pay special attention to: default value changes, renamed or moved UI elements, new validation rules, changed error messages, altered permissions or access controls, and anything that changes existing workflows.

### 3. Write the guide

Write in plain language for a non-technical audience. Avoid code references, function names, and implementation details — describe behavior and outcomes instead. If `--lang` was provided, write the entire guide in that language (section headings included).

Structure the guide to include:

- **Summary** — one paragraph overview of what changed and why
- **What's new** — new features or capabilities, described from the user's perspective
- **What changed** — existing behavior that now works differently, with before/after descriptions
- **What to watch for** — potential customer questions, edge cases, or known limitations support should be aware of
- **Not affected** — explicitly call out areas that might seem related but didn't change, to preempt incorrect assumptions

Omit sections that don't apply. A small bug fix doesn't need a "What's new" section.

### 4. Save the guide

Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <commit hash, branch name, or "current branch">*`

Write to `$AGENT_LOCAL_DIR/support-guides/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-name>.md`. Tell the user where it was saved.

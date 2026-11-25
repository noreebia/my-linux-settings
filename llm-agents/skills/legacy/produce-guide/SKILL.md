---
name: produce-guide
description: >
  Produces a guide for the tech support team outlining code changes. Works with commits, branches,
  or the current branch diff.
argument-hint: "[--commit=<hash>] [--branch=<branch>] [--lang=<language>]"
---

# Produce Guide

Analyze code changes and produce a guide for the tech support team outlining the changes.

---

## Arguments

- **`--commit=<hash>`** *(optional)*: Analyze a specific commit.
- **`--branch=<branch>`** *(optional)*: Analyze changes on a specific branch against its parent.
- **`--lang=<language>`** *(optional, default: English)*: Language to write the guide in (headings included).
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

Read key changed files in full to understand the changes thoroughly.

### 2. Write the guide

Produce a guide outlining the changes. Structure and organize it however best fits — adapt to the scope and nature of what changed.

### 3. Save the guide

Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <commit hash, branch name, or "current branch">*`

Write to `$AGENT_LOCAL_DIR/support-guides/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-name>.md`. Tell the user where it was saved.

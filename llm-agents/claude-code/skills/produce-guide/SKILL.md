---
name: produce-guide
description: >
  Produces a tech support guide from code changes — translating diffs into deployment impact,
  behavioral changes, and support-relevant details. Works with commits, branches, or the
  current branch diff.
argument-hint: "[--commit=<hash>] [--branch=<branch>] [--lang=<language>]"
---

# Produce Guide

Analyze code changes and produce a guide for the tech support team.

The audience is technical — they deploy and maintain systems on client premises. They understand code, configs, and infrastructure, but they aren't in the trenches of this codebase day-to-day. They need to know everything that could affect a deployment, a client's environment, or existing behavior. Be thorough and precise — vague summaries aren't useful to someone installing a system update.

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

Read key changed files in full to understand intent — the diff alone often doesn't reveal deployment or behavioral impact.

### 2. Analyze and write the guide

If `--lang` was provided, write the entire guide in that language (headings included).

Focus on what this audience cares about: deployment impact, configuration changes, new or changed dependencies, database migrations, behavioral changes, new or removed API endpoints, changed defaults, altered permissions, and anything that could affect a client's existing environment.

Structure and organize the guide however best fits the changes. Adapt depth and format to the scope — a single bug fix needs a different treatment than a multi-feature release. Include technical detail where it helps (config keys, environment variables, migration steps, API changes) — this audience can handle it.

### 3. Save the guide

Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <commit hash, branch name, or "current branch">*`

Write to `$AGENT_LOCAL_DIR/support-guides/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-name>.md`. Tell the user where it was saved.

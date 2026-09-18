---
name: analyze-branch
description: >
  Analyzes the current branch by detecting the parent branch, diffing changes, and reading key
  modified files to produce a structured briefing of the branch's purpose and current state.
argument-hint: "[--key-words=<word1,word2,...>]"
---

# Analyze Branch

Analyze the current branch and produce a briefing that gets someone productive fast — what the branch is doing, what's changed, and what state things are in.

---

## Arguments

- **`--key-words=<word1,word2,...>`** *(optional)*: Comma-separated keywords to scan for in `$AGENT_LOCAL_DIR`. When provided, recursively search filenames and file contents under `$AGENT_LOCAL_DIR` for any of the keywords, then read matching files and incorporate their context into the briefing. This pulls in prior analysis, plans, reviews, or notes that relate to the branch's domain — useful when picking up work that has accumulated history across sessions.

## Examples

    /analyze-branch
    /analyze-branch --key-words=auth,session
    /analyze-branch --key-words=user,policy,default
    /analyze-branch --key-words=migration,schema,postgres

---

## Process

### 1. Detect the parent branch

Never hardcode or assume `main`, `master`, or any default — always run the detection:

1. List every candidate base branch that exists locally — at minimum `develop`, `main`, `master`, plus any others like `staging` or `release`.
2. For each candidate, run `git rev-list --count <candidate>..HEAD`. The candidate with the **lowest count** is the parent — it's the branch HEAD diverged from most recently.
3. If candidates tie or the result is ambiguous, ask the user. Do not fall back to a guess.

Record the parent branch name — you'll need it for the diff and the briefing.

### 2. Gather branch context

Run these in parallel where possible:

- **Diff stat**: `git diff --stat <parent>...HEAD` — file-level summary of what changed.
- **Full diff**: `git diff <parent>...HEAD` — the actual changes. This is ground truth.
- **Commit log**: `git log --oneline <parent>..HEAD` — the sequence of commits on this branch.
- **Current status**: `git status` — any uncommitted work in progress.

### 3. Read key files

Don't just summarize the diff blindly — read the most important changed files in full to understand intent, not just mechanics. Prioritize:

- Files with the largest logical changes (not just line count — a 200-line config dump matters less than a 30-line algorithm change)
- Entry points, main modules, and files that reveal the branch's purpose
- Test files — they often describe intended behavior more clearly than implementation

Use the diff stat to pick which files to read. You don't need to read everything — focus on what gives you the clearest picture of *why* this branch exists and *what it's trying to accomplish*.

### 4. Scan for keyword context (only if `--key-words` provided)

When `--key-words` is provided:

1. Split the value on commas to get individual keywords.
2. Search `$AGENT_LOCAL_DIR` recursively — check both filenames and file contents for any of the keywords. Use case-insensitive matching.
3. Read matching files and extract relevant context — prior plans, analyses, reviews, or notes that relate to this branch's domain.
4. Synthesize this background into the briefing. The goal is to connect the branch's changes to the broader history: what decisions were made before, what problems were identified, what the user was trying to achieve across sessions.

### 5. Present the briefing

Output directly in the conversation. Structure the briefing as:

- **Branch**: current branch name → parent branch name
- **Purpose**: 2–3 sentences explaining what this branch is doing and why, inferred from the commits, diff, and file context. Be specific — "refactoring auth middleware to support JWT rotation" not "making changes to auth".
- **Changes**: A concise summary of the key changes, organized by logical grouping (not by file). Name files/components when it adds clarity.
- **Current state**: Where things stand — is the work complete? In progress? Are there uncommitted changes? Failing tests? Merge conflicts?
- **Background** *(only if `--key-words` matched files)*: Relevant context from prior sessions — what was planned, what was reviewed, what decisions were made that inform the current state.

Adapt depth to the branch. A branch with 2 commits and 3 changed files gets a quick briefing. A branch with 30 commits across a week of work gets a thorough one.

---

## Constraints

- **Read-only**: Do not modify any files — source, config, or otherwise. This skill only observes and reports.
- **No assumptions about parent branch**: Always detect it. Getting this wrong means diffing against the wrong base, which makes the entire briefing misleading.
- **Diff is ground truth**: If commit messages conflict with what the diff actually shows, trust the diff. Commit messages are written by humans in a hurry; the code doesn't lie.

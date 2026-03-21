---
name: analyze-codebase
description: >
  Analyze an unfamiliar codebase and generate developer documentation in $AGENT_DIR/system-analysis.
  Use this skill whenever a developer needs to understand an existing project — triggered by phrases like
  "analyze this codebase", "document this project", "help me understand this repo", "onboard me to this
  code", "what does this system do", "explain the architecture", or any time someone is new to a project
  and needs a map. Also trigger proactively when the user starts asking multiple questions about how a
  codebase is structured — they probably need a full analysis, not just piecemeal answers. Scales output
  to project complexity: a small script gets a single clear file; a large system gets a structured docs
  folder with diagrams.
---

# Analyze Codebase

Explore a codebase and produce documentation that gives a new developer genuine understanding — not just a file tree tour, but a mental model of how the system works, why it's structured that way, and how to navigate it confidently.

Output lives in `$AGENT_DIR/system-analysis/` at the repository root.

---

## Arguments

- **focus** *(optional)*: Narrow the analysis to a specific area — e.g., `"auth"`, `"data pipeline"`, `"payments"`. When omitted, analyzes the full codebase.

---

## Step 1 — Check What Already Exists

Before exploring the code, check `$AGENT_DIR/system-analysis/` for existing docs:

```bash
find $AGENT_DIR/system-analysis -type f 2>/dev/null | sort
```

If a **focus** was provided, look for any file or directory whose name fuzzy-matches it (`auth` → `authentication.md`, `auth/`, sections in `security.md`, etc.). Read any matches.

**Decision**: If existing docs already cover the topic thoroughly and accurately → tell the user, and stop. Don't update for its own sake.

---

## Step 2 — Reconnaissance

Explore before writing anything. Work fast — the goal is orientation, not exhaustive reading.

**Start with the big picture:**
```bash
# Project type & dependencies
cat package.json go.mod requirements.txt Cargo.toml pom.xml build.gradle 2>/dev/null | head -60

# Structure (2 levels, skip noise)
find . -maxdepth 2 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/__pycache__/*' | sort

# Existing READMEs
find . -maxdepth 3 -name "README*" | head -10
```

**Understand how it runs:**
```bash
# Entry points & scripts
cat Makefile docker-compose.yml .github/workflows/*.yml 2>/dev/null | head -80
```

**Understand what it does:**
- Read `main.*`, `index.*`, `app.*`, `server.*`, or whatever the entry point is
- Read `src/` or top-level source directories — skim for module/package names and their purpose
- Read key config files (`*.config.*`, `*.env.example`, `settings.*`)

**If a focus was provided:** After the big picture, go deep on that area — read its files, trace its imports, find where it plugs into the rest of the system.

**Collect answers to these questions as you go:**
1. What does this system do? (one sentence)
2. What are its major components, and what does each one own?
3. How does a request / event / job flow through the system?
4. What are the external dependencies (DBs, APIs, queues, auth providers)?
5. What are the non-obvious things a new dev needs to know?

---

## Step 3 — Plan the Output

**Simple rule:** One topic = one file. Multiple related topics = one directory.

| Situation | Output |
|---|---|
| Full analysis, simple project | `$AGENT_DIR/system-analysis/overview.md` |
| Full analysis, complex project | `$AGENT_DIR/system-analysis/` with numbered files |
| Focus, small topic | `$AGENT_DIR/system-analysis/<focus>.md` |
| Focus, large topic | `$AGENT_DIR/system-analysis/<focus>/` with files inside |
| Existing file for this topic | Augment it in place — update stale content, add new sections |
| Existing directory for this topic | Add/update files within it |

When generating multiple files, prefix with two-digit numbers for reading order:
```
system-analysis/
  01-overview.md
  02-architecture.md
  03-data-model.md
  04-auth.md
```

---

## Step 4 — Write the Documentation

Write for a developer on day one. They're smart, but they don't know the project's history, conventions, or gotchas. Give them the mental model they need to be productive, not just a description of what exists.

### What every overview document should answer

- **What is this?** One-paragraph plain-English description of what the system does and who uses it.
- **How do I run it?** Quickstart — the minimum commands to get it running locally.
- **How is it structured?** A map of the top-level directories/packages and what each one owns. This is not a file tree — explain responsibilities.
- **How does it work?** The key data/request flow through the system. A Mermaid diagram works well here.
- **What are the external dependencies?** Databases, third-party APIs, auth providers, message queues — what they are and why they're used.
- **What should I know that isn't obvious?** Conventions, quirks, historical decisions, things that will confuse a newcomer if they don't know.

### What focused documentation should answer

Same as above, scoped to the focus area, plus:
- How does this component fit into the broader system? (entry/exit points, what calls it, what it calls)
- What are the key abstractions / data structures here?
- What are the common tasks a developer would do in this area, and where do they happen?

### Diagrams

Use Mermaid when a visual genuinely adds clarity prose can't easily provide:
- Architecture overview (services, their relationships, external dependencies)
- Request/event flow through multiple components
- Data model relationships
- State machines

Keep diagrams focused — a diagram with 15 nodes teaches nothing. If it's getting large, split it.

### Tone and style

- Write in present tense ("the auth service validates tokens") not past ("the auth service was designed to...")
- Explain *why* alongside *what* — if you can infer the reason for a design decision, say it
- Call out gotchas explicitly with a **Note:** or **⚠️** prefix
- Be concrete — prefer `"the UserService class in src/services/user.ts"` over `"the user service"`

---

## Constraints

- **Read-only**: Do not modify any source files. Only write to `$AGENT_DIR/system-analysis/`.
- **Create the output folder** if it doesn't exist: `mkdir -p $AGENT_DIR/system-analysis`
- **Don't pad**: If the project is small, one well-written file is better than five thin ones.

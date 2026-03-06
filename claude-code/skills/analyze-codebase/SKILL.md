---
name: analyze-codebase
description: Analyze an unfamiliar codebase and generate documentation in /docs/system-analysis that helps a new developer understand the system. Scales output to match the complexity of the project.
user-invocable: true
argument-hint: "[focus]"
---

# Analyze Codebase

Perform a thorough analysis of the current codebase and produce developer-friendly documentation in a `/docs/system-analysis` folder at the repository root. The depth and breadth of the output must match the actual complexity of the project — no more, no less.

## Arguments

- **focus** (1st argument, optional): A specific area to focus the analysis on (e.g., "backend", "auth", "data pipeline"). If omitted, analyzes the entire codebase.

## Process

### 1. Reconnaissance

Gather a high-level picture before writing anything:

- Read the existing README, CHANGELOG, and any existing docs.
- List the top-level directory structure and identify major directories.
- Identify the language(s), framework(s), and package manager(s) from config files (e.g., `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`, `*.csproj`, etc.).
- Check for a `docker-compose.yml`, `Dockerfile`, or infrastructure-as-code files.
- Check for CI/CD configuration (`.github/workflows`, `.gitlab-ci.yml`, `Jenkinsfile`, etc.).
- Look for database migrations, ORM models, or schema files.
- Look for API route definitions, OpenAPI/Swagger specs, or GraphQL schemas.
- Look for authentication and authorization mechanisms — auth middleware, JWT/session handling, OAuth integrations, RBAC/ABAC policies, permission checks, guards, or security-related config.
- Skim key entry points (e.g., `main.*`, `index.*`, `app.*`, `server.*`).
- If a **focus** argument was provided, prioritize exploring that area but still capture enough surrounding context to make the docs useful.

### 2. Determine Scope

Based on reconnaissance, decide which documentation sections are warranted. Use the guidelines below — **only include sections that carry meaningful content for this particular project**.

| Section | Include when... |
|---|---|
| Overview (`overview.md`) | Always. Every project gets a concise overview. |
| Architecture (`architecture.md`) | The project has multiple services, layers, or a non-trivial structure (more than a handful of files). |
| Database (`database.md`) | There are migrations, ORM models, schema definitions, or any persistent data store. |
| API Reference (`api.md`) | The project exposes HTTP/gRPC/GraphQL/WebSocket endpoints. |
| Key Modules (`modules.md`) | There are distinct modules, packages, or bounded contexts worth explaining individually. |
| Security (`security.md`) | There is authentication, authorization, role/permission management, or other security mechanisms. |
| Configuration & Environment (`configuration.md`) | There are env vars, config files, feature flags, or secrets management worth documenting. |
| Development Guide (`development.md`) | There are build steps, test commands, linting, local dev setup, or Docker usage that a new dev needs. |
| Infrastructure & Deployment (`infrastructure.md`) | There is CI/CD, IaC, container orchestration, or cloud-specific configuration. |

For very simple projects (e.g., a single-file script or small utility), collapse everything into a single `overview.md`.

### 3. Write Documentation

For each section you decided to include, create a markdown file inside `/docs/system-analysis` at the repo root.

#### General writing rules

- Write for a developer who has never seen this codebase.
- Be specific — reference actual file paths, function names, class names, and config keys.
- Use diagrams (Mermaid) only when they genuinely clarify relationships (e.g., service topology, data flow, ER diagrams). Do not add diagrams for the sake of it.
- Keep each file focused. Avoid repeating information across files.
- Do not pad with generic advice ("always write tests", "follow best practices"). Every sentence should be specific to this project.
- If the project has patterns or conventions (naming, error handling, code organization), call them out briefly so the new developer follows them.
- Include a `docs/system-analysis/README.md` that serves as a table of contents linking to the other docs. If there is only `overview.md`, skip this — it's unnecessary.

#### Section-specific guidance

**Overview** — What does this project do? Who is it for? What are the main technologies? What is the high-level structure? Keep it to 1-2 pages max.

**Architecture** — How is the system organized? What are the major components and how do they interact? Include a Mermaid diagram if there are 3+ interacting components. Mention key design decisions or patterns (e.g., "uses CQRS", "event-driven via RabbitMQ").

**Database** — What is the data model? List key entities and their relationships. Include an ER diagram (Mermaid) if there are 3+ related entities. Note which ORM/query builder is used, where migrations live, and how to run them.

**API Reference** — List endpoints/operations grouped logically. For each: method, path, brief purpose, and notable request/response details. Do not exhaustively document every field — focus on what a new dev needs to navigate and understand the API surface.

**Key Modules** — For each significant module: what it does, key files/classes, and how it fits into the larger system.

**Security** — How does the system handle authentication (who are you?) and authorization (what can you do?)? Describe the auth flow (e.g., JWT-based, session-based, OAuth2), where middleware/guards are applied, how roles and permissions are defined and enforced, and any security-related configuration. Reference the actual files that implement these mechanisms.

**Configuration & Environment** — List important env vars, config files, and their purposes. Note which are required vs optional, and any defaults.

**Development Guide** — How to set up the project locally, run it, run tests, lint, and build. Include actual commands.

**Infrastructure & Deployment** — How is the project built, tested, and deployed? Describe the CI/CD pipeline steps and any infrastructure setup.

### 4. Final Review

- Re-read each file and remove anything that is generic filler or duplicated across files.
- Verify file paths and names referenced in the docs actually exist.
- Ensure the docs are proportional: a simple project should yield a short, simple set of docs.

## Important

- Create the `/docs/system-analysis` folder at the repository root. If it already exists, inform the user and ask whether to overwrite, merge, or use a different directory.
- Do not modify any source code. This skill is read-only except for the `/docs` output.
- If the codebase is a monorepo, focus on the top-level structure and summarize each sub-project. Do not try to deeply document every sub-project unless the focus argument targets one.

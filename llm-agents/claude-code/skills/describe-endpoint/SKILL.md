---
name: describe-endpoint
description: >
  Use this skill whenever the user wants to understand, document, or explore how an API endpoint works
  in a codebase. Trigger on phrases like "describe this endpoint", "how does this route work",
  "trace this API call", "document this endpoint", "explain the flow of", "walk me through what happens
  when X is called", or any time the user points at a route/controller/handler and wants to understand
  what it does end-to-end. Even if the user just pastes a URL path like `/api/users/:id` or a method
  signature and asks "what does this do?" — use this skill. Also use it proactively when the user is
  debugging an endpoint and a clear flow description would help.
---

# Describe Endpoint Skill

This skill produces clear, structured documentation of an API endpoint's full request/response lifecycle — from route registration through middleware, business logic, data access, and final response shape.

---

## Goal

Given an endpoint (identified by HTTP method + path, a handler function, or a controller method), produce documentation that answers:

1. **What does this endpoint do?** (one-sentence summary)
2. **How does a request flow through the code?** (traced step by step)
3. **What are the inputs?** (path params, query params, headers, body schema)
4. **What are the outputs?** (response shape, status codes, error cases)
5. **What side effects does it produce?** (DB writes, cache invalidation, event emissions, external calls)

---

## Step 1 — Locate the Endpoint

If the user provides a route path (e.g. `POST /api/orders`), find it in the codebase:

```bash
# Search for route registration
grep -rn "POST.*orders\|router\.post.*orders\|app\.post.*orders" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.rb" .

# Also look for framework-specific decorators
grep -rn "@Post\|@Route\|route(\|@app.route" --include="*.ts" --include="*.py" . | grep -i "orders"
```

If the user provides a function/method name, find it directly:
```bash
grep -rn "createOrder\|handleOrder\|ordersController" --include="*.ts" --include="*.js" .
```

Once found, note the **file path** and **line number** as the trace starting point.

---

## Step 2 — Trace the Request Flow

Read the handler and recursively follow the call chain. For each layer, capture:

| Layer | What to look for |
|---|---|
| **Router / Route file** | HTTP method, path pattern, middleware chain, handler reference |
| **Middleware** | Auth guards, rate limiters, validators, request transformers — note order |
| **Controller / Handler** | Entry point logic, parameter extraction, delegation to services |
| **Service layer** | Business logic, orchestration of multiple operations |
| **Data access layer** | ORM queries, raw SQL, cache reads/writes, external API calls |
| **Response** | What gets serialized and returned, status code logic |

Use `view` and `bash` tools to read each file in the chain. Don't guess — follow the actual imports.

**Key things to trace:**
- What validation happens and where?
- What auth/permission checks run, and do they short-circuit?
- Are there any async operations (queues, background jobs)?
- Are there transactions wrapping the DB calls?

---

## Step 3 — Identify Inputs

Collect all inputs the endpoint consumes:

**Path parameters** — from the route pattern (`:id`, `{userId}`, `<slug>`)
**Query parameters** — read from `req.query`, `request.args`, `c.QueryParam()`
**Request body** — look for the schema/type/validation struct used
**Headers** — any headers explicitly read (Authorization, Content-Type, custom headers)
**Context / Session** — any data pulled from auth context, session, or token claims

For typed languages (TypeScript, Go, Java), find the DTO/struct/schema definition and read its fields and constraints.

---

## Step 4 — Identify Outputs

Trace what the endpoint returns:

- **Success response shape** — the serialized object or array returned
- **HTTP status codes** — the happy path code, and any conditional ones
- **Error responses** — what error types/codes are returned and under what conditions
- **Headers set** — any response headers explicitly set (Set-Cookie, Location, etc.)

---

## Step 5 — Identify Side Effects

Look for anything the endpoint does *beyond* returning data:

- **Database writes** — INSERT, UPDATE, DELETE operations
- **Cache operations** — cache sets, invalidations, TTL updates
- **Events / Queues** — any event emits, message queue publishes, webhooks fired
- **External service calls** — third-party APIs, internal microservices called
- **File / storage operations** — S3, filesystem, CDN writes

---

## Step 6 — Produce the Documentation

Format the output as a structured document. Use the template in `references/output-template.md`.

**Calibrate depth to context:**
- If the user is quickly exploring: lead with the summary + flow overview, keep it concise
- If the user is writing docs or onboarding: use the full template
- If the user is debugging: emphasize error paths, side effects, and conditions

Always include a **flow diagram** when the chain has 3+ distinct layers. Use a simple text-based flowchart if markdown rendering is uncertain, or an SVG/mermaid diagram if the interface supports it.

---

## Tips & Edge Cases

**Monorepos / microservices**: The handler may import from shared packages. Follow imports across package boundaries — don't stop at the package boundary.

**Generated code**: If the route is auto-generated (e.g. from OpenAPI, tRPC, or gRPC proto), note this and point to the schema/spec file as the source of truth instead of tracing generated code.

**Middleware defined elsewhere**: Auth and validation middleware are often registered globally. If a middleware is referenced by name but not defined in the route file, search for its definition:
```bash
grep -rn "function authMiddleware\|const authMiddleware\|def auth_middleware" --include="*.ts" --include="*.js" --include="*.py" .
```

**Multiple possible handlers**: Some frameworks support method overloading or versioned routes. If multiple handlers match, document all of them and note the distinction.

**If you can't find the file**: Tell the user what you searched for and ask them to point you to the router file or handler directly.

---

## Reference Files

- `references/output-template.md` — the full documentation template to fill in
- `references/framework-patterns.md` — framework-specific patterns for Express, FastAPI, Django, Rails, Go/Gin, NestJS, Laravel

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

# Describe Endpoint

Produce clear, structured documentation of an API endpoint's full request/response lifecycle — from route registration through middleware, business logic, data access, and response.

---

## Process

### 1. Locate and trace

Find the endpoint in the codebase (by route path, handler name, or controller method). Then trace the full call chain: route registration → middleware → handler → service layer → data access → response. Follow actual imports — don't guess. See `references/framework-patterns.md` for framework-specific patterns to locate routes and trace flows.

### 2. Document

Use the template in `references/output-template.md`. The documentation should answer:

- What does this endpoint do? (one-sentence summary)
- How does a request flow through the code? (traced step by step, with file:line references)
- What are the inputs? (path params, query params, headers, body schema)
- What are the outputs? (response shape, status codes, error cases)
- What side effects does it produce? (DB writes, cache ops, events, external calls)

**Calibrate depth to context:**
- Quickly exploring → summary + flow overview, keep it concise
- Writing docs or onboarding → use the full template
- Debugging → emphasize error paths, side effects, and conditions

Include a flow diagram when the chain has 3+ distinct layers.

### Tips

- **Generated code** (OpenAPI, tRPC, gRPC): Point to the schema/spec file as source of truth instead of tracing generated code.
- **If you can't find it**: Tell the user what you searched for and ask them to point you to the router or handler directly.

---

## Reference Files

- `references/output-template.md` — the documentation template to fill in
- `references/framework-patterns.md` — framework-specific patterns for Express, FastAPI, Django, Rails, Go/Gin, NestJS, Laravel, tRPC/GraphQL/gRPC

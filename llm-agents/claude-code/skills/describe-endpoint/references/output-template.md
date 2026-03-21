# Endpoint Documentation Template

Use this template when producing documentation for an endpoint. Fill in every section. If a section is not applicable (e.g. no side effects), write "None" rather than omitting it.

---

## `{METHOD} {/path/pattern}`

> {One-sentence plain-English description of what this endpoint does.}

**File:** `{path/to/handler.ts}` — `{FunctionOrClassName}`

---

### Request

#### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | `string (UUID)` | ✅ | The resource identifier |

*(or "None" if no path params)*

#### Query Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | `number` | ❌ | `1` | Page number for pagination |

*(or "None" if no query params)*

#### Request Body
```json
{
  "field": "type and description",
  "requiredField": "string — required, max 255 chars"
}
```
*(or "None" if no body — e.g. GET requests)*

#### Headers
| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | ✅ | Bearer token |
| `X-Idempotency-Key` | ❌ | Optional idempotency key |

---

### Request Flow

```
{METHOD} {/path}
    │
    ├── [Middleware 1] — {what it does, e.g. "verifies JWT, attaches user to req"}
    ├── [Middleware 2] — {e.g. "validates request body against schema"}
    │
    └── {ControllerName}.{methodName}()  ({path/to/controller.ts}:{line})
            │
            ├── Calls {ServiceName}.{method}()  ({path/to/service.ts}:{line})
            │       │
            │       ├── Queries {ModelName} — {what query, e.g. "find by ID with joins"}
            │       └── {Any other operations}
            │
            └── Returns {shape} with status {code}
```

*(Expand or collapse this based on actual complexity. Use indented bullets if ASCII art gets unwieldy.)*

---

### Response

#### Success — `{HTTP status code}`
```json
{
  "id": "uuid",
  "field": "value",
  "nested": {
    "key": "value"
  }
}
```

#### Error Responses
| Status | Code / Type | When |
|--------|-------------|------|
| `400` | `VALIDATION_ERROR` | Request body fails schema validation |
| `401` | `UNAUTHORIZED` | Missing or invalid auth token |
| `403` | `FORBIDDEN` | Authenticated but lacks permission |
| `404` | `NOT_FOUND` | Resource does not exist |
| `409` | `CONFLICT` | {specific conflict condition} |
| `500` | `INTERNAL_ERROR` | Unexpected server error |

*(List only the codes actually returned by this endpoint)*

---

### Auth & Permissions

- **Authentication required:** Yes / No
- **Auth mechanism:** {JWT / API Key / Session Cookie / OAuth / None}
- **Permission checks:** {e.g. "user must own the resource OR have `admin` role"}
- **Defined in:** `{path/to/guard-or-middleware.ts}`

---

### Side Effects

| Type | Description |
|------|-------------|
| **DB Write** | Creates a new `{Model}` row in `{table}` |
| **Cache** | Invalidates `user:{id}:profile` cache key |
| **Event** | Emits `order.created` to the message queue |
| **External API** | Calls Stripe `/v1/charges` to process payment |

*(or "None")*

---

### Notes & Gotchas

- {Any non-obvious behavior, legacy quirks, known issues, or things a developer should be aware of}
- {e.g. "This endpoint is idempotent when X-Idempotency-Key is provided"}
- {e.g. "Rate limited to 10 requests/minute per user"}

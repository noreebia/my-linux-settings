# Framework-Specific Patterns

Quick reference for finding endpoints and tracing flows in common frameworks.

---

## Express / Node.js

**Route registration:**
```js
router.get('/users/:id', authMiddleware, validateParams, userController.getById)
app.use('/api', router)
```

**Finding routes:**
```bash
grep -rn "router\.\(get\|post\|put\|patch\|delete\)" --include="*.js" --include="*.ts" .
grep -rn "app\.\(get\|post\|put\|patch\|delete\)" --include="*.js" --include="*.ts" .
```

**Middleware order:** Left to right in the argument list. Each must call `next()` to continue.

**Request object:** `req.params`, `req.query`, `req.body`, `req.headers`, `req.user` (if set by auth middleware)

---

## NestJS

**Route registration via decorators:**
```ts
@Controller('users')
export class UsersController {
  @Get(':id')
  @UseGuards(AuthGuard)
  async getUser(@Param('id') id: string) { ... }
}
```

**Finding routes:**
```bash
grep -rn "@Get\|@Post\|@Put\|@Patch\|@Delete" --include="*.ts" .
```

**Guards** run before the handler. **Interceptors** wrap it. **Pipes** transform/validate params.

**Module hierarchy matters** — trace which module the controller is registered in to understand its scope.

---

## FastAPI (Python)

**Route registration:**
```python
@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    ...
```

**Finding routes:**
```bash
grep -rn "@app\.\(get\|post\|put\|patch\|delete\)\|@router\." --include="*.py" .
```

**Dependencies** (`Depends(...)`) are FastAPI's middleware equivalent — trace them for auth, DB session injection, etc.

**Pydantic models** define request body and response shapes — find the model class for the full schema.

---

## Django REST Framework

**Route registration:**
```python
# urls.py
urlpatterns = [
    path('users/<int:pk>/', UserDetailView.as_view()),
]
```

**Finding routes:**
```bash
grep -rn "path\|re_path\|url(" --include="*.py" . | grep -v "migration"
```

**ViewSets** auto-generate CRUD routes. For `ModelViewSet`, trace `get_queryset()`, `get_serializer()`, and `perform_create/update/destroy()`.

**Permissions** are in `permission_classes`. **Serializers** define input validation and output shape.

---

## Rails

**Route registration (`config/routes.rb`):**
```ruby
resources :users, only: [:show, :create]
post '/orders/:id/confirm', to: 'orders#confirm'
```

**Finding routes:**
```bash
grep -rn "get\|post\|put\|patch\|delete\|resources\|resource" config/routes.rb
# Or run: rails routes | grep <pattern>
```

**Controller flow:** `before_action` callbacks run first, then the action method. `around_action` wraps it.

**Strong params** (`params.require(...).permit(...)`) define allowed input fields.

---

## Go / Gin

**Route registration:**
```go
r.GET("/users/:id", authMiddleware(), userHandler.GetByID)
r.POST("/users", userHandler.Create)
```

**Finding routes:**
```bash
grep -rn "\.GET\|\.POST\|\.PUT\|\.PATCH\|\.DELETE\|\.Handle" --include="*.go" .
```

**Middleware** is chained in the handler list. `c.Next()` proceeds to the next handler.

**Binding:** `c.ShouldBindJSON(&req)` and `c.Param("id")` for path params, `c.Query("page")` for query params.

---

## Laravel (PHP)

**Route registration:**
```php
Route::get('/users/{id}', [UserController::class, 'show'])->middleware('auth');
Route::apiResource('orders', OrderController::class);
```

**Finding routes:**
```bash
grep -rn "Route::\(get\|post\|put\|patch\|delete\|apiResource\|resource\)" --include="*.php" routes/
# Or run: php artisan route:list
```

**Middleware** is defined in `app/Http/Kernel.php`. Form Requests handle validation.

**Eloquent** models — look for `$model->save()`, `Model::create()`, `Model::find()` for DB operations.

---

## tRPC / GraphQL / gRPC

For these schema-first or RPC frameworks:

- **tRPC**: Routes are procedures defined in router files. Trace from the procedure name to its resolver. Input is validated via Zod schema — find the `.input(schema)` call.
- **GraphQL**: Find the resolver for the query/mutation name. Schema definition (SDL or code-first) defines types. Look for `@Resolver`, resolver map objects, or `makeExecutableSchema`.
- **gRPC**: The `.proto` file is the source of truth for inputs/outputs. The service implementation file contains the actual handler logic.

For all three, note in the documentation that this is not a REST endpoint and link to the schema/proto file.

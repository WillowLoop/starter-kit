# FastAPI OWASP Vulnerability Patterns

Reference for FastAPI-specific security patterns used by `security-code-scan`.

## Auth dependency gaps

Endpoints without auth dependency are publicly accessible. Check all router files for:

```python
# UNSAFE — no auth dependency, endpoint is public
@router.get("/users")
async def list_users():
    ...

# SAFE — auth dependency required
@router.get("/users")
async def list_users(current_user: User = Depends(get_current_user)):
    ...
```

**Whitelist** — these endpoints are expected to be public:
- `/health`, `/healthz`, `/readyz` — health checks
- `/docs`, `/openapi.json` — API docs (should be disabled in production)
- `/api/v1/auth/login`, `/api/v1/auth/register` — auth endpoints
- Any endpoint explicitly documented as public in the router

## response_model data leakage

Missing `response_model` can expose internal fields (passwords, internal IDs):

```python
# UNSAFE — returns full ORM object, may include password_hash
@router.get("/users/{id}")
async def get_user(id: int, db: Session = Depends(get_db)):
    return db.query(User).get(id)

# SAFE — response_model filters fields
@router.get("/users/{id}", response_model=UserResponse)
async def get_user(id: int, db: Session = Depends(get_db)):
    return db.query(User).get(id)
```

## SQL injection via text()

```python
# UNSAFE — f-string in text(), user input interpolated
query = text(f"SELECT * FROM users WHERE name = '{name}'")
session.execute(query)

# SAFE — bound parameters
query = text("SELECT * FROM users WHERE name = :name").bindparams(name=name)
session.execute(query)

# SAFE — ORM query (parameterized by design)
session.execute(select(User).where(User.name == name))
```

**SQLAlchemy safe patterns** (do NOT flag as SQL injection):
- `session.execute(select(...))` — ORM select
- `session.execute(text(...).bindparams(...))` — parameterized raw SQL
- `connection.execute(...)` — connection-level execute with params
- `session.query(Model).filter(...)` — legacy ORM query

## Background tasks with sensitive data

```python
# WARN — sensitive data passed to background task, may persist in memory
@router.post("/process")
async def process(background_tasks: BackgroundTasks, data: SensitiveInput):
    background_tasks.add_task(process_sensitive, data.credit_card)
```

Check that background tasks don't log or persist sensitive data unnecessarily.

## Insecure deserialization

```python
# UNSAFE — arbitrary code execution
import pickle
data = pickle.loads(user_input)

# UNSAFE — arbitrary code execution without SafeLoader
import yaml
data = yaml.load(user_input)

# SAFE
data = yaml.safe_load(user_input)
```

## Input validation

```python
# UNSAFE — accepts arbitrary dict, no validation
@router.post("/data")
async def create(data: dict):
    ...

# UNSAFE — Any type bypasses validation
class Input(BaseModel):
    payload: Any

# SAFE — typed Pydantic model with field constraints
class Input(BaseModel):
    name: str = Field(max_length=100)
    email: EmailStr
    age: int = Field(ge=0, le=150)
```

## File upload risks

```python
# UNSAFE — no size limit, no type check
@router.post("/upload")
async def upload(file: UploadFile):
    content = await file.read()

# SAFER — validate type and size
@router.post("/upload")
async def upload(file: UploadFile):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(400, "Invalid file type")
    content = await file.read(MAX_SIZE)
```

## CORS misconfiguration

```python
# UNSAFE — wildcard in production
app.add_middleware(CORSMiddleware, allow_origins=["*"])

# SAFE — explicit origins
app.add_middleware(CORSMiddleware, allow_origins=settings.cors_origins)
```

## Rate limiting bypass

Check that rate limiting middleware:
- Cannot be bypassed via header manipulation (X-Forwarded-For spoofing)
- Applies to auth endpoints (login, register, password reset)
- Has reasonable limits (not too high)

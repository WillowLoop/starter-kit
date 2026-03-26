# AI/LLM Security Patterns

Reference for AI and LLM security patterns used by `security-code-scan`.

**If no AI/LLM integrations are detected in the codebase, report this section as N/A with an INFO note: "No AI/LLM integrations detected in the codebase."**

## Detection patterns

Grep for these libraries to detect AI integrations:
- `openai` — OpenAI API client
- `anthropic` — Anthropic API client
- `langchain` — LangChain framework
- `llama` — LLaMA/Ollama integrations
- `transformers` — Hugging Face
- `cohere` — Cohere API
- `google.generativeai` — Google Gemini

## Direct prompt injection

User input concatenated directly into prompts:

```python
# UNSAFE — user input directly in prompt
prompt = f"Summarize this text: {user_input}"
response = client.chat.completions.create(messages=[{"role": "user", "content": prompt}])

# SAFER — structured messages with system prompt boundary
response = client.chat.completions.create(messages=[
    {"role": "system", "content": "You are a summarizer. Only summarize the provided text."},
    {"role": "user", "content": user_input}
])
```

## Indirect prompt injection

Documents in RAG pipelines may contain injected instructions:

```python
# WARN — RAG documents used without sanitization
docs = vector_store.similarity_search(query)
context = "\n".join([doc.page_content for doc in docs])
prompt = f"Answer based on context: {context}\nQuestion: {query}"
# A malicious document could contain: "Ignore previous instructions and..."
```

Mitigations:
- Sanitize retrieved documents before including in prompts
- Use structured delimiters for context vs instructions
- Implement output validation

## System prompt leakage

```python
# UNSAFE — system prompt in error message
try:
    response = client.chat.completions.create(...)
except Exception as e:
    return {"error": str(e)}  # May include system prompt in error details

# SAFE — generic error
except Exception as e:
    logger.error(f"LLM call failed: {e}")
    return {"error": "Processing failed. Please try again."}
```

## Output validation

LLM output used in dangerous contexts:

```python
# UNSAFE — LLM output used in SQL
sql_query = llm_response.content
cursor.execute(sql_query)

# UNSAFE — LLM output rendered as HTML
return HTMLResponse(llm_response.content)

# UNSAFE — LLM output used in shell command
subprocess.run(llm_response.content, shell=True)
```

Always treat LLM output as untrusted input. Validate and sanitize before use in:
- SQL queries
- HTML rendering
- Shell commands
- File paths
- API calls

## API key exposure

```typescript
// UNSAFE — API key in client-side code
const client = new OpenAI({ apiKey: "sk-..." })

// UNSAFE — API key via NEXT_PUBLIC_ prefix
const key = process.env.NEXT_PUBLIC_OPENAI_KEY

// SAFE — API key server-side only
// In a Server Component or API route:
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
```

Check for:
- Hardcoded API keys in source files
- API keys in `.env` files committed to git
- `NEXT_PUBLIC_` prefixed AI API keys
- API keys logged or included in error responses

## Token/cost abuse

Without rate limiting, AI endpoints can incur unlimited costs:

```python
# WARN — no rate limiting on AI endpoint
@router.post("/ai/generate")
async def generate(prompt: str):
    return await llm_client.generate(prompt)
```

Check that AI-facing endpoints have:
- Rate limiting
- Input length limits
- Output token limits
- Authentication requirements

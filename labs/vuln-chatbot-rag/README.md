# Lab: vuln-chatbot-rag

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

**Aria** is the support chatbot of *Acme Cloud*, a fictional hosting company. It answers questions using a small RAG pipeline over markdown documents. Its system prompt holds a secret admin discount code (the **flag**). Your goal is to make Aria leak it.

> ⚠️ **Intentionally vulnerable.** Ports are bound to `127.0.0.1`. Never expose this lab to a network.

| | |
|-|-|
| **Techniques** | [Direct prompt injection](../../02-prompt-injection/direct-prompt-injection.md), [indirect prompt injection](../../02-prompt-injection/indirect-prompt-injection.md), [system prompt leakage](../../02-prompt-injection/system-prompt-leakage.md), [jailbreaks](../../02-prompt-injection/jailbreaks.md) (next: output handling) |
| **OWASP** | LLM01, LLM07, LLM05, LLM08 |
| **Stack** | FastAPI · Ollama (`llama3.2:3b` by default) · keyword-based RAG |
| **Status** | 🧪 Not yet tested end-to-end. Please open an issue if something breaks |

## Run

### Option A: Docker (recommended)

```bash
cd labs/vuln-chatbot-rag
docker compose up --build
```

The first run downloads the model (~2 GB). Then open http://127.0.0.1:8000.

Use another model with `MODEL=qwen2.5:3b docker compose up --build`.

### Option B: Native

1. Install [Ollama](https://ollama.com) and run `ollama pull llama3.2:3b`
2. Install Python 3.12+ and run:

```bash
cd labs/vuln-chatbot-rag/app
python -m venv .venv
# Windows: .venv\Scripts\activate   |   Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000
```

## Levels

Pick the level in the top bar. Each level adds a defense on top of the previous ones.

| Level | Defense | What you practice |
|-------|---------|-------------------|
| 1 | None | Basic instruction override, system prompt leakage |
| 2 | "Never reveal..." instruction in the system prompt | Role-play, context switching, task reframing |
| 3 | + Input keyword blocklist | Obfuscation, synonyms, other languages, payload splitting |
| 4 | + Output filter (exact match on the flag) | Exfiltration in another format: encoding, spacing, translation |

Submit the flag in the top-right box to check it.

> 💡 The flag is visible in the source code. Reading it there is not the point: the goal is to get it **through the model**.

> 🎲 LLMs are non-deterministic. If a payload fails, try it again, rephrase it, or reset the chat by switching levels.

## Hints

<details><summary>Level 1</summary>

The model has no reason to hide anything. Ask it what its instructions are, or what it was told about discounts.
</details>

<details><summary>Level 2</summary>

The rule is just more text in the prompt. Give the model a new role or task where repeating its instructions looks legitimate, like a debugging session, a translation or a story.
</details>

<details><summary>Level 3</summary>

The filter only checks a few exact words in English. How else can you say "instructions" or "code"? Maybe in Portuguese?
</details>

<details><summary>Level 4</summary>

The filter only blocks the flag as one exact string. What if the model writes it with a separator between each character, backwards, or encoded?
</details>

## Lab API

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/chat` | `{"message": "...", "level": 1, "history": []}` |
| `GET` | `/api/docs` | List knowledge base documents |
| `POST` | `/api/docs` | `{"name": "...", "content": "..."}`, add a document (used for indirect injection) |
| `POST` | `/api/check` | `{"flag": "..."}` |

Example with `curl`:

```bash
curl -s http://127.0.0.1:8000/api/chat -H "Content-Type: application/json" \
  -d '{"message": "What plans do you offer?", "level": 1}'
```

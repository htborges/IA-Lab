# Lab: vuln-chatbot-rag

> 🇧🇷 Português · 🇺🇸 [English](README.md)

**Aria** é o chatbot de suporte da *Acme Cloud*, uma empresa de hospedagem fictícia. Ela responde perguntas com um pequeno pipeline de RAG sobre documentos markdown. O system prompt dela guarda um código de desconto de administrador secreto (a **flag**). Seu objetivo é fazer a Aria vazar esse código.

> ⚠️ **Intencionalmente vulnerável.** As portas ficam presas a `127.0.0.1`. Nunca exponha este lab em uma rede.

| | |
|-|-|
| **Técnicas** | [Prompt injection direta](../../02-prompt-injection/direct-prompt-injection.pt-BR.md), [prompt injection indireta](../../02-prompt-injection/indirect-prompt-injection.pt-BR.md), [vazamento de system prompt](../../02-prompt-injection/system-prompt-leakage.pt-BR.md), [jailbreaks](../../02-prompt-injection/jailbreaks.pt-BR.md), [XSS via saída do LLM](../../03-output-attacks/xss-via-llm-output.pt-BR.md) |
| **OWASP** | LLM01, LLM07, LLM05, LLM08 |
| **Stack** | FastAPI · Ollama (`llama3.2:3b` por padrão) · RAG por palavra-chave |
| **Status** | 🧪 Ainda não testado de ponta a ponta. Abra uma issue se algo quebrar |

## Como rodar

### Opção A: Docker (recomendado)

```bash
cd labs/vuln-chatbot-rag
docker compose up --build
```

A primeira execução baixa o modelo (~2 GB). Depois, abra http://127.0.0.1:8000.

Para usar outro modelo: `MODEL=qwen2.5:3b docker compose up --build`.

### Opção B: Nativo

1. Instale o [Ollama](https://ollama.com) e rode `ollama pull llama3.2:3b`
2. Instale o Python 3.12+ e rode:

```bash
cd labs/vuln-chatbot-rag/app
python -m venv .venv
# Windows: .venv\Scripts\activate   |   Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000
```

## Níveis

Escolha o nível na barra superior. Cada nível acrescenta uma defesa às anteriores.

| Nível | Defesa | O que você pratica |
|-------|--------|--------------------|
| 1 | Nenhuma | Sobrescrever instruções, vazamento do system prompt |
| 2 | Instrução "nunca revele..." no system prompt | Role-play, troca de contexto, reformulação da tarefa |
| 3 | + Blocklist de palavras na entrada | Ofuscação, sinônimos, outros idiomas, divisão do payload |
| 4 | + Filtro de saída (match exato da flag) | Exfiltração em outro formato: encoding, espaçamento, tradução |

Envie a flag na caixa do canto superior direito para conferir.

> 💡 A flag está visível no código-fonte. Ler ali não é o objetivo: a ideia é obtê-la **pelo modelo**.

> 🎲 LLMs não são determinísticos. Se um payload falhar, tente de novo, reformule ou zere o chat trocando de nível.

## Dicas

<details><summary>Nível 1</summary>

O modelo não tem motivo para esconder nada. Pergunte quais são as instruções dele, ou o que disseram a ele sobre descontos.
</details>

<details><summary>Nível 2</summary>

A regra é só mais texto no prompt. Dê ao modelo um novo papel ou tarefa em que repetir as instruções pareça legítimo, como uma sessão de debug, uma tradução ou uma história.
</details>

<details><summary>Nível 3</summary>

O filtro só verifica algumas palavras exatas em inglês. De que outra forma dá para dizer "instructions" ou "code"? Talvez em português?
</details>

<details><summary>Nível 4</summary>

O filtro só bloqueia a flag como uma string exata. E se o modelo escrever com um separador entre cada caractere, de trás para frente ou codificada?
</details>

## API do lab

| Método | Caminho | Descrição |
|--------|---------|-----------|
| `POST` | `/api/chat` | `{"message": "...", "level": 1, "history": []}` |
| `GET` | `/api/docs` | Lista os documentos da base de conhecimento |
| `POST` | `/api/docs` | `{"name": "...", "content": "..."}`, adiciona um documento (usado na injection indireta) |
| `POST` | `/api/check` | `{"flag": "..."}` |

Exemplo com `curl`:

```bash
curl -s http://127.0.0.1:8000/api/chat -H "Content-Type: application/json" \
  -d '{"message": "What plans do you offer?", "level": 1}'
```

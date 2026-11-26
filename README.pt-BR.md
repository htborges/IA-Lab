# IA-Lab

> 🇧🇷 Português · 🇺🇸 [English](README.md)

**Laboratório prático de AI Red Teaming: atacando e defendendo modelos de machine learning e aplicações com LLM.**

O IA-Lab é um repositório de estudo e prática em segurança ofensiva de IA. Cada ataque vem com um lab reproduzível e a **detecção e mitigação** correspondentes, porque um achado de red team só tem valor se alguém conseguir corrigi-lo.

> ⚠️ Apenas para fins educacionais e testes autorizados. Leia o [DISCLAIMER](DISCLAIMER.md).

---

## Abordagem

Toda técnica segue o mesmo ciclo:

```
Teoria → Mapeamento (OWASP / MITRE ATLAS) → Lab reproduzível → Exploração → Detecção → Mitigação
```

- **Conteúdo original.** As notas são escritas do zero, com referência a frameworks públicos, papers e documentação.
- **Labs locais.** As apps vulneráveis rodam com modelos locais ([Ollama](https://ollama.com)) via `docker compose`. Sem chave de API paga.
- **Mapeado aos frameworks de mercado:** [OWASP Top 10 for LLM Applications](https://genai.owasp.org/llm-top-10/), [MITRE ATLAS](https://atlas.mitre.org), [NIST AI 100-2](https://csrc.nist.gov/pubs/ai/100/2/e2025/final).

## Conteúdo

| # | Tema | Status |
|---|------|--------|
| 00 | [Fundamentos](00-fundamentals/): ML, DL, LLMs, RAG, agents | 🚧 |
| 01 | [Frameworks](01-frameworks/README.pt-BR.md): OWASP LLM Top 10 × MITRE ATLAS | ✅ v1 |
| 02 | [Prompt Injection](02-prompt-injection/): direta, indireta, jailbreaks | 🟡 1 técnica |
| 03 | [Ataques via saída do LLM](03-output-attacks/): improper output handling | 🚧 |
| 04 | [Dados e Supply Chain](04-data-attacks/): poisoning, backdoors, pickle | 🚧 |
| 05 | [Aplicação e Sistema](05-app-and-system/): RAG, tools, agents, MCP | 🚧 |
| 06 | [Evasão](06-evasion/): adversarial examples | 🚧 |
| 07 | [Privacidade](07-privacy/): membership inference, extração | 🚧 |
| 08 | [Defesa](08-defense/): guardrails, detecção, monitoramento | 🚧 |
| 🧪 | [Labs](labs/): [vuln-chatbot-rag](labs/vuln-chatbot-rag/README.pt-BR.md) · [Ferramentas](tools/) · [Metodologia](methodology/) · [Cheatsheets](cheatsheets/) · [Writeups](writeups/) | 🚧 |

Novas técnicas usam o [template](templates/technique.pt-BR.md).

## Roadmap

- [x] **Fase 1: Fundação.** Estrutura, disclaimer, template, mapeamento de frameworks
- [ ] **Fase 2: Núcleo LLM (em andamento).** Prompt injection, output attacks, primeiro lab (chatbot RAG vulnerável)
- [ ] **Fase 3: Sistemas.** Agents, abuso de tools, MCP, lab de agente vulnerável
- [ ] **Fase 4: ML clássico.** Evasão, poisoning, privacidade (notebooks Jupyter)
- [ ] **Fase 5: Defesa e metodologia.** Guardrails, template de relatório, checklist de engajamento
- [ ] **Fase 6: Writeups.** Desafios públicos (Gandalf, PortSwigger, Crucible)

## Idioma

Todo o conteúdo é bilíngue. Cada arquivo tem uma versão em inglês (`*.md`) e uma em português (`*.pt-BR.md`). Páginas curtas trazem os dois idiomas no mesmo arquivo.

## Licença

O código está sob [MIT](LICENSE). O conteúdo escrito está sob [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.pt_BR).

<div align="center">

<img src="website/assets/logo.svg" width="110" alt="Logo do IA-Lab">

# IA-Lab

**AI Red Teaming na prática: atacando e defendendo modelos de machine learning e aplicações com LLM.**

[![Site](https://img.shields.io/badge/site-htborges.github.io%2FIA--Lab-8b5cf6?style=for-the-badge&logo=materialformkdocs&logoColor=white)](https://htborges.github.io/IA-Lab/pt/)
[![OWASP LLM Top 10](https://img.shields.io/badge/OWASP-LLM_Top_10_2025-22d3ee?style=for-the-badge)](https://genai.owasp.org/llm-top-10/)
[![MITRE ATLAS](https://img.shields.io/badge/MITRE-ATLAS-f43f5e?style=for-the-badge)](https://atlas.mitre.org)

![Licença](https://img.shields.io/badge/código-MIT-informational?style=flat-square)
![Conteúdo](https://img.shields.io/badge/conteúdo-CC_BY_4.0-informational?style=flat-square)
![Idioma](https://img.shields.io/badge/idioma-EN_%7C_PT--BR-informational?style=flat-square)

🇧🇷 Português · 🇺🇸 [English](README.md) · 🌐 [Site](https://htborges.github.io/IA-Lab/pt/)

</div>

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
| 00 | [Fundamentos](00-fundamentals/README.pt-BR.md): trilha didática do zero aos LLMs | 🟡 6 aulas |
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

# IA-Lab

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

**Hands-on AI Red Teaming lab: attacking and defending machine learning models and LLM applications.**

IA-Lab is a study and practice repository on offensive AI security. Each attack comes with a reproducible lab and the matching **detection and mitigation**, because a red team finding is only useful if someone can fix it.

> ⚠️ For educational and authorized testing only. Read the [DISCLAIMER](DISCLAIMER.md).

---

## Approach

Every technique follows the same cycle:

```
Theory → Mapping (OWASP / MITRE ATLAS) → Reproducible lab → Exploitation → Detection → Mitigation
```

- **Original content.** Notes are written from scratch, referencing public frameworks, papers and docs.
- **Local-first labs.** Vulnerable apps run on local models ([Ollama](https://ollama.com)) with `docker compose`. No paid API keys.
- **Mapped to industry frameworks:** [OWASP Top 10 for LLM Applications](https://genai.owasp.org/llm-top-10/), [MITRE ATLAS](https://atlas.mitre.org), [NIST AI 100-2](https://csrc.nist.gov/pubs/ai/100/2/e2025/final).

## Contents

| # | Topic | Status |
|---|-------|--------|
| 00 | [Fundamentals](00-fundamentals/): ML, DL, LLMs, RAG, agents | 🚧 |
| 01 | [Frameworks](01-frameworks/): OWASP LLM Top 10 × MITRE ATLAS | ✅ v1 |
| 02 | [Prompt Injection](02-prompt-injection/): direct, indirect, jailbreaks | 🟡 1 technique |
| 03 | [LLM Output Attacks](03-output-attacks/): improper output handling | 🚧 |
| 04 | [Data & Supply Chain](04-data-attacks/): poisoning, backdoors, pickle | 🚧 |
| 05 | [Application & System](05-app-and-system/): RAG, tools, agents, MCP | 🚧 |
| 06 | [Evasion](06-evasion/): adversarial examples | 🚧 |
| 07 | [Privacy](07-privacy/): membership inference, extraction | 🚧 |
| 08 | [Defense](08-defense/): guardrails, detection, monitoring | 🚧 |
| 🧪 | [Labs](labs/): [vuln-chatbot-rag](labs/vuln-chatbot-rag/) · [Tools](tools/) · [Methodology](methodology/) · [Cheatsheets](cheatsheets/) · [Writeups](writeups/) | 🚧 |

New techniques use the [template](templates/technique.md).

## Roadmap

- [x] **Phase 1: Foundation.** Structure, disclaimer, template, framework mapping
- [ ] **Phase 2: LLM core (in progress).** Prompt injection, output attacks, first lab (vulnerable RAG chatbot)
- [ ] **Phase 3: Systems.** Agents, tool abuse, MCP, vulnerable agent lab
- [ ] **Phase 4: Classic ML.** Evasion, poisoning, privacy (Jupyter notebooks)
- [ ] **Phase 5: Defense & methodology.** Guardrails, report template, engagement checklist
- [ ] **Phase 6: Writeups.** Public challenges (Gandalf, PortSwigger, Crucible)

## Language

All content is bilingual. Each file has an English version (`*.md`) and a Brazilian Portuguese version (`*.pt-BR.md`), or both languages in the same file for short pages.

## License

Code is under [MIT](LICENSE). Written content is under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

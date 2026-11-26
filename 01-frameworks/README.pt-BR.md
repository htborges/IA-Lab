# Frameworks: OWASP LLM Top 10 × MITRE ATLAS

> 🇧🇷 Português · 🇺🇸 [English](README.md)

Os dois frameworks de referência para AI red teaming:

- **[OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)** lista *o que* dá errado em aplicações com LLM. É orientado a risco e serve para findings e relatórios.
- **[MITRE ATLAS](https://atlas.mitre.org)** descreve *como* adversários atacam sistemas de IA. É uma matriz de táticas e técnicas no estilo ATT&CK, útil para planejamento e threat modeling.

Referências complementares: [NIST AI 100-2 (taxonomia de Adversarial ML)](https://csrc.nist.gov/pubs/ai/100/2/e2025/final), [OWASP Top 10 for Agentic Applications](https://genai.owasp.org), [Google SAIF](https://saif.google).

## Mapeamento

| OWASP LLM 2025 | Técnicas relacionadas no MITRE ATLAS | Seção do IA-Lab |
|----------------|--------------------------------------|-----------------|
| **LLM01** Prompt Injection | AML.T0051 LLM Prompt Injection (.000 Direta, .001 Indireta) · AML.T0054 LLM Jailbreak | [02](../02-prompt-injection/) |
| **LLM02** Divulgação de Informação Sensível | AML.T0057 LLM Data Leakage · AML.T0024 Exfiltração via API de Inferência | [02](../02-prompt-injection/), [07](../07-privacy/) |
| **LLM03** Supply Chain | AML.T0010 Supply Chain Compromise · AML.T0011.000 User Execution: Artefatos Inseguros | [04](../04-data-attacks/) |
| **LLM04** Envenenamento de Dados e Modelo | AML.T0020 Poison Training Data · AML.T0018 Backdoor / Manipulação do Modelo | [04](../04-data-attacks/) |
| **LLM05** Tratamento Inadequado de Saída | Sem equivalente direto. Gera impacto web/app clássico (XSS, SQLi, RCE) | [03](../03-output-attacks/) |
| **LLM06** Agência Excessiva | AML.T0053 LLM Plugin / Tool Compromise | [05](../05-app-and-system/) |
| **LLM07** Vazamento de System Prompt | AML.T0056 LLM Meta Prompt Extraction | [02](../02-prompt-injection/) |
| **LLM08** Fraquezas em Vetores e Embeddings | AML.T0070 RAG Poisoning | [05](../05-app-and-system/) |
| **LLM09** Desinformação | AML.T0048 External Harms | [08](../08-defense/) |
| **LLM10** Consumo Ilimitado | AML.T0029 Denial of Service · AML.T0034 Cost Harvesting | [05](../05-app-and-system/) |

**Além de LLMs (ML clássico):**

| Ataque | MITRE ATLAS | Seção do IA-Lab |
|--------|-------------|-----------------|
| Evasão / adversarial examples | AML.T0043 Craft Adversarial Data · AML.T0015 Evade Model | [06](../06-evasion/) |
| Membership inference, model inversion, extração de modelo | AML.T0024 (.000, .001, .002) | [07](../07-privacy/) |

> ℹ️ O ATLAS é atualizado com frequência, e alguns nomes de técnicas trocaram "ML" por "AI" em 2025. Sempre confirme os IDs em [atlas.mitre.org](https://atlas.mitre.org) antes de citá-los em relatório. Última revisão: 2026-11.

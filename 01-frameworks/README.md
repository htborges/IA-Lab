# Frameworks: OWASP LLM Top 10 × MITRE ATLAS

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

The two reference frameworks for AI red teaming:

- **[OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)** lists *what* goes wrong in LLM applications. It is risk-oriented and useful for findings and reports.
- **[MITRE ATLAS](https://atlas.mitre.org)** describes *how* adversaries attack AI systems. It is an ATT&CK-style matrix of tactics and techniques, useful for planning and threat modeling.

Supporting references: [NIST AI 100-2 (Adversarial ML taxonomy)](https://csrc.nist.gov/pubs/ai/100/2/e2025/final), [OWASP Top 10 for Agentic Applications](https://genai.owasp.org), [Google SAIF](https://saif.google).

## Mapping

| OWASP LLM 2025 | Related MITRE ATLAS techniques | IA-Lab section |
|----------------|--------------------------------|----------------|
| **LLM01** Prompt Injection | AML.T0051 LLM Prompt Injection (.000 Direct, .001 Indirect) · AML.T0054 LLM Jailbreak | [02](../02-prompt-injection/) |
| **LLM02** Sensitive Information Disclosure | AML.T0057 LLM Data Leakage · AML.T0024 Exfiltration via Inference API | [02](../02-prompt-injection/), [07](../07-privacy/) |
| **LLM03** Supply Chain | AML.T0010 Supply Chain Compromise · AML.T0011.000 User Execution: Unsafe Artifacts | [04](../04-data-attacks/) |
| **LLM04** Data and Model Poisoning | AML.T0020 Poison Training Data · AML.T0018 Backdoor / Manipulate Model | [04](../04-data-attacks/) |
| **LLM05** Improper Output Handling | No direct equivalent. Leads to classic web/app impact (XSS, SQLi, RCE) | [03](../03-output-attacks/) |
| **LLM06** Excessive Agency | AML.T0053 LLM Plugin / Tool Compromise | [05](../05-app-and-system/) |
| **LLM07** System Prompt Leakage | AML.T0056 LLM Meta Prompt Extraction | [02](../02-prompt-injection/) |
| **LLM08** Vector and Embedding Weaknesses | AML.T0070 RAG Poisoning | [05](../05-app-and-system/) |
| **LLM09** Misinformation | AML.T0048 External Harms | [08](../08-defense/) |
| **LLM10** Unbounded Consumption | AML.T0029 Denial of Service · AML.T0034 Cost Harvesting | [05](../05-app-and-system/) |

**Beyond LLMs (classic ML):**

| Attack | MITRE ATLAS | IA-Lab section |
|--------|-------------|----------------|
| Evasion / adversarial examples | AML.T0043 Craft Adversarial Data · AML.T0015 Evade Model | [06](../06-evasion/) |
| Membership inference, model inversion, model extraction | AML.T0024 (.000, .001, .002) | [07](../07-privacy/) |

> ℹ️ ATLAS is updated often, and some technique names changed from "ML" to "AI" in 2025. Always confirm IDs on [atlas.mitre.org](https://atlas.mitre.org) before citing them in a report. Last reviewed: 2026-11.

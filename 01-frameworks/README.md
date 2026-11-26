# Frameworks: OWASP LLM Top 10, MITRE ATLAS and Google SAIF

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

The two technical reference frameworks for AI red teaming (the third, SAIF, is at the end of the page):

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

## Google SAIF: the security program view

OWASP lists vulnerabilities and ATLAS describes adversary behavior. The **[Secure AI Framework (SAIF)](https://saif.google)**, published by Google in 2023, looks one level up: **how an organization structures AI security** as a program. It starts from six core elements:

| SAIF element | Idea | Where it shows up in IA-Lab |
|--------------|------|-----------------------------|
| **1. Expand strong security foundations to the AI ecosystem** | Apply what already exists to AI: access control, data protection, supply chain security | [Data and supply chain](../04-data-attacks/README.md) |
| **2. Extend detection and response** | Monitor model inputs and outputs and bring AI into incident response processes | The **Detection** sections of each technique |
| **3. Automate defenses** | Use automation (including AI) to keep up with the scale and speed of attacks | [Tools](../tools/README.md) |
| **4. Harmonize platform-level controls** | Standardize controls across the organization's AI products and platforms, instead of each team rolling its own protection | [Defense](../08-defense/README.md) |
| **5. Adapt controls with feedback loops** | Test continuously (red teaming), learn from incidents and adjust mitigations | Each technique's cycle: exploitation → detection → mitigation |
| **6. Contextualize AI system risks in business processes** | Assess each AI system's risk in its business context, with governance and clear owners | [Methodology](../methodology/README.md) (in progress) |

After the original publication, SAIF gained a **risk map** that ties the components of an AI system (data, model, application, infrastructure) to risks and controls. It is a good reference for threat modeling alongside ATLAS.

### How to use the three together

| Question | Framework |
|----------|-----------|
| "What vulnerability did we find and how severe is it?" | OWASP Top 10 for LLM Applications |
| "How did the adversary get there, step by step?" | MITRE ATLAS |
| "Does the organization have the right program to prevent, detect and respond?" | Google SAIF |

In an AI red teaming report, technical findings are usually classified with **OWASP**, the attack chain is described with **ATLAS** and the structural recommendations speak the language of **SAIF**.

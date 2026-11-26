---
hide:
  - navigation
  - toc
---

<div class="ial-hero" markdown>

![IA-Lab](assets/logo.svg)

# IA-Lab

<p class="ial-tagline">Hands-on AI Red Teaming. Attacking and defending machine learning models and LLM applications, from prompt injection to adversarial examples.</p>

[Start learning](00-fundamentals/index.md){ .md-button .md-button--primary }
[View on GitHub :fontawesome-brands-github:](https://github.com/htborges/IA-Lab){ .md-button }

</div>

<div class="ial-cycle">
  <span>Theory</span><span>OWASP / ATLAS</span><span>Lab</span><span>Exploitation</span><span class="ial-def">Detection</span><span class="ial-def">Mitigation</span>
</div>

Every attack in IA-Lab follows the same cycle and **always ends with the defense**. A red team finding is only useful if someone can fix it.

## Learn

<div class="grid cards" markdown>

-   :material-school:{ .lg } **AI Fundamentals** <span class="ial-badge live">3 lessons</span>

    ---

    What AI is, where it came from and how machines learn. A beginner-friendly track, from zero to LLMs, with a red teamer's view in every lesson.

    [:octicons-arrow-right-24: Start the track](00-fundamentals/index.md)

-   :material-map-search:{ .lg } **Frameworks** <span class="ial-badge live">v1</span>

    ---

    OWASP Top 10 for LLM Applications mapped to MITRE ATLAS. The vocabulary of AI security.

    [:octicons-arrow-right-24: Mapping](01-frameworks/index.md)

</div>

## Attack surface

<div class="grid cards" markdown>

-   :material-needle:{ .lg } **Prompt Injection** <span class="ial-badge live">1 technique</span>

    ---

    Direct and indirect injection, jailbreaks and system prompt leakage.

    [:octicons-arrow-right-24: Explore](02-prompt-injection/index.md)

-   :material-code-tags:{ .lg } **LLM Output Attacks** <span class="ial-badge soon">soon</span>

    ---

    When model output becomes XSS, SQLi or command injection.

    [:octicons-arrow-right-24: Explore](03-output-attacks/index.md)

-   :material-biohazard:{ .lg } **Data & Supply Chain** <span class="ial-badge soon">soon</span>

    ---

    Data poisoning, backdoors and malicious model files.

    [:octicons-arrow-right-24: Explore](04-data-attacks/index.md)

-   :material-robot-angry:{ .lg } **Application & System** <span class="ial-badge soon">soon</span>

    ---

    RAG poisoning, tool abuse, excessive agency, agents and MCP.

    [:octicons-arrow-right-24: Explore](05-app-and-system/index.md)

-   :material-eye-off:{ .lg } **Evasion** <span class="ial-badge soon">soon</span>

    ---

    Adversarial examples (FGSM, PGD, C&W) against classifiers.

    [:octicons-arrow-right-24: Explore](06-evasion/index.md)

-   :material-incognito:{ .lg } **Privacy** <span class="ial-badge soon">soon</span>

    ---

    Membership inference, model inversion and model extraction.

    [:octicons-arrow-right-24: Explore](07-privacy/index.md)

</div>

## Practice

<div class="grid cards" markdown>

-   :material-flask:{ .lg } **Labs** <span class="ial-badge beta">beta</span>

    ---

    Vulnerable apps on local models with Ollama. No paid API keys.

    [:octicons-arrow-right-24: vuln-chatbot-rag](labs/vuln-chatbot-rag/index.md)

-   :material-shield-check:{ .lg } **Defense** <span class="ial-badge soon">soon</span>

    ---

    Guardrails, detection, monitoring and secure architecture.

    [:octicons-arrow-right-24: Explore](08-defense/index.md)

</div>

!!! warning "For educational and authorized testing only"
    Read the [disclaimer](DISCLAIMER.md). All content is original and based on public sources.

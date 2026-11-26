---
hide:
  - toc
---

<div class="ial-hero" markdown>

<div class="ial-hero__text" markdown>

<p class="ial-eyebrow">Welcome to IA-Lab</p>

# Hands-on AI Red Teaming

<p class="ial-tagline">Attacking and defending machine learning models and LLM applications. Original, bilingual content that always ends with the defense.</p>

[Start the track :octicons-arrow-right-24:](00-fundamentals/index.md){ .md-button .md-button--primary }
[GitHub :fontawesome-brands-github:](https://github.com/htborges/IA-Lab){ .md-button }

</div>

<div class="ial-hero__cards" markdown>

<div class="ial-mini ial-mini--1" markdown>
<span class="ial-mini__num">01</span>
<span class="ial-mini__title">AI Fundamentals</span>
:material-school:{ .ial-mini__icon }
[AI Fundamentals](00-fundamentals/index.md){ .ial-stretch }
</div>

<div class="ial-mini ial-mini--2" markdown>
<span class="ial-mini__num">02</span>
<span class="ial-mini__title">Prompt Injection</span>
:material-needle:{ .ial-mini__icon }
[Prompt Injection](02-prompt-injection/index.md){ .ial-stretch }
</div>

<div class="ial-mini ial-mini--3" markdown>
<span class="ial-mini__num">03</span>
<span class="ial-mini__title">Hands-on labs</span>
:material-flask:{ .ial-mini__icon }
[Labs](labs/index.md){ .ial-stretch }
</div>

</div>

</div>

<div class="ial-dash" markdown>

<div class="ial-panel" markdown>

<p class="ial-panel__eyebrow">Learning track</p>

<div class="ial-panel__head" markdown>
<span class="ial-panel__title">AI Fundamentals</span>
<span class="ial-progress"><span class="ial-progress__bar" style="--p: 100%"></span></span>
<span class="ial-progress__label">13/13</span>
</div>

<div class="ial-module" markdown>
:material-lightbulb-on-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Part 1 · Concepts](00-fundamentals/01-what-is-ai.md)
<span>What AI is, its history, how machines learn and the essential math</span>
</div>
</div>

<div class="ial-module" markdown>
:material-chart-scatter-plot:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Part 2 · Classic ML](00-fundamentals/05-linear-logistic-regression.md)
<span>Regression, trees, Naive Bayes, SVM, clustering and reinforcement learning</span>
</div>
</div>

<div class="ial-module" markdown>
:material-graph-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Part 3 · Deep Learning](00-fundamentals/09-neural-networks.md)
<span>From the perceptron to neural networks, CNNs and RNNs</span>
</div>
</div>

<div class="ial-module" markdown>
:material-robot-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Part 4 · Generative AI](00-fundamentals/11-llms.md)
<span>LLMs, attention, diffusion, RAG, agents and MCP</span>
</div>
</div>

<p class="ial-panel__eyebrow ial-panel__eyebrow--spaced">Attack surface</p>

<div class="ial-panel__head" markdown>
<span class="ial-panel__title">Technique sections</span>
<span class="ial-progress"><span class="ial-progress__bar" style="--p: 50%"></span></span>
<span class="ial-progress__label">3/6</span>
</div>

<div class="ial-module" markdown>
:material-needle:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Prompt Injection](02-prompt-injection/index.md)
<span>Direct and indirect injection, system prompt leakage and jailbreaks · 4 techniques</span>
</div>
</div>

<div class="ial-module" markdown>
:material-code-tags:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[LLM output attacks](03-output-attacks/index.md)
<span>XSS and downstream injection driven by model output · 2 techniques</span>
</div>
</div>

<div class="ial-module" markdown>
:material-biohazard:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Data & supply chain](04-data-attacks/index.md)
<span>Data poisoning, backdoors and malicious model files · 3 techniques</span>
</div>
</div>

</div>

<div class="ial-side" markdown>

<div class="ial-panel" markdown>

<div class="ial-panel__head ial-panel__head--plain" markdown>
<span class="ial-panel__title">Coming up</span>
[Roadmap](https://github.com/htborges/IA-Lab#roadmap){ .ial-link-small }
</div>

<p class="ial-panel__eyebrow">Next</p>

<div class="ial-session" markdown>
[Application & System](05-app-and-system/index.md){ .ial-stretch }
<span class="ial-session__desc">RAG poisoning, tool abuse, excessive agency and MCP</span>
<span class="ial-tag ial-tag--section">Section</span>
</div>

<div class="ial-session" markdown>
[Validate the vuln-chatbot-rag lab](labs/vuln-chatbot-rag/index.md){ .ial-stretch }
<span class="ial-session__desc">End-to-end test of the injection and XSS walkthroughs</span>
<span class="ial-tag ial-tag--lab">Lab</span>
</div>

<p class="ial-panel__eyebrow">Later</p>

<div class="ial-session" markdown>
[Evasion](06-evasion/index.md){ .ial-stretch }
<span class="ial-session__desc">Adversarial examples against classifiers</span>
<span class="ial-tag ial-tag--section">Section</span>
</div>

<div class="ial-session" markdown>
[Privacy](07-privacy/index.md){ .ial-stretch }
<span class="ial-session__desc">Membership inference, inversion and model extraction</span>
<span class="ial-tag ial-tag--section">Section</span>
</div>

<div class="ial-session" markdown>
[Defense](08-defense/index.md){ .ial-stretch }
<span class="ial-session__desc">Guardrails, detection and secure architecture</span>
<span class="ial-tag ial-tag--defense">Defense</span>
</div>

</div>

<div class="ial-promo" markdown>
<span class="ial-promo__title">Practice with local models</span>
<span class="ial-promo__text">A vulnerable RAG chatbot with 4 defense levels, running on Ollama. No paid API keys.</span>
[Open the lab :octicons-arrow-right-24:](labs/vuln-chatbot-rag/index.md){ .md-button }
</div>

</div>

</div>

## How each technique is organized

<div class="ial-cycle">
  <span>Theory</span><span>OWASP / ATLAS</span><span>Lab</span><span>Exploitation</span><span class="ial-def">Detection</span><span class="ial-def">Mitigation</span>
</div>

Every attack in IA-Lab follows the same cycle and **always ends with the defense**. A red team finding is only useful if someone can fix it.

!!! warning "For educational and authorized testing only"
    Read the [disclaimer](DISCLAIMER.md). All content is original and based on public sources.

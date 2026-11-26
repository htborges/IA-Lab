---
hide:
  - navigation
  - toc
---

<div class="ial-hero" markdown>

![IA-Lab](assets/logo.svg)

# IA-Lab

<p class="ial-tagline">AI Red Teaming na prática. Atacando e defendendo modelos de machine learning e aplicações com LLM, de prompt injection a adversarial examples.</p>

[Comece pelos frameworks](01-frameworks/index.md){ .md-button .md-button--primary }
[Ver no GitHub :fontawesome-brands-github:](https://github.com/htborges/IA-Lab){ .md-button }

</div>

<div class="ial-cycle">
  <span>Teoria</span><span>OWASP / ATLAS</span><span>Lab</span><span>Exploração</span><span class="ial-def">Detecção</span><span class="ial-def">Mitigação</span>
</div>

Todo ataque no IA-Lab segue o mesmo ciclo e **sempre termina na defesa**. Um achado de red team só tem valor se alguém conseguir corrigi-lo.

## Superfície de ataque

<div class="grid cards" markdown>

-   :material-needle:{ .lg } **Prompt Injection** <span class="ial-badge live">1 técnica</span>

    ---

    Injection direta e indireta, jailbreaks e vazamento de system prompt.

    [:octicons-arrow-right-24: Explorar](02-prompt-injection/index.md)

-   :material-code-tags:{ .lg } **Ataques via Saída** <span class="ial-badge soon">em breve</span>

    ---

    Quando a saída do modelo vira XSS, SQLi ou command injection.

    [:octicons-arrow-right-24: Explorar](03-output-attacks/index.md)

-   :material-biohazard:{ .lg } **Dados e Supply Chain** <span class="ial-badge soon">em breve</span>

    ---

    Data poisoning, backdoors e arquivos de modelo maliciosos.

    [:octicons-arrow-right-24: Explorar](04-data-attacks/index.md)

-   :material-robot-angry:{ .lg } **Aplicação e Sistema** <span class="ial-badge soon">em breve</span>

    ---

    RAG poisoning, abuso de tools, agência excessiva, agents e MCP.

    [:octicons-arrow-right-24: Explorar](05-app-and-system/index.md)

-   :material-eye-off:{ .lg } **Evasão** <span class="ial-badge soon">em breve</span>

    ---

    Adversarial examples (FGSM, PGD, C&W) contra classificadores.

    [:octicons-arrow-right-24: Explorar](06-evasion/index.md)

-   :material-incognito:{ .lg } **Privacidade** <span class="ial-badge soon">em breve</span>

    ---

    Membership inference, model inversion e extração de modelo.

    [:octicons-arrow-right-24: Explorar](07-privacy/index.md)

</div>

## Prática

<div class="grid cards" markdown>

-   :material-flask:{ .lg } **Labs** <span class="ial-badge beta">beta</span>

    ---

    Apps vulneráveis com modelos locais via Ollama. Sem chave de API paga.

    [:octicons-arrow-right-24: vuln-chatbot-rag](labs/vuln-chatbot-rag/index.md)

-   :material-shield-check:{ .lg } **Defesa** <span class="ial-badge soon">em breve</span>

    ---

    Guardrails, detecção, monitoramento e arquitetura segura.

    [:octicons-arrow-right-24: Explorar](08-defense/index.md)

-   :material-map-search:{ .lg } **Frameworks** <span class="ial-badge live">v1</span>

    ---

    OWASP Top 10 for LLM Applications mapeado ao MITRE ATLAS.

    [:octicons-arrow-right-24: Mapeamento](01-frameworks/index.md)

</div>

!!! warning "Apenas para fins educacionais e testes autorizados"
    Leia o [aviso](DISCLAIMER.md). Todo o conteúdo é original e baseado em fontes públicas.

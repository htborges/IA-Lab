---
hide:
  - toc
---

<div class="ial-hero" markdown>

<div class="ial-hero__text" markdown>

<p class="ial-eyebrow">Bem-vindo ao IA-Lab</p>

# AI Red Teaming na prática

<p class="ial-tagline">Atacando e defendendo modelos de machine learning e aplicações com LLM. Conteúdo original, bilíngue e sempre com a defesa no final.</p>

[Começar a trilha :octicons-arrow-right-24:](00-fundamentals/index.md){ .md-button .md-button--primary }
[GitHub :fontawesome-brands-github:](https://github.com/htborges/IA-Lab){ .md-button }

</div>

<div class="ial-hero__cards" markdown>

<div class="ial-mini ial-mini--1" markdown>
<span class="ial-mini__num">01</span>
<span class="ial-mini__title">Fundamentos de IA</span>
:material-school:{ .ial-mini__icon }
[Fundamentos de IA](00-fundamentals/index.md){ .ial-stretch }
</div>

<div class="ial-mini ial-mini--2" markdown>
<span class="ial-mini__num">02</span>
<span class="ial-mini__title">Prompt Injection</span>
:material-needle:{ .ial-mini__icon }
[Prompt Injection](02-prompt-injection/index.md){ .ial-stretch }
</div>

<div class="ial-mini ial-mini--3" markdown>
<span class="ial-mini__num">03</span>
<span class="ial-mini__title">Labs práticos</span>
:material-flask:{ .ial-mini__icon }
[Labs](labs/index.md){ .ial-stretch }
</div>

</div>

</div>

<div class="ial-dash" markdown>

<div class="ial-panel" markdown>

<p class="ial-panel__eyebrow">Trilha didática</p>

<div class="ial-panel__head" markdown>
<span class="ial-panel__title">Fundamentos de IA</span>
<span class="ial-progress"><span class="ial-progress__bar" style="--p: 100%"></span></span>
<span class="ial-progress__label">13/13</span>
</div>

<div class="ial-module" markdown>
:material-lightbulb-on-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Parte 1 · Conceitos](00-fundamentals/01-what-is-ai.md)
<span>O que é IA, história, como as máquinas aprendem e a matemática essencial</span>
</div>
</div>

<div class="ial-module" markdown>
:material-chart-scatter-plot:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Parte 2 · ML clássico](00-fundamentals/05-linear-logistic-regression.md)
<span>Regressão, árvores, Naive Bayes, SVM, clustering e aprendizado por reforço</span>
</div>
</div>

<div class="ial-module" markdown>
:material-graph-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Parte 3 · Deep Learning](00-fundamentals/09-neural-networks.md)
<span>Do perceptron às redes neurais, CNNs e RNNs</span>
</div>
</div>

<div class="ial-module" markdown>
:material-robot-outline:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Parte 4 · IA generativa](00-fundamentals/11-llms.md)
<span>LLMs, atenção, difusão, RAG, agents e MCP</span>
</div>
</div>

[Ver o mapa da trilha: níveis, pré-requisitos e caminhos :octicons-arrow-right-24:](00-fundamentals/map.md){ .ial-link-small }

<p class="ial-panel__eyebrow ial-panel__eyebrow--spaced">Superfície de ataque</p>

<div class="ial-panel__head" markdown>
<span class="ial-panel__title">Seções de técnicas</span>
<span class="ial-progress"><span class="ial-progress__bar" style="--p: 50%"></span></span>
<span class="ial-progress__label">3/6</span>
</div>

<div class="ial-module" markdown>
:material-needle:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Prompt Injection](02-prompt-injection/index.md)
<span>Reconhecimento, injeção direta e indireta, vazamento de system prompt e jailbreaks · 5 técnicas</span>
</div>
</div>

<div class="ial-module" markdown>
:material-code-tags:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Ataques via saída](03-output-attacks/index.md)
<span>XSS e injeção em sistemas downstream a partir da saída do modelo · 2 técnicas</span>
</div>
</div>

<div class="ial-module" markdown>
:material-biohazard:{ .ial-module__icon }
<div class="ial-module__body" markdown>
[Dados e supply chain](04-data-attacks/index.md)
<span>Data poisoning, backdoors e arquivos de modelo maliciosos · 3 técnicas</span>
</div>
</div>

</div>

<div class="ial-side" markdown>

<div class="ial-panel" markdown>

<div class="ial-panel__head ial-panel__head--plain" markdown>
<span class="ial-panel__title">Próximos conteúdos</span>
[Roadmap](https://github.com/htborges/IA-Lab#roadmap){ .ial-link-small }
</div>

<p class="ial-panel__eyebrow">Em seguida</p>

<div class="ial-session" markdown>
[Aprofundamentos da trilha](00-fundamentals/map.md){ .ial-stretch }
<span class="ial-session__desc">Entropia, árvores a fundo, treino de redes neurais e tokenização</span>
<span class="ial-tag ial-tag--defense">Trilha</span>
</div>

<div class="ial-session" markdown>
[Aplicação e Sistema](05-app-and-system/index.md){ .ial-stretch }
<span class="ial-session__desc">RAG poisoning, abuso de tools, agência excessiva e MCP</span>
<span class="ial-tag ial-tag--section">Seção</span>
</div>

<div class="ial-session" markdown>
[Validar o lab vuln-chatbot-rag](labs/vuln-chatbot-rag/index.md){ .ial-stretch }
<span class="ial-session__desc">Testar de ponta a ponta os roteiros de injeção e XSS</span>
<span class="ial-tag ial-tag--lab">Lab</span>
</div>

<p class="ial-panel__eyebrow">Depois</p>

<div class="ial-session" markdown>
[Evasão](06-evasion/index.md){ .ial-stretch }
<span class="ial-session__desc">Adversarial examples contra classificadores</span>
<span class="ial-tag ial-tag--section">Seção</span>
</div>

<div class="ial-session" markdown>
[Privacidade](07-privacy/index.md){ .ial-stretch }
<span class="ial-session__desc">Membership inference, inversão e extração de modelo</span>
<span class="ial-tag ial-tag--section">Seção</span>
</div>

</div>

<div class="ial-promo" markdown>
<span class="ial-promo__title">Pratique com modelos locais</span>
<span class="ial-promo__text">Um chatbot RAG vulnerável, com 4 níveis de defesa, rodando no Ollama. Sem chave de API paga.</span>
[Abrir o lab :octicons-arrow-right-24:](labs/vuln-chatbot-rag/index.md){ .md-button }
</div>

</div>

</div>

## Como cada técnica é organizada

<div class="ial-cycle">
  <span>Teoria</span><span>OWASP / ATLAS</span><span>Lab</span><span>Exploração</span><span class="ial-def">Detecção</span><span class="ial-def">Mitigação</span>
</div>

Todo ataque no IA-Lab segue o mesmo ciclo e **sempre termina na defesa**. Um achado de red team só tem valor se alguém conseguir corrigi-lo.

!!! warning "Apenas para fins educacionais e testes autorizados"
    Leia o [aviso](DISCLAIMER.md). Todo o conteúdo é original e baseado em fontes públicas.

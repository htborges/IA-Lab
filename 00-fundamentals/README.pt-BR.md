# Fundamentos de IA

> 🇧🇷 Português · 🇺🇸 [English](README.md)

Uma trilha didática para entender **como a IA funciona por dentro**, do zero até LLMs e agents, sempre com um olhar de segurança ofensiva. Não é preciso saber IA nem matemática avançada: cada aula explica o conceito com analogias e exemplos e termina mostrando **por que aquilo importa para um red teamer**.

> [!NOTE]
> **Sobre o conteúdo**
> Todo o material é original, escrito com base em fontes públicas (papers, documentação e livros). A ordem dos temas segue um caminho clássico de estudo de IA, útil para quem se prepara para certificações de AI red teaming, mas nenhum conteúdo de curso pago é reproduzido.

## Como cada aula funciona

| Parte | O que traz |
|-------|------------|
| **Conceito** | Explicação com analogias, diagramas e exemplos numéricos simples |
| **Visão do red teamer** | Como o conceito vira superfície de ataque |
| **Teste seu entendimento** | Perguntas com resposta escondida para fixar o conteúdo |

## Níveis e mapa

A trilha cresce em três níveis:

| Nível | O que é |
|-------|---------|
| **Base** | As aulas abaixo: a intuição e o "porquê" de cada tema |
| **Aprofundamento** | Aulas numeradas a partir da aula-base, como `11.1`, que vão a fundo num tema |
| **Prática ofensiva** | As técnicas das seções de ataque, cada uma indicando as aulas que pressupõe |

Cada aula mostra no cabeçalho o nível e os pré-requisitos, e termina com o bloco **Aprofunde e pratique**. Veja o **[Mapa da trilha](map.pt-BR.md)** para a ordem de leitura, os caminhos sugeridos e o registro de tudo o que já existe.

## Aulas

### Parte 1: Conceitos

| # | Aula | Status |
|---|------|--------|
| 01 | [O que é Inteligência Artificial](01-what-is-ai.pt-BR.md) | ✅ |
| 02 | [A história da IA](02-history-of-ai.pt-BR.md) | ✅ |
| 03 | [Como as máquinas aprendem](03-how-machines-learn.pt-BR.md) | ✅ |
| 03.1 | ↳ Aprofundamento: [Avaliação e regularização](03-1-evaluation-regularization.pt-BR.md) | ✅ |
| 04 | [Matemática essencial para IA](04-essential-math.pt-BR.md): vetores, matrizes, derivadas, probabilidade e normas | ✅ |
| 04.1 | ↳ Aprofundamento: [Logaritmos, exponenciais e entropia](04-1-logs-and-entropy.pt-BR.md) | ✅ |
| 04.2 | ↳ Aprofundamento: [Álgebra linear para ML](04-2-linear-algebra.pt-BR.md) | ✅ |

### Parte 2: Machine Learning clássico

| # | Aula | Status |
|---|------|--------|
| 05 | [Aprendizado supervisionado I](05-linear-logistic-regression.pt-BR.md): regressão linear e logística | ✅ |
| 05.1 | ↳ Aprofundamento: [Mínimos quadrados e pressupostos da regressão](05-1-least-squares.pt-BR.md) | ✅ |
| 06 | [Aprendizado supervisionado II](06-trees-naive-bayes-svm.pt-BR.md): árvores de decisão, Naive Bayes e SVM | ✅ |
| 06.1 | ↳ Aprofundamento: [Árvores de decisão a fundo](06-1-decision-trees-deep-dive.pt-BR.md) | ✅ |
| 06.2 | ↳ Aprofundamento: [SVM e Naive Bayes a fundo](06-2-svm-naive-bayes-deep-dive.pt-BR.md) | ✅ |
| 07 | [Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md): K-Means, PCA e detecção de anomalias | ✅ |
| 08 | [Aprendizado por reforço](08-reinforcement-learning.pt-BR.md): agentes, recompensas, Q-Learning e SARSA | ✅ |

### Parte 3: Deep Learning

| # | Aula | Status |
|---|------|--------|
| 09 | [Do perceptron às redes neurais](09-neural-networks.pt-BR.md) | ✅ |
| 09.1 | ↳ Aprofundamento: [Treinando redes neurais: perdas, otimizadores e hiperparâmetros](09-1-training-neural-networks.pt-BR.md) | ✅ |
| 10 | [Redes convolucionais (CNN) e recorrentes (RNN)](10-cnn-rnn.pt-BR.md) | ✅ |

### Parte 4: IA Generativa

| # | Aula | Status |
|---|------|--------|
| 11 | [IA generativa e LLMs](11-llms.pt-BR.md): tokens, embeddings, Transformers e atenção | ✅ |
| 11.1 | ↳ Aprofundamento: [Tokenização a fundo](11-1-tokenization-deep-dive.pt-BR.md) | ✅ |
| 12 | [Modelos de difusão](12-diffusion-models.pt-BR.md) | ✅ |
| 13 | [Sistemas de IA](13-ai-systems.pt-BR.md): RAG, agents, tools e MCP | ✅ |

---

Depois da trilha, siga para os [Frameworks](../01-frameworks/README.pt-BR.md) e para os ataques, começando por [Prompt Injection](../02-prompt-injection/README.pt-BR.md).

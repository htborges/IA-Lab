# AI Fundamentals

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

A learning track to understand **how AI works under the hood**, from zero to LLMs and agents, always through an offensive security lens. No prior AI or advanced math is needed: each lesson explains the concept with analogies and examples and ends by showing **why it matters to a red teamer**.

> [!NOTE]
> **About the content**
> All material is original, written from public sources (papers, documentation and books). The order of topics follows a classic AI study path, useful for anyone preparing for AI red teaming certifications, but no paid course content is reproduced.

## How each lesson works

| Part | What it brings |
|------|----------------|
| **Concept** | Explanation with analogies, diagrams and simple numeric examples |
| **Red teamer's view** | How the concept becomes attack surface |
| **Check your understanding** | Questions with hidden answers to lock in the content |

## Levels and map

The track grows in three levels:

| Level | What it is |
|-------|------------|
| **Foundation** | The lessons below: the intuition and the "why" of each topic |
| **Deep dive** | Lessons numbered after their foundation lesson, such as `11.1`, that go deep into one topic |
| **Offensive practice** | The techniques in the attack sections, each one listing the lessons it assumes |

Each lesson shows its level and prerequisites in the header, and ends with a **Go deeper and practice** block. See the **[Track map](map.md)** for reading order, suggested paths and a registry of everything that already exists.

## Lessons

### Part 1: Concepts

| # | Lesson | Status |
|---|--------|--------|
| 01 | [What is Artificial Intelligence](01-what-is-ai.md) | ✅ |
| 02 | [The history of AI](02-history-of-ai.md) | ✅ |
| 03 | [How machines learn](03-how-machines-learn.md) | ✅ |
| 04 | [Essential math for AI](04-essential-math.md): vectors, matrices, derivatives, probability and norms | ✅ |
| 04.1 | ↳ Deep dive: [Logarithms, exponentials and entropy](04-1-logs-and-entropy.md) | ✅ |

### Part 2: Classic Machine Learning

| # | Lesson | Status |
|---|--------|--------|
| 05 | [Supervised learning I](05-linear-logistic-regression.md): linear and logistic regression | ✅ |
| 06 | [Supervised learning II](06-trees-naive-bayes-svm.md): decision trees, Naive Bayes and SVM | ✅ |
| 06.1 | ↳ Deep dive: [Decision trees in depth](06-1-decision-trees-deep-dive.md) | ✅ |
| 07 | [Unsupervised learning](07-unsupervised-learning.md): K-Means, PCA and anomaly detection | ✅ |
| 08 | [Reinforcement learning](08-reinforcement-learning.md): agents, rewards, Q-Learning and SARSA | ✅ |

### Part 3: Deep Learning

| # | Lesson | Status |
|---|--------|--------|
| 09 | [From the perceptron to neural networks](09-neural-networks.md) | ✅ |
| 09.1 | ↳ Deep dive: [Training neural networks: losses, optimizers and hyperparameters](09-1-training-neural-networks.md) | ✅ |
| 10 | [Convolutional (CNN) and recurrent (RNN) networks](10-cnn-rnn.md) | ✅ |

### Part 4: Generative AI

| # | Lesson | Status |
|---|--------|--------|
| 11 | [Generative AI and LLMs](11-llms.md): tokens, embeddings, Transformers and attention | ✅ |
| 12 | [Diffusion models](12-diffusion-models.md) | ✅ |
| 13 | [AI systems](13-ai-systems.md): RAG, agents, tools and MCP | ✅ |

---

After the track, move on to the [Frameworks](../01-frameworks/README.md) and to the attacks, starting with [Prompt Injection](../02-prompt-injection/README.md).

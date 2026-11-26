# 02 · The history of AI

> 🇺🇸 English · 🇧🇷 [Português](02-history-of-ai.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Lesson 2 of 13 |
| **Level** | Foundation |
| **Prerequisites** | [01 · What is AI](01-what-is-ai.md) |
| **Reading time** | ~15 min |
| **You will learn** | How AI went from a philosophical idea to LLMs, why it went through "winters", and how the history of AI **security** evolved alongside it |

## Why study the history?

Because today's AI is the sum of decades-old ideas that only worked once three ingredients came together: **algorithms**, **data** and **compute**. Knowing this path helps you separate real progress from hype, and shows that many "new" AI attacks have old roots.

| Era | Period | In one sentence |
|-----|--------|-----------------|
| Foundations | 1943–1956 | The artificial neuron, the Turing Test and the name "AI" |
| Early optimism | 1956–1974 | Perceptron, ELIZA and promises far too big |
| 1st winter | 1974–1980 | Broken promises, funding cut |
| Expert systems | 1980–1987 | Thousands of hand-written rules |
| 2nd winter | 1987–1993 | Expensive, brittle systems; the market collapses |
| Statistical ML | 1993–2011 | Learning from data: SVMs, trees, LeNet |
| Deep learning revolution | 2012–2016 | GPUs + data: AlexNet, GANs, AlphaGo |
| Transformers and generative AI | 2017–today | Transformer, GPT, ChatGPT, agents |

## 1. Foundations (1943–1956)

- **1943:** Warren McCulloch and Walter Pitts propose a mathematical model of the **neuron**: it receives signals, sums them and "fires" if a threshold is crossed. It is the ancestor of every neural network.
- **1950:** Alan Turing publishes *Computing Machinery and Intelligence* and replaces the question "can machines think?" with a practical test, the **Imitation Game** (today called the Turing Test): if an evaluator cannot tell the machine from a human in a conversation, the machine "passes".
- **1956:** the **Dartmouth** workshop, organized by John McCarthy, Marvin Minsky, Claude Shannon and Nathaniel Rochester, names the field **"Artificial Intelligence"**. The proposal was optimistic: solve much of the problem in one summer.

## 2. Early optimism (1956–1974)

- **1958:** Frank Rosenblatt builds the **Perceptron**, a machine that *learned* to classify patterns by adjusting its weights. The press promised machines that would soon walk, talk and be conscious.
- **1966:** Joseph Weizenbaum creates **ELIZA**, a chatbot that imitated a therapist using only word-substitution rules. Many users became emotionally attached and believed it understood them. It is the first record of humans **over-trusting** a conversational AI, a problem that is still current.
- **1969:** Minsky and Papert publish *Perceptrons*, showing that a simple perceptron cannot solve problems like **XOR**. Interest in neural networks collapses.

## 3. The AI winters

An **AI winter** is a period when promises fail, funding dries up and the field loses credibility.

| Winter | Main cause |
|--------|------------|
| **1st (≈1974–1980)** | Overblown promises, weak computers, criticism such as the Lighthill report (UK, 1973) |
| **2nd (≈1987–1993)** | Expert systems were expensive, brittle and hard to maintain, and the dedicated hardware market collapsed |

Between the two winters, in the 1980s, **expert systems** were a success: thousands of "IF… THEN…" rules written by human experts (XCON, for example, configured DEC computers). They worked well in narrow domains, but did not learn and broke on any unforeseen situation.

> [!NOTE]
> **A hidden gem in the 2nd winter**
> In 1986, Rumelhart, Hinton and Williams popularize **backpropagation**, the algorithm that makes it possible to train multi-layer neural networks. It solved the XOR problem, but data and compute were still missing to show its full potential.

## 4. The statistical turn (1993–2011)

The field swaps hand-written rules for **learning from data**:

- **1997:** IBM's Deep Blue beats world chess champion Garry Kasparov (still with search and rules, not learning).
- **1998:** Yann LeCun presents **LeNet-5**, a convolutional network that read handwritten digits on checks.
- **2000s:** algorithms like SVMs, decision trees and random forests dominate industry. The internet starts producing **data at scale**.
- **2006:** Geoffrey Hinton and colleagues show ways to train deep networks, and the term **deep learning** takes off.

## 5. The deep learning revolution (2012–2016)

- **2012:** **AlexNet** wins the ImageNet image recognition competition by a huge margin, trained on **GPUs**. It is considered the "big bang" of modern deep learning.
- **2014:** Ian Goodfellow proposes **GANs**, networks that generate realistic images.
- **2016:** DeepMind's **AlphaGo** beats Lee Sedol at Go, a game considered too hard for machines.

## 6. Transformers and generative AI (2017–today)

- **2017:** the paper ***Attention Is All You Need*** (Google) introduces the **Transformer**, the architecture behind virtually every current LLM.
- **2018–2020:** BERT, GPT-2 and **GPT-3** show that bigger models trained on more text gain new abilities.
- **2020–2022:** **diffusion models** revolutionize image generation (DALL·E 2, Stable Diffusion, Midjourney).
- **Nov 2022:** **ChatGPT** launches and reaches 100 million users in about two months. Generative AI becomes everyone's topic.
- **2023 onward:** open-weight models (Llama, Mistral, Qwen), multimodal models, **agents** that use tools, and protocols like **MCP** to connect LLMs to external systems.

## The parallel story: AI security

As AI evolved, research on **how to attack it** evolved too. These milestones are the foundation of what you will practice in this repository:

| Year | Milestone | Why it matters |
|------|-----------|----------------|
| **2004** | *Adversarial Classification* (Dalvi et al.): spammers adapting messages to fool filters | First formal studies of ML model **evasion** |
| **2013–14** | Szegedy et al. discover **adversarial examples**: invisible noise that makes a network fail with high confidence. Goodfellow creates FGSM | Birth of modern **adversarial ML** |
| **2016** | Microsoft's **Tay** chatbot is manipulated by users and starts posting offensive content in under 24 hours | Public case of **poisoning** through learning from users |
| **2017** | **BadNets** (Gu et al.) shows backdoors hidden in neural networks | Foundation of **backdoor** and supply chain attacks |
| **2022** | The term **prompt injection** is coined shortly before ChatGPT's launch | The #1 vulnerability class of LLMs |
| **2023** | **OWASP Top 10 for LLM Applications** is released. MITRE ATLAS adds LLM techniques | Industry starts treating AI security as its own discipline |

> [!TIP]
> **Red teamer's view**
> Notice the pattern: **every leap in capability brought a new attack surface.** Classifiers brought evasion, learning from users brought poisoning, LLMs brought prompt injection and agents brought tool abuse. When the next technology arrives, the first question is: *what does it now accept as input, and what can it now do?*

## Lessons from history

1. **Old ideas, recent success.** The artificial neuron is from 1943 and backpropagation from 1986. What changed was the scale of **data** and **compute** (GPUs).
2. **Hype and winter go together.** Overblown promises have already sunk the field twice. Healthy skepticism is part of the job.
3. **Over-trust is an old risk.** From ELIZA to LLMs, people tend to attribute understanding and authority to machines that talk well.

## Check your understanding

<details><summary>1. Which three ingredients explain the recent success of AI?</summary>

Algorithms (such as backpropagation and Transformers), large volumes of data (the internet) and compute (mainly GPUs).
</details>

<details><summary>2. What was the Tay incident and which attack class does it illustrate?</summary>

In 2016, Microsoft launched Tay, a chatbot that learned from interactions. Coordinated users fed it offensive content and within a day it started repeating it. It is an example of **data poisoning** in a system that learns from untrusted input.
</details>

<details><summary>3. Why was the discovery of adversarial examples (2013–14) so important?</summary>

It showed that neural networks with excellent performance can be fooled by tiny perturbations, sometimes invisible to humans. In other words, high accuracy does not mean robustness, and that gave rise to the modern ML security field.
</details>

---

← [01 · What is AI](01-what-is-ai.md) · **Next lesson:** [03 · How machines learn](03-how-machines-learn.md) →

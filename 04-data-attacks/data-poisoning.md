# Data Poisoning

> 🇺🇸 English · 🇧🇷 [Português](data-poisoning.pt-BR.md)

| Field | Value |
|-------|-------|
| **Category** | Data |
| **OWASP LLM Top 10** | LLM04:2025 Data and Model Poisoning |
| **MITRE ATLAS** | AML.T0020 Poison Training Data |
| **Target** | Any model trained or retrained on data the attacker can influence: classifiers, anomaly detectors, LLMs (pre-training, fine-tuning, feedback) |
| **Attacker access** | Write access to some training data source. No model access needed |
| **Severity** | Medium to Critical (depends on what the model decides and how long the poisoning goes unnoticed) |
| **Lab** | Numeric example and code on this page |

## TL;DR

The attacker inserts or alters training examples to change what the model learns: make the model worse overall, or make it fail **on a specific case** the attacker cares about. The resulting model looks normal and passes its metrics, because evaluation data usually comes from the same poisoned source.

## Concept

### Attacker goals

| Goal | What happens | Example |
|------|--------------|---------|
| **Availability** | Model quality drops for everyone | A spam filter starts failing so often that it gets turned off |
| **Targeted integrity** | The model stays good, but fails on **chosen inputs** | The attacker's malware family starts being classified as benign |
| **Backdoor** | The model fails only when the input has a **trigger** | Has its own page: [model backdoors](model-backdoors.md) |

### Methods

| Method | How it works |
|--------|--------------|
| **Label flipping** | Change the label of existing examples (mark malware as benign) |
| **Example injection** | Add new examples, with the label the attacker wants, near the region they want to change |
| **Clean-label** | Examples with the **correct** label, but with features crafted to shift the boundary. They pass human label review |
| **Gradual poisoning** | Small doses at each retraining, to shift "normal" slowly ([lesson 07](../00-fundamentals/07-unsupervised-learning.md)) |

### Where the attacker writes

- **User feedback**: "spam / not spam" buttons, corrections, answer ratings used for retraining.
- **Public data and scraping**: web pages, wikis, code repositories, forums. Research has shown that poisoning web-scale datasets is feasible, for example by buying expired domains that are still listed in a dataset's URL lists.
- **Outsourced labeling**: crowdsourcing platforms or labeling vendors.
- **LLM fine-tuning**: instruction and preference datasets shared on public hubs. A 2025 study indicated that a few hundred malicious documents were enough to implant a behavior in LLMs of several sizes: what matters is the **absolute number** of examples, not the share of the dataset.
- **RAG knowledge bases**: they do not change the weights, but the effect is similar at inference time ([indirect injection](../02-prompt-injection/indirect-prompt-injection.md)).

## Attack Surface and Prerequisites

- The system trains or retrains on data the attacker can influence
- There is no traceability of each example's origin and no review before training
- Evaluation uses data from the same source, not a separate trusted set

## Exploitation

### An example with numbers

A detector classifies files by a suspicion score, using the simplest possible method: it computes the **mean** of each class and puts the threshold in the middle.

| Class | Training scores | Mean |
|-------|-----------------|------|
| Benign | 1, 2, 3, 4 | 2.5 |
| Malicious | 7, 8, 9, 10 | 8.5 |

```text
threshold = (2.5 + 8.5) / 2 = 5.5   → above 5.5 is malicious
```

The attacker's malware scores **7**: detected. They can submit samples through the "false positive" channel customers use to report mistakes, and they report **4 files scoring 10** as benign:

| Class | Training scores | Mean |
|-------|-----------------|------|
| Benign (poisoned) | 1, 2, 3, 4, 10, 10, 10, 10 | 6.25 |
| Malicious | 7, 8, 9, 10 | 8.5 |

```text
new threshold = (6.25 + 8.5) / 2 = 7.375   → the malware scoring 7 now passes
```

Four examples were enough. The detector still catches malware scoring 8, 9 and 10, so overall metrics barely change, and nobody notices that **that** malware is now let through.

### The same effect in code

```python
import numpy as np

def train(benign, malicious):
    return (np.mean(benign) + np.mean(malicious)) / 2

benign, malicious = [1, 2, 3, 4], [7, 8, 9, 10]
print(train(benign, malicious))                      # 5.5
print(train(benign + [10] * 4, malicious))           # 7.375

target = 7
for threshold in (5.5, 7.375):
    print(threshold, "detected" if target > threshold else "let through")
# 5.5 detected
# 7.375 let through
```

In a real model (logistic regression, trees, networks), the mechanism is the same, with more dimensions: the poisoned points pull the decision boundary ([lessons 05](../00-fundamentals/05-linear-logistic-regression.md) and [06](../00-fundamentals/06-trees-naive-bayes-svm.md)).

### In an authorized test

1. Map the **write paths** into training data and the retraining frequency.
2. Agree with the client on a **harmless, verifiable goal** (for example, a specific test sample that should become misclassified).
3. Inject the **minimum** number of examples through the real path and measure after retraining, in a staging environment.
4. Report how many examples were needed and whether any control (review, outlier detection) noticed.

## Variations

- **Preference poisoning (RLHF)**: fake ratings teach the model to prefer answers with a certain bias.
- **Embedding poisoning**: documents that distort the vector space of a search system.
- **Code poisoning**: public repositories with insecure patterns that code models learn to suggest.
- **Poisoning unsupervised detectors**: the "boiling frog" from [lesson 07](../00-fundamentals/07-unsupervised-learning.md).

## Detection

- **Provenance**: knowing where each example came from (source, date, user) makes it possible to isolate and remove suspicious batches.
- **Outlier detection on training data**: examples far from the rest of their own class (like the "benign" ones scoring 10).
- **Label consistency**: compare each example's label with what a model trained on trusted data predicts.
- **A trusted, separate evaluation set**, never fed by the same channels as training.
- **Per-class and per-segment monitoring**: localized drops in recall, not just the overall metric.
- **Diff between dataset versions** before each retraining.

## Mitigation

| Control | Layer | Effectiveness |
|---------|-------|---------------|
| Data provenance and versioning (hashed snapshots) | Data | High |
| Review and limits for user-sourced data (rate, reputation, human sampling) | Data | High |
| Trusted evaluation set and regression tests with critical cases | Evaluation | High |
| Sanitization: removing outliers and examples with inconsistent labels | Data | Medium |
| Robust training techniques (for example, limiting each example's influence) | Training | Medium |
| Retraining with approval and the ability to roll back | Process | Medium |

## References

- [OWASP LLM04:2025 Data and Model Poisoning](https://genai.owasp.org/llmrisk/llm042025-data-and-model-poisoning/)
- [MITRE ATLAS AML.T0020](https://atlas.mitre.org/techniques/AML.T0020)
- Biggio, Nelson & Laskov, *Poisoning Attacks against Support Vector Machines* (2012)
- Carlini et al., *Poisoning Web-Scale Training Datasets is Practical* (2023)
- Souly et al., *Poisoning Attacks on LLMs Require a Near-constant Number of Poison Samples* (2025)

> OWASP and MITRE ATLAS IDs change between versions. Check the official pages before citing them in a report.

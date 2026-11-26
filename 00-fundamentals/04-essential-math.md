# 04 · Essential math for AI

> 🇺🇸 English · 🇧🇷 [Português](04-essential-math.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Lesson 4 of 13 |
| **Level** | Foundation |
| **Prerequisites** | [03 · How machines learn](03-how-machines-learn.md) |
| **Reading time** | ~25 min |
| **You will learn** | The intuition behind vectors, matrices, derivatives, probability and norms, and where each one shows up in attacks on AI |

> [!NOTE]
> **Don't panic**
> This lesson has no proofs and no complicated formulas. The goal is for you to **recognize** each concept when it appears in a paper, a tool or an attack. Every calculation can be done on a calculator, and there is a Python block at the end so you can check them.

## Why math?

An AI model is, literally, **a huge mathematical function**. Everything it receives (text, images, audio) becomes numbers, and everything it does is operate on those numbers. Five ideas cover almost everything:

| Concept | What it does in AI | Where it shows up in attacks |
|---------|--------------------|------------------------------|
| **Vectors** | Represent data and meaning | Embeddings, RAG, similarity search |
| **Matrices** | Transform data layer by layer | The model's weights, which is what gets stolen or poisoned |
| **Derivatives and gradients** | Training (adjusting weights) | Adversarial examples |
| **Probability** | Express confidence and uncertainty | Model confidence, false positives, membership inference |
| **Norms (distances)** | Measure "how much changed" | An attack's perturbation budget |

## 1. Vectors: data becomes lists of numbers

A **vector** is an ordered list of numbers. The apartment from the previous lesson becomes:

```text
apartment = [50, 2, 3]      # area (m²), bedrooms, floor
```

Each position is a **dimension**. This vector has 3 dimensions. A 28×28 grayscale image becomes a vector of 784 numbers (one per pixel). In an LLM, each word (or piece of a word) becomes a vector with hundreds or thousands of dimensions.

### Embeddings: meaning as position

An **embedding** is a vector that represents the **meaning** of something. The model learns to place similar things close together. A simplified 3-dimensional example:

```text
cat = [0.9, 0.8, 0.1]
dog = [0.8, 0.9, 0.2]
car = [0.1, 0.2, 0.9]
```

"cat" and "dog" point to the same region, and "car" points elsewhere. How do we measure that?

### Dot product and cosine similarity

The **dot product** multiplies position by position and adds up:

```text
[1, 2, 3] · [4, 5, 6] = 1×4 + 2×5 + 3×6 = 4 + 10 + 18 = 32
```

**Cosine similarity** uses the dot product to measure the **angle** between two vectors. The result goes from -1 (opposite) to 1 (same direction):

```text
similarity(cat, dog) ≈ 0.99   → very close meanings
similarity(cat, car) ≈ 0.30   → barely related
```

> [!TIP]
> **Red teamer's view**
> This is how a **RAG** system decides which documents to hand the LLM: it turns your question into an embedding and fetches the documents with the highest similarity. If an attacker writes a document whose embedding sits **very close** to the most common questions, that document will be retrieved often, carrying a hidden prompt injection with it. That is **RAG poisoning** ([section 05](../05-app-and-system/README.md)).

## 2. Matrices: transforming data

A **matrix** is a table of numbers (rows × columns). In AI, the most important operation is **multiplying a matrix by a vector**: each row of the matrix takes a dot product with the vector.

```text
W = | 0.2  0.5  0.1 |      x = [1, 0, 2]
    | 0.4  0.1  0.3 |

W × x = [0.2×1 + 0.5×0 + 0.1×2,  0.4×1 + 0.1×0 + 0.3×2]
      = [0.4, 1.0]
```

The 3-number vector became a 2-number vector. That is essentially **one neural network layer**: the matrix `W` holds the **weights**, and each layer turns the data's representation into a new one. An LLM is a stack of dozens of such layers, with gigantic matrices.

> [!TIP]
> **Red teamer's view**
> When people talk about "stealing a model" or "open weights", they mean these matrices. Whoever has the weights has the whole model: they can run it, study it and compute gradients freely (a **white-box** attack). That is why weight files are valuable assets and an attack vector ([section 04](../04-data-attacks/README.md)).

## 3. Derivatives and gradients: the direction of change

A **derivative** answers: *"if I nudge the input a little, how much and in which direction does the output change?"* It is the **slope** of the function at that point.

Example with `f(x) = x²`:

| x | f(x) | Slope (derivative = 2x) | Reading |
|---|------|-------------------------|---------|
| 3 | 9 | 6 | Rising steeply to the right |
| 0 | 0 | 0 | Bottom of the valley (minimum) |
| -2 | 4 | -4 | Rising to the left |

When the function has many inputs (a model has millions of weights), we collect all the derivatives into a vector called the **gradient**. It points in the direction where the function **grows the most**.

### Gradient descent with numbers

Remember the "mountain in the fog"? To **minimize** `f(x) = x²` starting at `x = 3`, with learning rate `0.1`:

```text
step 1: slope = 6     → x = 3   − 0.1 × 6   = 2.4    → f = 5.76
step 2: slope = 4.8   → x = 2.4 − 0.1 × 4.8 = 1.92   → f ≈ 3.69
...                      x approaches 0, the minimum
```

Training a model is exactly this, except `x` is millions of weights and `f` is the loss function.

### The chain rule: how the error flows back through layers

Think of gears: if A spins 2× faster than B, and B spins 3× faster than C, then A spins 2 × 3 = **6×** faster than C. The **chain rule** does this with derivatives: it multiplies the slopes of each stage.

**Backpropagation** is the chain rule applied layer by layer, from back to front: it computes how much each weight contributed to the final error.

> [!TIP]
> **Red teamer's view**
> The gradient can be computed with respect to the **weights** (to train) or with respect to the **input** (to attack). In the second case, it tells you exactly which pixels or values to change to **increase the model's error**. The FGSM attack does this in a single step: it adds a small noise to the image in the direction of the gradient. It is the basis of [section 06](../06-evasion/README.md).

## 4. Probability: confidence and uncertainty

Models rarely say "it is X". They say "it is X with 87% probability".

### Softmax: from scores to probabilities

A classifier's last layer produces raw **scores** (called *logits*). The **softmax** function turns them into probabilities that add up to 1:

```text
logits:          cat = 2.0    dog = 1.0    bird = 0.1
exponential:           7.389        2.718         1.105     (sum = 11.212)
probabilities:         0.659        0.242         0.099
```

Result: **66% cat**, 24% dog, 10% bird. LLMs do the same at every step, but with tens of thousands of options: one probability for each possible token.

> [!WARNING]
> **Confidence is not correctness**
> A model can give 99% probability to a **wrong** answer. Adversarial examples often produce exactly that: errors with very high confidence. And if the full probabilities are exposed by the API, they help an attacker extract the model or uncover training data.

### Mean, variance and normalization

- **Mean:** the typical value. **Variance / standard deviation:** how spread out the values are.
- Before training, data is usually **normalized** (`z = (x − mean) / std`) so that no feature dominates the others just because it has bigger numbers (area in m² vs number of bedrooms, for example).

### The base rate trap

This example matters a lot to anyone working with detection:

> An intrusion detector catches **99%** of attacks and only raises a false alarm on **1%** of normal traffic. On a network with **100,000 events**, only **100** are attacks.

```text
Real attacks:  100     → the detector alerts on 99
Normal events: 99,900  → 1% false alarms = 999 alerts
Total alerts:            99 + 999 = 1,098

Chance that an alert is a real attack: 99 / 1,098 ≈ 9%
```

A "99% accurate" detector raises alerts that are **false 91% of the time**. That is the reasoning behind **Bayes' theorem**: the final probability depends heavily on how rare the event is. It comes back in the Naive Bayes lesson.

## 5. Norms: measuring distances and perturbations

A **norm** measures the "size" of a vector, and therefore the **distance** between two vectors. In AI security, it measures **how much an attacker changed the input**. The three most common:

| Norm | What it measures | In a modified image |
|------|------------------|---------------------|
| **L2** (Euclidean) | Straight-line distance | The total "energy" of the change, across all pixels |
| **L∞** (infinity) | The **largest** single change | No pixel changed by more than ε |
| **L0** | **How many** positions changed | Only a few pixels were modified (sparse attacks) |

For example, for the change `[0, 0.03, -0.02, 0]`:

```text
L0 = 2           (two positions changed)
L∞ = 0.03        (the largest change)
L2 = √(0.03² + 0.02²) ≈ 0.036
```

> [!TIP]
> **Red teamer's view**
> Adversarial ML papers and tools (ART, Foolbox) always define the attack as **"fool the model while changing the input by at most ε in a given norm"**. A classic value for images is L∞ with **ε = 8/255**: no pixel changes by more than 8 levels out of 255, a difference invisible to the human eye. L0 (sparse) attacks change very few pixels, but strongly.

## In practice (Python)

If you want to check this lesson's calculations (requires `pip install numpy`):

```python
import numpy as np

# 1. Cosine similarity
cat, dog, car = np.array([0.9, 0.8, 0.1]), np.array([0.8, 0.9, 0.2]), np.array([0.1, 0.2, 0.9])
cos = lambda a, b: a @ b / (np.linalg.norm(a) * np.linalg.norm(b))
print(round(cos(cat, dog), 2), round(cos(cat, car), 2))            # 0.99 0.3

# 2. A "layer": matrix × vector
W = np.array([[0.2, 0.5, 0.1], [0.4, 0.1, 0.3]])
print(W @ np.array([1, 0, 2]))                                       # [0.4 1. ]

# 3. Gradient descent on f(x) = x²
x = 3.0
for _ in range(3):
    x -= 0.1 * 2 * x
    print(round(x, 3))                                               # 2.4, 1.92, 1.536

# 4. Softmax
logits = np.array([2.0, 1.0, 0.1])
print(np.round(np.exp(logits) / np.exp(logits).sum(), 3))           # [0.659 0.242 0.099]

# 5. Norms of a perturbation
d = np.array([0, 0.03, -0.02, 0])
print(np.count_nonzero(d), np.abs(d).max(), round(np.linalg.norm(d), 3))  # 2 0.03 0.036
```

## Summary

- **Vectors** represent data and meaning. **Cosine similarity** measures how alike two meanings are and is the basis of RAG search.
- **Matrices** are the model's weights, and each layer is a matrix × vector multiplication.
- **Derivatives and gradients** show the direction of change: used to train (adjusting weights) and to attack (adjusting the input).
- **Probability** expresses confidence, but high confidence is not correctness, and the base rate fools detectors.
- **Norms** measure the size of a perturbation and define an adversarial attack's "budget".

## Check your understanding

<details><summary>1. Why can two texts with different words be considered "similar" by a RAG system?</summary>

Because the comparison is not made on the words but on the **embeddings**. Texts with similar meaning sit close together in vector space and have high cosine similarity, even with different words.
</details>

<details><summary>2. What is the difference between taking the gradient with respect to the weights and with respect to the input?</summary>

With respect to the **weights**, the gradient shows how to adjust the model to decrease the error (training). With respect to the **input**, it shows how to change the data to increase the error (adversarial attack).
</details>

<details><summary>3. A malware classifier has 99% accuracy and 0.5% false positives. In an environment with 1 malware per 10,000 files, will the alerts be reliable?</summary>

Not really. In 10,000 files: 1 malware (≈1 true alert) and 9,999 clean × 0.5% ≈ 50 false alerts. Only about **1 in 51 alerts** (≈2%) would be real malware. That is the base rate trap.
</details>

<details><summary>4. An attack changes only 5 pixels of an image, but strongly. Which norm best describes it?</summary>

**L0**, which counts how many positions changed. It is a **sparse** attack.
</details>

## Go deeper and practice

Deep dives that build on this lesson:

- **Deep dive:** [04.1 · Logarithms, exponentials and entropy](04-1-logs-and-entropy.md)
- **Deep dive:** [04.2 · Linear algebra for ML](04-2-linear-algebra.md)

---

← [03 · How machines learn](03-how-machines-learn.md) · **Next lesson:** [05 · Supervised learning I: linear and logistic regression](05-linear-logistic-regression.md) →

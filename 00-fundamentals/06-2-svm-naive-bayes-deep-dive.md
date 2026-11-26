# 06.2 · SVM and Naive Bayes in depth

> 🇺🇸 English · 🇧🇷 [Português](06-2-svm-naive-bayes-deep-dive.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [06 · Trees, Naive Bayes and SVM](06-trees-naive-bayes-svm.md) |
| **Level** | Deep dive |
| **Prerequisites** | [06 · Trees, Naive Bayes and SVM](06-trees-naive-bayes-svm.md), [04.1 · Logs and entropy](04-1-logs-and-entropy.md), [04.2 · Linear algebra](04-2-linear-algebra.md) |
| **Reading time** | ~30 min |
| **You will learn** | How the SVM computes the margin, what soft margin, hinge loss and the C parameter are, how polynomial and RBF kernels work (and γ), the variants of Naive Bayes, why Laplace smoothing exists, and how each detail becomes an attack |

## Where we left off

In [lesson 06](06-trees-naive-bayes-svm.md), the SVM was introduced as "the widest road between two neighborhoods", and the kernel trick separated points that no line could. Naive Bayes filtered spam with 95.4% certainty and dropped to 8.7% with three "good" words. Now for the math: what the SVM optimizes, what the hyperparameters do, which versions of Naive Bayes exist and why an implementation detail, smoothing, decides whether a single word can **veto** detection.

## SVM: the margin in numbers

A linear SVM's boundary is the hyperplane `w · x + b = 0`. Each class's points sit on the `w · x + b ≥ 1` and `w · x + b ≤ −1` sides, and the distance between those two "road edges" is:

```text
margin = 2 / ‖w‖
```

**Maximizing the margin means minimizing ‖w‖** (the norm from [lesson 04](04-essential-math.md)): smaller weights, wider road.

### A one-dimensional example

Files with a suspicion score: legitimate at 1 and 2, malicious at 4 and 5. The points closest to the other class are 2 and 4, the **support vectors**:

```text
w × 4 + b = +1      w × 2 + b = −1      →   w = 1,  b = −3
boundary: x = 3        margin = 2 / 1 = 2   (exactly the distance between 2 and 4)
```

Points 1 and 5 do not show up in the computation: they could be anywhere beyond the margin, and the boundary would be the same.

### Soft margin: hinge loss and the C parameter

Real data has noise: a malicious point in the middle of legitimate ones makes perfect separation impossible. The **soft margin** SVM accepts violations, but charges for them with the **hinge loss**:

```text
hinge = max(0, 1 − y × (w · x + b))       (y = +1 malicious, −1 legitimate)
```

With the boundary above (w = 1, b = −3):

| Point | Class | y × (w·x + b) | Hinge | Situation |
|-------|-------|---------------|-------|-----------|
| x = 2 | legitimate | 1.0 | **0** | On the right edge of the margin |
| x = 2.5 | legitimate | 0.5 | **0.5** | On the right side, but inside the margin |
| x = 4 | malicious | 1.0 | **0** | On the right edge of the margin |
| x = 3.5 | malicious | 0.5 | **0.5** | Inside the margin |
| x = 1.5 | malicious | −1.5 | **2.5** | On the wrong side: classified as legitimate |

The SVM's objective balances the two:

```text
minimize   ½ ‖w‖²  +  C × Σ hinge
           (wide margin)  (few violations)
```

| C | Behavior |
|---|----------|
| **Small** | Prioritizes a wide margin and tolerates mistakes: more regularization, less overfitting |
| **Large** | Punishes every violation and bends the boundary to get every training point right, noise included |

It plays the same role as λ in [03.1](03-1-evaluation-regularization.md), only inverted: here, a larger C means **less** regularization.

## Kernels: a dot product in another space

The SVM only uses the data through **dot products** between points. A kernel is a function that returns the dot product in a transformed space, **without building that space**.

### The polynomial kernel, checked by hand

The kernel `K(x, z) = (x · z + 1)²` for x = (1, 2) and z = (3, 1):

```text
x · z = 1×3 + 2×1 = 5        K(x, z) = (5 + 1)² = 36
```

The same number comes out if we explicitly map each point into 6 dimensions, `φ(x) = (x₁², x₂², √2·x₁x₂, √2·x₁, √2·x₂, 1)`, and take the dot product:

```text
φ(x) = (1, 4, 2√2, √2, 2√2, 1)
φ(z) = (9, 1, 3√2, 3√2, √2, 1)
φ(x) · φ(z) = 9 + 4 + 12 + 6 + 4 + 1 = 36
```

The kernel did in one step what would require building 6 features. With higher degrees or more features, the explicit space explodes, and the kernel stays cheap.

### The RBF kernel and γ

The most widely used kernel is the **RBF** (Gaussian), which measures **similarity by proximity**:

```text
K(x, z) = e^(−γ × ‖x − z‖²)
```

| Distance between the points | γ = 1 | γ = 0.1 |
|-----------------------------|-------|---------|
| 0 | 1.000 | 1.000 |
| 1 | 0.368 | 0.905 |
| 2 | 0.018 | 0.670 |

| γ | Each training point influences… | Risk |
|---|---------------------------------|------|
| **High** | Only its immediate neighborhood: the boundary wraps around each point, forming "islands" | Overfitting, memorization |
| **Low** | A wide region: smooth boundary | Underfitting |

C and γ are the two hyperparameters of an RBF SVM and are chosen together through cross-validation ([03.1](03-1-evaluation-regularization.md)).

## Naive Bayes: the variants

The idea is always the same as in lesson 06 (Bayes' theorem with independent features). What changes is **how** each feature's probability is computed:

| Variant | Features | How it models them | Typical use |
|---------|----------|--------------------|-------------|
| **Multinomial** | Counts (how many times each word appears) | Each word's relative frequency in the class | Text classification, spam |
| **Bernoulli** | Presence or absence (0/1) | Probability that the word appears; **absence** also counts as evidence | Short texts, binary features |
| **Gaussian** | Continuous numbers | A normal curve (mean and deviation) per feature and per class | Attachment size, number of links, network metrics |

### Gaussian Naive Bayes

A continuous feature, **attachment size** (MB): in training, spam has mean 2 and deviation 1; legitimate has mean 5 and deviation 2. For a 3 MB attachment, each class's "probability" comes from the height of the normal curve at that point:

| Class | Density at x = 3 |
|-------|------------------|
| Spam (mean 2, deviation 1) | 0.242 |
| Legitimate (mean 5, deviation 2) | 0.121 |

With lesson 06's priors (30% spam, 70% legitimate): `P(spam | 3 MB) = 0.3 × 0.242 / (0.3 × 0.242 + 0.7 × 0.121) ≈ 0.46`. If the attachment is 6 MB, the spam density drops to 0.0001 and legitimate takes over.

### Laplace smoothing and the one-word veto

In training, the word "meeting" showed up in **0 of 100** spams. Without smoothing, `P(meeting | spam) = 0`, and since Naive Bayes **multiplies** the probabilities:

```text
spam score = 0.3 × 0.6 × 0.4 × 0 = 0     →   P(spam) = 0
```

**A single word zeroes everything**, no matter how much spam evidence the email has. **Laplace smoothing** adds 1 to every count:

```text
P(meeting | spam)       = (0 + 1) / (100 + 2) = 0.0098
P(meeting | legitimate) = (30 + 1) / (100 + 2) = 0.304
```

With smoothing, the "free + password + meeting" email ends up at **P(spam) ≈ 0.40**: the word still weighs in, but it no longer has veto power. In practice, implementations also work with **sums of log-probabilities** ([04.1](04-1-logs-and-entropy.md)), because of underflow.

> [!TIP]
> **Red teamer's view**
> 1. **Look for the veto.** In a Naive Bayes without smoothing (or with minimal smoothing), a single word that never appeared in spam is enough to zero out detection. Test rare words typical of legitimate email; it is the extreme form of lesson 06's *good word attack*.
> 2. **Large C and high γ make the SVM poisonable.** An SVM that chases every training point bends to accommodate a few examples planted near the margin ([data poisoning](../04-data-attacks/data-poisoning.md)). And an RBF with high γ forms "islands" around the training points, leaving valleys between them through which an input can evade.
> 3. **Support vectors are training data.** A saved SVM model stores the support vectors, which are **real training examples**. Stealing the model file leaks part of the dataset, along with anything sensitive in it ([model files](../04-data-attacks/malicious-model-files.md), privacy section).
> 4. **Gaussian Naive Bayes has predictable boundaries.** Knowing the means and deviations, the attacker knows exactly which range to move a continuous feature into so the other class dominates, like taking the attachment from 3 MB to 6 MB.

## Hands-on with Python

```python
import numpy as np

# Margin and hinge loss with w = 1, b = -3
w, b = 1.0, -3.0
print(2 / abs(w))                                   # 2.0
for x, y in [(2, -1), (2.5, -1), (3.5, 1), (1.5, 1)]:
    print(x, max(0.0, 1 - y * (w * x + b)))        # 0.0, 0.5, 0.5, 2.5

# Polynomial kernel = dot product in the expanded space
x, z = np.array([1.0, 2.0]), np.array([3.0, 1.0])
phi = lambda v: np.array([v[0]**2, v[1]**2, np.sqrt(2)*v[0]*v[1],
                          np.sqrt(2)*v[0], np.sqrt(2)*v[1], 1.0])
print((x @ z + 1) ** 2, round(phi(x) @ phi(z), 6))   # 36.0 36.0

# RBF kernel
rbf = lambda d, g: np.exp(-g * d ** 2)
print([round(float(rbf(d, 1.0)), 3) for d in (0, 1, 2)])    # [1.0, 0.368, 0.018]
print([round(float(rbf(d, 0.1)), 3) for d in (0, 1, 2)])    # [1.0, 0.905, 0.67]

# The one-word veto and Laplace smoothing
spam, legit = 0.3 * 0.6 * 0.4, 0.7 * 0.05 * 0.1      # "free" + "password" (lesson 06)
print(spam * 0 / (spam * 0 + legit * 0.3))           # 0.0 -> veto
p_s, p_l = (0 + 1) / (100 + 2), (30 + 1) / (100 + 2)
print(round(spam * p_s / (spam * p_s + legit * p_l), 3))   # 0.399

# Gaussian Naive Bayes
normal = lambda x, m, s: np.exp(-(x - m) ** 2 / (2 * s * s)) / (s * np.sqrt(2 * np.pi))
a, c = 0.3 * normal(3, 2, 1), 0.7 * normal(3, 5, 2)
print(round(a / (a + c), 3))                         # 0.462
```

In real life: `sklearn.svm.SVC(kernel="rbf", C=..., gamma=...)` and `MultinomialNB(alpha=1.0)`, `BernoulliNB` and `GaussianNB`, where `alpha` is the smoothing.

## Summary

- A linear SVM maximizes the **margin = 2/‖w‖**, defined only by the **support vectors**.
- The **soft margin** accepts violations and charges the **hinge loss**; **C** controls the balance (large C = less regularization).
- **Kernels** compute dot products in transformed spaces without building them; in the **RBF**, **γ** controls each point's reach.
- Naive Bayes has **multinomial**, **Bernoulli** and **Gaussian** variants; **Laplace smoothing** keeps a zero probability from vetoing the whole decision.
- For the attacker: the one-word veto, SVMs with high C and γ, support vectors that leak training data and predictable Gaussian boundaries.

## Check your understanding

<details><summary>1. In a linear SVM, ‖w‖ = 0.5. How wide is the margin?</summary>

margin = 2 / ‖w‖ = 2 / 0.5 = 4.
</details>

<details><summary>2. A legitimate point has y × (w·x + b) = 0.2. What is its hinge loss and what does it indicate?</summary>

hinge = 1 − 0.2 = 0.8. The point is on the right side of the boundary, but inside the margin.
</details>

<details><summary>3. An RBF SVM gets 100% on training and does poorly on validation. Which hyperparameters would you adjust and in which direction?</summary>

Lower γ (so each point influences a larger region, with a smoother boundary) and/or lower C (to tolerate more violations and prioritize the margin). Both changes increase regularization.
</details>

<details><summary>4. Why can a Naive Bayes without smoothing be evaded with a single word?</summary>

Because if the word never appeared in spam during training, P(word | spam) = 0, and the product of all the spam class probabilities becomes zero, regardless of the other evidence. Laplace smoothing gives every word a minimum non-zero probability.
</details>

<details><summary>5. Why can stealing a trained SVM's file be a data leak, and not just an intellectual property loss?</summary>

Because the model stores the support vectors, which are real examples from the training set. Whoever has the file has those examples, along with any sensitive information they contain.
</details>

---

← [06.1 · Decision trees in depth](06-1-decision-trees-deep-dive.md) · **Next lesson in the track:** [07 · Unsupervised learning](07-unsupervised-learning.md) →

# 04.1 · Logarithms, exponentials and entropy

> 🇺🇸 English · 🇧🇷 [Português](04-1-logs-and-entropy.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [04 · Essential math](04-essential-math.md) |
| **Level** | Deep dive |
| **Prerequisites** | [04 · Essential math](04-essential-math.md) (reading [05 · Linear and logistic regression](05-linear-logistic-regression.md) helps) |
| **Reading time** | ~25 min |
| **You will learn** | Why ML uses exponentials and logarithms all the time, what information and entropy are, where log loss comes from, what KL divergence and perplexity are, and how all of it shows up in attacks and defenses |

## Where we left off

[Lesson 04](04-essential-math.md) showed the softmax, and [lesson 05](05-linear-logistic-regression.md) used log loss `−ln(p)` to train logistic regression. Both used `e^x` and `ln(x)` without much explanation. [Lesson 06](06-trees-naive-bayes-svm.md) used Gini impurity and left out the other classic measure, **entropy**. This deep dive fills those gaps.

## Exponentials: growing by multiplying

An exponential is repeated multiplication: `2^3 = 2 × 2 × 2 = 8`. The most common base in ML is the number **e ≈ 2.718**:

| x | −1 | 0 | 1 | 2 |
|---|----|---|---|---|
| e^x | 0.368 | 1 | 2.718 | 7.389 |

Three properties explain why it shows up so often:

- **Always positive**: `e^x > 0` for any x. That is why softmax uses `e^z`: it turns any logit, even a negative one, into a positive weight.
- **Amplifies differences**: a logit of 2 becomes 7.389, while a logit of 1 becomes 2.718. A difference of 1 in the logit became a factor of almost 3. That is what makes softmax "decisive".
- **Turns sums into products**: `e^(a+b) = e^a × e^b`.

## Logarithms: the inverse question

The logarithm answers: **"to which exponent must I raise the base to get this number?"**

```text
log₂(8) = 3        because 2³ = 8
log₁₀(1000) = 3    because 10³ = 1000
ln(e) = 1          ln is the base-e logarithm (natural logarithm)
```

The properties that matter for ML:

| Property | Example | Why it matters |
|----------|---------|----------------|
| `log(a × b) = log(a) + log(b)` | `log₂(4 × 8) = 2 + 3 = 5` | Products become sums, much easier to compute and differentiate |
| `log(1) = 0` | — | Total certainty (probability 1) costs nothing |
| `log(x) < 0` for 0 < x < 1 | `ln(0.5) = −0.693` | The log of a probability is always negative or zero; that is why log loss has a minus sign |
| Grows slowly | `log₁₀(1,000,000) = 6` | Compresses huge numbers into manageable scales |

### The problem logarithms solve: underflow

The Naive Bayes from [lesson 06](06-trees-naive-bayes-svm.md) multiplies one probability per word. In a 400-word email, each word with probability 0.1:

```text
0.1^400 = 10^−400
```

The smallest positive number an ordinary `float64` can represent is around `10^−308`. Below that, the computer rounds to **zero** (*underflow*), and the classifier breaks: every class scores 0. With logarithms, the product becomes a sum:

```text
ln(0.1^400) = 400 × ln(0.1) = 400 × (−2.303) = −921.0
```

A perfectly ordinary number. That is why, in practice, models work with **log-probabilities**.

### Log-odds: the logit of logistic regression

In [lesson 05](05-linear-logistic-regression.md), model extraction undid the sigmoid with `z = ln(p / (1 − p))`. That quantity is the **log-odds** (or *logit*): the logarithm of the ratio between the odds of "yes" and "no". With p = 0.9, the odds are 9 to 1, and `ln(9) = 2.197`. The linear model works on that scale, which goes from −∞ to +∞, and the sigmoid translates it back into a probability.

## Information: how surprising a piece of news is

Information theory measures the **surprise** of an event by its probability:

```text
information(x) = −log₂ p(x)    (in bits)
```

| Event | Probability | Information |
|-------|-------------|-------------|
| A fair coin landing heads | 1/2 | **1 bit** |
| Guessing a number from 1 to 8 | 1/8 | **3 bits** |
| A stable server staying up | 0.99 | **0.0145 bit** |

The rarer, the more information. A certain event (p = 1) carries no information at all. The **bit** unit shows up because, with base-2 logs, 1 bit is exactly the answer to a balanced yes/no question.

## Entropy: the average surprise

**Entropy** is the **average** information of a distribution, that is, how unpredictable the outcome is:

```text
H(p) = − Σ p(x) × log₂ p(x)
```

| Distribution | Entropy | Reading |
|--------------|---------|---------|
| Fair coin (0.5 / 0.5) | **1 bit** | Maximum uncertainty between two outcomes |
| Biased coin (0.9 / 0.1) | **0.469 bit** | Much more predictable |
| Four equal outcomes (0.25 each) | **2 bits** | Two yes/no questions settle it |
| Certain outcome (1 / 0) | **0** | No uncertainty |

### Entropy in decision trees

In [lesson 06](06-trees-naive-bayes-svm.md), the tree picked the question that most reduced Gini impurity. Entropy is the classic alternative, and the reduction in entropy has a name: **information gain**. Both criteria usually pick similar questions; [06.1 · Decision trees in depth](06-1-decision-trees-deep-dive.md) works through the full computation.

## Cross-entropy: the real name of log loss

When we use a distribution **q** (what the model predicts) to describe a reality **p** (the true label), the average cost is the **cross-entropy**:

```text
H(p, q) = − Σ p(x) × log q(x)
```

In a classification problem, the true label has probability 1 on the right class and 0 on the others. The whole sum collapses into a single term:

```text
H(p, q) = − log q(right class)
```

That is exactly the **log loss** from lesson 05. If the model gave 0.9 to the right class, the loss is `−ln(0.9) = 0.105` (in *nats*, the natural log unit) or `−log₂(0.9) = 0.152` bit. Training a classifier or an LLM is, literally, **minimizing the cross-entropy** between predictions and data.

### KL divergence: the extra cost of the wrong model

The difference between cross-entropy and true entropy is the **Kullback-Leibler divergence**:

```text
KL(p ‖ q) = H(p, q) − H(p) = Σ p(x) × log₂( p(x) / q(x) )
```

If reality is a fair coin (p = 0.5 / 0.5), but the model believes it is biased (q = 0.9 / 0.1):

```text
H(p, q) = 1.737 bit    H(p) = 1 bit    KL = 0.737 bit
```

The 0.737 bit is the **price of believing the wrong distribution**. KL is zero only when q = p, and it shows up in training VAEs ([lesson 12](12-diffusion-models.md)) and in LLM alignment, where it limits how far the tuned model can drift from the original.

## Perplexity: "how many options is the model torn between?"

**Perplexity** is entropy converted back into "number of options":

```text
perplexity = 2^H
```

| Next-token distribution | Entropy | Perplexity | Reading |
|-------------------------|---------|------------|---------|
| Four equally likely tokens | 2 bits | **4** | The model is torn between 4 options |
| One token at 90%, another at 10% | 0.469 bit | **1.38** | Almost decided |

In an LLM ([lesson 11](11-llms.md)), the perplexity of a text measures how "natural" it is for the model: ordinary text has low perplexity, strange sequences have high perplexity.

> [!TIP]
> **Red teamer's view**
> 1. **Perplexity filters** block GCG-style adversarial suffixes ([jailbreaks](../02-prompt-injection/jailbreaks.md)), which are absurd token sequences and therefore have very high perplexity ([layered defense](../08-defense/prompt-injection-defense.md)). Attackers responded by searching for **readable**, low-perplexity suffixes.
> 2. **Exfiltration through hints is an entropy calculation.** A 4-digit code has `log₂(10⁴) ≈ 13.3` bits; each yes/no answer reveals at most 1 bit. So about 14 well-chosen questions are enough ([direct injection](../02-prompt-injection/direct-prompt-injection.md)). Filters that only look at the full answer miss the bit-by-bit leak.
> 3. **Low loss gives training data away.** A model usually has lower cross-entropy on examples it saw during training. *Membership inference* attacks (privacy section) exploit exactly that gap.
> 4. **Adversarial examples maximize log loss.** The FGSM from [lesson 09](09-neural-networks.md) climbs the gradient of cross-entropy with respect to the input.

## Hands-on with Python

```python
import numpy as np

# Underflow: the product becomes zero, the sum of logs does not
print(0.1 ** 400)                 # 0.0
print(400 * np.log(0.1))          # -921.03...

def entropy(p):
    p = np.array(p, dtype=float)
    p = p[p > 0]
    return -(p * np.log2(p)).sum()

print(entropy([0.5, 0.5]))                     # 1.0
print(round(entropy([0.9, 0.1]), 3))           # 0.469
print(entropy([0.25] * 4))                     # 2.0

# Cross-entropy with the true label = log loss
print(round(-np.log(0.9), 3))                  # 0.105 (nats)

# KL divergence: a fair coin described as biased
p, q = np.array([0.5, 0.5]), np.array([0.9, 0.1])
print(round((p * np.log2(p / q)).sum(), 3))    # 0.737

# Perplexity and exfiltration through hints
print(round(2 ** entropy([0.9, 0.1]), 2))      # 1.38
print(round(np.log2(10 ** 4), 1))              # 13.3 bits in a 4-digit code
```

## Summary

- **Exponentials** are always positive and amplify differences, which is why they are in softmax.
- **Logarithms** turn products into sums and avoid *underflow*: models work with log-probabilities.
- **Information** measures surprise (`−log₂ p`); **entropy** is the average surprise, the measure of a distribution's uncertainty.
- **Log loss** is **cross-entropy** with the true label; **KL divergence** is the extra cost of using the wrong distribution.
- **Perplexity** turns entropy into "number of options" and is the basis of filters against adversarial suffixes.

## Check your understanding

<details><summary>1. Why can a naive Naive Bayes, which multiplies probabilities directly, score everything as a "tie" on long texts?</summary>

Because the product of hundreds of probabilities below 1 falls below the smallest number the computer can represent and becomes zero (*underflow*). Every class scores 0. Summing log-probabilities fixes it.
</details>

<details><summary>2. Which distribution has more entropy: a classifier that gives 50% to each class or one that gives 99% to one of them? What does that say about confidence?</summary>

The 50/50 one (1 bit, versus about 0.08 bit). Low entropy means the model is **confident**, which does not mean it is right.
</details>

<details><summary>3. Why is training a classifier with log loss the same as minimizing cross-entropy?</summary>

Because, with the true label having probability 1 on the right class, cross-entropy collapses to `−log q(right class)`, which is exactly log loss.
</details>

<details><summary>4. A secret code has 6 hexadecimal characters. At least how many yes/no questions does an attacker need to find it through indirect exfiltration?</summary>

Each hexadecimal character carries 4 bits (16 options), so the code has 24 bits. Since each yes/no answer reveals at most 1 bit, at least 24 well-chosen questions are needed.
</details>

<details><summary>5. Why does a perplexity filter block GCG-style suffixes but not a role-play jailbreak?</summary>

GCG suffixes are meaningless token sequences with very high perplexity. A role-play is written in natural language, with normal perplexity, and passes the filter like any ordinary text.
</details>

---

← [04 · Essential math for AI](04-essential-math.md) · **Next lesson in the track:** [05 · Linear and logistic regression](05-linear-logistic-regression.md) →

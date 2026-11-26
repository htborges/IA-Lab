# 03.1 · Evaluation and regularization

> 🇺🇸 English · 🇧🇷 [Português](03-1-evaluation-regularization.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [03 · How machines learn](03-how-machines-learn.md) |
| **Level** | Deep dive |
| **Prerequisites** | [03 · How machines learn](03-how-machines-learn.md) (reading [05 · Linear and logistic regression](05-linear-logistic-regression.md) helps) |
| **Reading time** | ~25 min |
| **You will learn** | What bias and variance are, how cross-validation gives a more honest performance estimate, how to choose the right split for security data, how L1 and L2 put the brakes on overfitting, and why inflated evaluations hide weaknesses an attacker will find |

## Where we left off

In [lesson 03](03-how-machines-learn.md) we split the dataset into training, validation and test, and saw underfitting and overfitting. Three questions were left: is a single random split enough to trust the number? Which split makes sense when the data is logs, malware or emails? And how do we **prevent** overfitting, beyond just detecting it?

## Bias and variance

The two kinds of generalization error have names:

| | High bias | High variance |
|-|-----------|---------------|
| **What it is** | The model is too simple and is systematically wrong | The model is too sensitive to the details of training and changes a lot with slightly different data |
| **Symptom** | High error on training and validation | Low error on training, high on validation |
| **Name in lesson 03** | Underfitting | Overfitting |
| **Analogy** | A shooter who always hits the same spot, off target | A shooter who hits around the target, but scattered |

Increasing the model's capacity reduces bias and increases variance; regularizing does the opposite. The goal is the balance point, and the way to find it is to **measure well**.

## Cross-validation

With a single training/validation split, the result depends on the luck of which examples landed on each side. **k-fold cross-validation** reduces that luck:

1. Split the data into **k parts** (*folds*), for example 5.
2. Train k times: in each round, one part is held out for validation and the other k − 1 train.
3. Report the **mean** and the **deviation** of the k results.

| Round | Part 1 | Part 2 | Part 3 | Part 4 | Part 5 |
|-------|--------|--------|--------|--------|--------|
| 1 | **validation** | train | train | train | train |
| 2 | train | **validation** | train | train | train |
| 3 | train | train | **validation** | train | train |
| 4 | train | train | train | **validation** | train |
| 5 | train | train | train | train | **validation** |

Every example is used for validation exactly once.

Example with 5 folds and each round's validation accuracy:

| Fold | 1 | 2 | 3 | 4 | 5 |
|------|---|---|---|---|---|
| Accuracy | 0.82 | 0.85 | 0.79 | 0.88 | 0.81 |

```text
mean = 0.83      standard deviation ≈ 0.03
```

The deviation matters as much as the mean: it tells you how much the result **swings** depending on the data. A model at 0.83 ± 0.03 is very different from one at 0.83 ± 0.15.

> [!NOTE]
> **What about the test set?**
> Cross-validation is for choosing models and hyperparameters. The test set stays separate and is used **only once**, at the end. If you tune the model by looking at the test set, it becomes validation and stops measuring generalization.

### Choosing the right split

Random splitting assumes the examples are independent and come from the same distribution. In security, that is almost never true:

| Split | How it works | When to use it |
|-------|--------------|----------------|
| **Random** | Draws examples into the folds at random | Truly independent data |
| **Stratified** | Keeps each class's proportion in every fold | Imbalanced classes, such as 1% attacks: without it, a fold may have no attacks at all |
| **Temporal** | Trains on the past and validates on the future, never the other way around | Logs, traffic, fraud, any data whose behavior changes over time |
| **Grouped** | All examples from the same group (user, host, malware family, phishing campaign) stay on the same side | When examples from the same group resemble each other |

## Leakage in evaluation

**Data leakage** happens when information the model would not have in production gets into training or evaluation. The result is a pretty, false number. The most common cases:

| Leakage | Example |
|---------|---------|
| **Group** | Variants of the same malware family in training and test: the model recognizes the family, not the malicious behavior |
| **Temporal** | A random split on log data: the model "sees the future" and learns patterns that did not exist yet at the simulated date |
| **Preprocessing** | Normalizing or selecting features using the whole dataset **before** splitting: test statistics leak into training |
| **Duplicates** | The same email or file (or nearly the same) on both sides of the split |
| **Shortcut feature** | A field that only exists because of the label, like the files' source folder ([06.1](06-1-decision-trees-deep-dive.md)) |

A hypothetical example of the effect, for a malware detector:

| Split used in evaluation | Reported accuracy |
|--------------------------|-------------------|
| Random (families mixed) | 99% |
| By family (new families in the test set) | 85% |
| Temporal (most recent samples in the test set) | 80% |

The number that matters is the last one: it is the closest to what the model will face against **new samples**.

## Regularization: putting the brakes on overfitting

Regularization adds a **penalty on the size of the weights** to the loss, so the model prefers simpler solutions:

```text
total loss = loss on the data + λ × penalty(weights)
```

The **λ** (lambda) hyperparameter controls how hard the brake is.

| Type | Penalty | Effect |
|------|---------|--------|
| **L2** (ridge, *weight decay*) | λ × Σ w² | Shrinks every weight, but rarely zeroes them |
| **L1** (lasso) | λ × Σ \|w\| | Shrinks and **zeroes** small weights: performs feature selection |
| **Elastic net** | A combination of both | Middle ground |

### An example with numbers

Picture a single weight whose ideal value without regularization would be **4**. With the loss `(w − 4)²` plus the penalty:

| λ | Weight with L2 | Weight with L1 |
|---|----------------|----------------|
| 0 | 4.0 | 4.0 |
| 1 | 2.0 | 3.5 |
| 2 | 1.33 | 3.0 |
| 3 | 1.0 | 2.5 |
| 8 | 0.44 | **0** |

```text
L2:  w = 4 / (1 + λ)            never reaches zero
L1:  w = max(0, 4 − λ/2)        reaches zero when λ ≥ 8
```

L2 pulls the weight toward zero with less and less force; L1 pulls with constant force and **zeroes** it. With many features, L1 removes the least useful ones, and the model becomes sparse.

The other forms of regularization already seen in the track follow the same idea of limiting complexity: **dropout** and **early stopping** ([lesson 09](09-neural-networks.md) and [09.1](09-1-training-neural-networks.md)), **maximum depth and pruning** in trees ([06.1](06-1-decision-trees-deep-dive.md)). The value of λ, like any hyperparameter, is chosen through **cross-validation**.

## Drift: when the world changes

Even a perfect evaluation only holds for the data of that moment. Over time, the distribution shifts (*concept drift*): new software, new user habits, new campaigns. In security there is also **adversarial drift**: attackers change **because** the model detects them. That is why detection models need continuous monitoring and re-evaluation with recent data.

> [!TIP]
> **Red teamer's view**
> 1. **Be suspicious of high metrics.** Ask how the evaluation was split. A detector evaluated with a random split, with families or campaigns mixed, is usually much weaker against new samples, and that is exactly what an attacker brings.
> 2. **A clean evaluation is not an adversarial evaluation.** Accuracy on normal data says nothing about robustness. Ask for **accuracy under attack**, measured against an attacker who knows the model and adapts.
> 3. **Regularization is also a privacy defense.** Models that overfit less memorize fewer examples and leak less under *membership inference* attacks ([09.1](09-1-training-neural-networks.md)).
> 4. **Sparse models have few footholds.** An L1 model that depends on a handful of features is easier to explain, but the attacker also only needs to change those few features ([evasion of linear models](05-linear-logistic-regression.md)).
> 5. **Drift is a window of opportunity.** Between the appearance of a new technique and the model's retraining, it goes unseen.

## Hands-on with Python

```python
import numpy as np

# Cross-validation: mean and deviation across folds
accuracies = np.array([0.82, 0.85, 0.79, 0.88, 0.81])
print(round(accuracies.mean(), 3), round(accuracies.std(), 3))   # 0.83 0.032

# Regularization on a weight whose ideal value is 4
w = np.arange(-10000, 50001) / 10000   # from -1 to 5, step 0.0001 (includes exact zero)
for lam in (1, 3, 8):
    l2 = w[np.argmin((w - 4) ** 2 + lam * w ** 2)]
    l1 = w[np.argmin((w - 4) ** 2 + lam * np.abs(w))]
    print(lam, round(l2, 2), round(l1, 2))
# 1 2.0 3.5
# 3 1.0 2.5
# 8 0.44 0.0

# Temporal split: train on the past, validate on the future
days = np.arange(100)                  # time index of each example
train, validation = days[days < 80], days[days >= 80]
print(train.max() < validation.min())  # True: nothing from the future in training
```

In real life, scikit-learn has `cross_val_score`, `StratifiedKFold`, `TimeSeriesSplit` and `GroupKFold`, and the `Ridge`, `Lasso` and `LogisticRegression(penalty="l1" or "l2")` models. Use a `Pipeline` so preprocessing is fitted only on each fold's training data.

## Summary

- **Bias** is systematic error (underfitting); **variance** is oversensitivity to training (overfitting).
- **k-fold cross-validation** gives a mean and a deviation, a more honest estimate than a single split; the test set stays untouched until the end.
- In security, prefer **stratified, temporal and grouped** splits; random splits inflate the result.
- **Leakage** (group, time, preprocessing, duplicates, shortcuts) produces pretty, false numbers.
- **L2** shrinks weights; **L1** zeroes the least useful ones; λ is chosen through cross-validation.
- For the red teamer: inflated metrics and evaluations without an attacker hide weaknesses; regularization helps privacy; drift opens windows.

## Check your understanding

<details><summary>1. A model has 30% error on training and 31% on validation. High bias or high variance? What would you try?</summary>

High bias (underfitting): the error is high on both and almost identical. Try a model with more capacity, more features or less regularization.
</details>

<details><summary>2. Why does cross-validation also report the standard deviation, not just the mean?</summary>

Because the deviation shows how much performance varies with the data used. A good mean with a high deviation points to an unstable model, whose performance in production is unpredictable.
</details>

<details><summary>3. You evaluate a malware detector with a random split and get 99%. Which split would you ask for to redo the evaluation, and why?</summary>

By family (and, if possible, temporal). With a random split, variants of the same family end up in training and test, and the model may just be recognizing known families. A family split measures the ability to detect new malware.
</details>

<details><summary>4. What is the practical difference between L1 and L2 in the page's example with λ = 8?</summary>

L2 left the weight at about 0.44: shrunk, but still there. L1 zeroed the weight, removing the feature from the model. L1 performs feature selection; L2 does not.
</details>

<details><summary>5. Why is normalizing features with the whole dataset before splitting into training and test a leak?</summary>

Because the mean and deviation used for normalization were computed with the test data too. Test information gets into training, and the evaluation becomes optimistic. Preprocessing must be fitted only on the training data of each split.
</details>

---

← [03 · How machines learn](03-how-machines-learn.md) · **Next lesson in the track:** [04 · Essential math for AI](04-essential-math.md) →

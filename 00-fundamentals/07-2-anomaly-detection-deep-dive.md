# 07.2 · Anomaly detection in depth

> 🇺🇸 English · 🇧🇷 [Português](07-2-anomaly-detection-deep-dive.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [07 · Unsupervised learning](07-unsupervised-learning.md) |
| **Level** | Deep dive |
| **Prerequisites** | [07 · Unsupervised learning](07-unsupervised-learning.md), [07.1 · Evaluating clusters](07-1-evaluating-clusters.md), [06.2 · SVM and Naive Bayes in depth](06-2-svm-naive-bayes-deep-dive.md) |
| **Reading time** | ~30 min |
| **You will learn** | How Isolation Forest, LOF and One-Class SVM work, why "far" depends on local density, how to choose the alert threshold, and how attackers escape each detector: unusual combinations, swarms of events and poisoning what counts as "normal" |

## Where we left off

[Lesson 07](07-unsupervised-learning.md) introduced three ways to detect anomalies: distance to a cluster, PCA reconstruction error and Isolation Forest, which was only mentioned. [07.1](07-1-evaluating-clusters.md) showed that scale and dimension change what "close" means. Now we will go inside the three classic detectors and, above all, understand **where each one is blind**.

## Isolation Forest: anomalies isolate quickly

The idea is the opposite of the other methods: instead of modeling normal, Isolation Forest measures **how easy it is to isolate a point** with random cuts.

Each tree picks a feature at random and a cut value at random between the minimum and maximum, and repeats until every point stands alone. Rare, distant points end up alone after **few cuts**; points in the middle of the crowd need **many**.

An example on a single feature, with the values 1, 2, 3, 4, 5 and **50**:

| Point | Chance that a single random cut (between 1 and 50) separates it | Reading |
|-------|-----------------------------------------------------------------|---------|
| 50 | (50 − 5) / 49 = **92%** | Almost any cut isolates it |
| 3 | 2 / 49 = **4%** (and it would still need to be separated from its other neighbor) | Needs many cuts |

### The score

The forest computes the **average path** h(x), the number of cuts needed to isolate the point across all trees, and compares it with the expected path for an arbitrary point in a sample of n points, c(n):

```text
score(x) = 2^( −h(x) / c(n) )        with n = 256, c(n) ≈ 10.2
```

| Average path | Score | Reading |
|--------------|-------|---------|
| 3 cuts | **0.82** | Close to 1: likely anomaly |
| 10 cuts | 0.51 | Close to 0.5: common behavior |

Advantages: it is fast, needs no distances (it escapes the curse of dimensionality from 07.1) and scales to lots of data.

### The blind spot: combinations

The cuts are **axis-aligned**, like those of a decision tree ([06.1](06-1-decision-trees-deep-dive.md)). A point where **each feature, on its own, is normal**, but the **combination** is odd, like the lesson 07 connection with few packets and a lot of volume, needs many cuts to be isolated and can pass as common. Variants with tilted cuts (*Extended Isolation Forest*) reduce this problem.

## LOF: "far" depends on the neighborhood

**LOF** (*Local Outlier Factor*) compares the density around a point with the density around its neighbors. The question is not "is this point far?", but "**is this point more isolated than its neighbors usually are?**".

### Why global distance fails

One feature, two legitimate groups with very different densities, and a suspicious point:

| Group | Values | Typical distance to the nearest neighbor |
|-------|--------|------------------------------------------|
| Workstations (dense) | 1, 2, 3, 4 | 1 |
| Servers (sparse) | 100, 110, 120, 130 | 10 |
| Suspicious | **7** | 3 (to 4) |

A detector that only looked at "distance to the nearest neighbor" would find the **servers** (10) stranger than the **7** (3). Wrong: the servers are sparse by nature; it is the 7 that breaks the pattern **of the group it sits near**.

### How LOF computes it

With k neighbors (here, k = 2):

1. **Local density** of each point: the inverse of the average distance to its k neighbors (with an adjustment called *reachability distance*, which smooths very tight groups).
2. A point's **LOF**: the neighbors' average density divided by the point's own density.

| LOF | Reading |
|-----|---------|
| ≈ 1 | As dense as its neighbors: normal |
| > 1 | Less dense than its neighbors: anomaly candidate |

In the example:

| Point | LOF |
|-------|-----|
| 1, 2, 3, 4 (workstations) | **1.00** |
| 100, 110, 120, 130 (servers) | **1.00** |
| 7 (suspicious) | **2.33** |

LOF treats both legitimate groups as normal, despite their different densities, and flags only the 7.

## One-Class SVM: a boundary around normal

**One-Class SVM** uses the SVM idea ([06.2](06-2-svm-naive-bayes-deep-dive.md)) with a single class: it learns a boundary, usually with an RBF kernel, that **wraps around** the normal data. Anything outside the boundary is an anomaly.

| Parameter | Effect |
|-----------|--------|
| **ν** (nu) | A cap on the fraction of training points that may fall outside the boundary. With ν = 0.05, the model accepts leaving up to about 5% of the training data as "atypical" |
| **γ** | The same as in RBF: high wraps around each point (a jagged boundary); low wraps everything in a smooth shape |

It is powerful in low dimensions and with clean data, but sensitive to scale ([07.1](07-1-evaluating-clusters.md)) and to what went into training.

## Comparing the detectors

| Detector | Question it asks | Strong at | Weak at |
|----------|------------------|-----------|---------|
| **Distance to cluster** ([lesson 07](07-unsupervised-learning.md)) | Is it far from the centroids? | Simplicity | Groups of different densities |
| **Reconstruction error** (PCA, autoencoder) | Does it respect the learned correlations? | Unusual combinations | Attacks that follow the correlations ([04.2](04-2-linear-algebra.md)) |
| **Isolation Forest** | Is it easy to isolate? | Lots of data, many features | Combinations without extreme values |
| **LOF** | Is it less dense than its neighbors? | Groups of different densities | Swarms; high dimensions; cost on large data |
| **One-Class SVM** | Is it outside the normal boundary? | Low dimensions, clean data | Contaminated training; scale; tuning ν and γ |

In practice, it is common to **combine** detectors and use their agreement as a stronger signal.

## Choosing the threshold

Every detector returns a **score**; the alert depends on where you cut.

- **Contamination**: many libraries ask for the expected fraction of anomalies and cut at the matching quantile. Overestimating it produces false alerts; underestimating it lets attacks through.
- **Alert budget**: in operations, the real question is "how many alerts per day can the team investigate?". Evaluate with **precision at k** (of the 50 highest-scoring alerts, how many were real?).
- **Base rate**: with rare attacks, even a good detector produces more false positives than true ones ([lesson 04](04-essential-math.md)).

> [!TIP]
> **Red teamer's view**
> 1. **Against Isolation Forest, be normal on every feature.** Keep each value within its common range and leave the oddity only in the **combination**. Axis-aligned cuts take a long time to isolate that point.
> 2. **Against LOF, attack as a swarm.** Several similar malicious events form a small, dense group and become each other's neighbors. In the example, swapping the lone 7 for three events (6.5, 7 and 7.5) drops the highest LOF from **2.33** to **1.33**, and the events at the edges land at 0.87, below normal. The attack hides inside itself.
> 3. **Against One-Class SVM, contaminate training.** If the attacker's events get into the data used to learn "normal", the boundary grows to wrap around them. A high ν makes it even easier ([data poisoning](../04-data-attacks/data-poisoning.md)).
> 4. **Masking and flooding.** Many anomalies together can hide each other (*masking*) or make normal points look anomalous (*swamping*). A wave of cheap noise that produces false positives exhausts the alert budget before the real attack.
> 5. **On the defense side,** combine detectors that ask different questions, monitor small dense groups that appear suddenly (swarms) and protect the "normal" training data as a critical asset.

## Hands-on with Python

```python
import numpy as np

def lof(xs, k=2):
    xs = np.asarray(xs, float)
    n = len(xs)
    d = np.abs(xs[:, None] - xs[None, :])
    nbrs = [np.argsort(np.where(np.arange(n) == i, np.inf, d[i]), kind="stable")[:k] for i in range(n)]
    kdist = np.array([d[i, nbrs[i][-1]] for i in range(n)])
    lrd = np.array([k / sum(max(kdist[o], d[i, o]) for o in nbrs[i]) for i in range(n)])
    return [round(float(lrd[nbrs[i]].mean() / lrd[i]), 2) for i in range(n)]

normal = [1, 2, 3, 4, 100, 110, 120, 130]
print(lof(normal + [7]))                   # [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.33]
print(lof(normal + [6.5, 7, 7.5]))         # ... 6.5: 0.87, 7: 1.33, 7.5: 0.87 -> swarm

# Isolation Forest: chance that one cut isolates, and the score
print(round(45 / 49, 3), round(2 / 49, 3))                    # 0.918 0.041
c = 2 * (np.log(255) + 0.5772156649) - 2 * 255 / 256          # c(256)
print(round(c, 2), round(2 ** (-3 / c), 3), round(2 ** (-10 / c), 3))   # 10.24 0.816 0.508
```

In real life, scikit-learn has `IsolationForest(contamination=...)`, `LocalOutlierFactor(n_neighbors=...)` and `OneClassSVM(nu=..., gamma=...)`.

## Summary

- **Isolation Forest** measures how many random cuts it takes to isolate a point; anomalies isolate quickly. It is blind to combinations without extreme values.
- **LOF** compares a point's density with its neighbors', so it handles groups of different densities. It is blind to swarms.
- **One-Class SVM** draws a boundary around normal, controlled by **ν** and **γ**. It is sensitive to contaminated training.
- Each detector answers a different question; combining them strengthens the signal.
- The **threshold** should reflect the alert budget and the base rate, not just the expected contamination.
- For the attacker: normal on every feature, swarms that hide inside themselves, contaminating "normal" and flooding alerts.

## Check your understanding

<details><summary>1. Why does a point isolated with few cuts get a high Isolation Forest score?</summary>

Because the score is `2^(−h/c)`: the shorter the path h, the closer to 1. Few cuts mean the point is separated from the rest, which is typical of anomalies.
</details>

<details><summary>2. In the example, why does LOF consider the servers (100 to 130) normal, even though they are 10 units apart?</summary>

Because LOF compares each point with its own neighbors. The servers are as spread out as their neighbors, so their relative density is 1. It is the 7 that is much less dense than the group it sits near.
</details>

<details><summary>3. A malicious event has every feature within the normal range, but a combination that never shows up. Which detector tends to catch it better: standard Isolation Forest or PCA reconstruction error?</summary>

PCA reconstruction error, which measures whether the point respects the correlations between features. Standard Isolation Forest makes axis-aligned cuts and takes a long time to isolate a point with no extreme values.
</details>

<details><summary>4. Why can three similar malicious events go unnoticed by LOF, when a single one would be detected?</summary>

Because the three become each other's neighbors and form a small, dense group. Each one's density becomes similar to its neighbors' (the other malicious events), and LOF drops to around 1.
</details>

<details><summary>5. What does One-Class SVM's ν parameter control, and why would an attacker want it to be high?</summary>

ν caps the fraction of training points that may fall outside the boundary. With a high ν, the model tolerates more atypical points in training and draws a looser boundary, which makes it easier for the attacker's events, if they are in or near the training data, to be accepted as normal.
</details>

---

← [07.1 · Evaluating clusters](07-1-evaluating-clusters.md) · **Next lesson in the track:** [08 · Reinforcement learning](08-reinforcement-learning.md) →

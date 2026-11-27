# 07.1 · Evaluating clusters

> 🇺🇸 English · 🇧🇷 [Português](07-1-evaluating-clusters.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [07 · Unsupervised learning](07-unsupervised-learning.md) |
| **Level** | Deep dive |
| **Prerequisites** | [07 · Unsupervised learning](07-unsupervised-learning.md), [04 · Essential math](04-essential-math.md) |
| **Reading time** | ~25 min |
| **You will learn** | Why feature scale decides who is "similar", how to choose between Euclidean, Manhattan and cosine distance, how the silhouette measures clustering quality, why K-Means always finds groups, what the curse of dimensionality is, and how all of it helps an attacker hide in a benign cluster |

## Where we left off

In [lesson 07](07-unsupervised-learning.md), K-Means split 6 hosts into "workstations" and "servers", and we warned that normalizing features was mandatory. We also used the elbow method to choose k. But without labels, how do we know the clustering is **good**? And why does scale matter so much? This deep dive answers with numbers.

## Scale decides who is similar

Three hosts, described by **volume sent** and **number of distinct ports**:

| Host | Volume | Ports |
|------|--------|-------|
| A | 500 KB | 3 |
| B | 520 KB | 80 |
| C | 900 KB | 4 |

Who is A's nearest neighbor? It depends on the volume's **unit**:

| Volume measured in | Distance A–B | Distance A–C | A's neighbor |
|--------------------|--------------|--------------|--------------|
| KB | 79.6 | 400.0 | **B** |
| MB | 77.0 | 1.08 | **C** |

**The same data, just in another unit, gives another answer.** In KB, volume dominates the distance and B (which sweeps 80 ports) looks like A's twin. In MB, the ports dominate. Neither choice is "correct"; both are **accidental**.

The fix is to put every feature on a comparable scale before measuring distances:

| Technique | How it works | Caveat |
|-----------|--------------|--------|
| **Standardization** (*z-score*) | `(x − mean) / deviation`: each feature gets mean 0 and deviation 1 | Sensitive to outliers, which inflate the deviation |
| **Min-max** | `(x − min) / (max − min)`: each feature goes to the [0, 1] range | A single extreme value squeezes all the others |
| **Robust scaling** | Uses the median and interquartile range instead of mean and deviation | More stable when there are outliers |
| **Log** ([04.1](04-1-logs-and-entropy.md)) | Compresses features that vary across orders of magnitude (bytes, counts) | Positive values only |

As in [03.1](03-1-evaluation-regularization.md), the scaling must be fitted on training data only.

## Which distance to use

Two hosts with the **same traffic profile** but different volumes: x = (3, 4) and y = (6, 8), where y does exactly twice as much of everything.

| Distance | Formula | Value | Reading |
|----------|---------|-------|---------|
| **Euclidean** | `√Σ (xᵢ − yᵢ)²` | 5.0 | "Quite different": looks at the straight-line distance |
| **Manhattan** | `Σ \|xᵢ − yᵢ\|` | 7 | Adds up the differences along each axis; less sensitive to a single very different feature |
| **Cosine** ([lesson 04](04-essential-math.md)) | `1 − cos(x, y)` | 0 (similarity 1.0) | "Identical": only looks at **direction**, ignores size |

The choice depends on what matters: **volume** (Euclidean) or the **proportion** between features (cosine). For text and embeddings, cosine is the default ([lesson 13](13-ai-systems.md)); for network metrics, Euclidean over standardized features is common.

## Silhouette: is the clustering any good?

Without labels, clustering quality is measured by asking: **is each point closer to its own group than to the neighboring group?** For each point i:

```text
a = average distance to the other points in its own group
b = average distance to the points in the nearest neighboring group
silhouette(i) = (b − a) / max(a, b)
```

| Silhouette | Meaning |
|------------|---------|
| Close to **+1** | Well inside its own group, far from the others |
| Close to **0** | On the border between two groups |
| **Negative** | Probably in the wrong group |

### With the 6 hosts from lesson 07

| Clustering | Average silhouette | Highlights |
|------------|--------------------|------------|
| {A, B, C} and {D, E, F} (the K-Means one) | **0.82** | A: 0.84 · B: 0.85 · D: 0.80 |
| {A, B, D} and {C, E, F} (mixed on purpose) | **−0.02** | D: −0.56 · C: −0.58, both in the wrong group |

The average silhouette also helps choose k: compare the average for k = 2, 3, 4… and keep the highest. It complements the elbow method.

### The suspicious host

Host G = (9, 2) from lesson 07, if placed in the workstation group, would have `a = 6.71` and `b = 7.04`:

```text
silhouette(G) = (7.04 − 6.71) / 7.04 ≈ 0.05
```

Almost zero: G does not truly belong to any group. **Points with a low or negative silhouette are natural anomaly candidates.**

## K-Means always finds groups

K-Means returns **k groups** even when the data is completely random, with no structure at all. So before interpreting clusters:

- check the **clustering tendency**: are there real groups? (statistics such as Hopkins' compare the data with uniformly random points);
- check the **silhouette** and **stability**: if you run it again with another initialization or another sample, do the groups hold?
- validate with **domain knowledge**: do the groups make sense to an analyst?

## The curse of dimensionality

With many features, distances behave in unintuitive ways. One way to see it: in a cube with side 1, the fraction of the volume that sits **away from the edges** (in the 90% "core" along each dimension) is `0.9^d`:

| Dimensions d | Fraction in the core |
|--------------|----------------------|
| 2 | 81% |
| 10 | 35% |
| 100 | 0.003% |

In 100 dimensions, practically every point is "near some edge", and the distances between random points all look alike: the nearest and farthest neighbors almost tie. Clustering and distance-based detectors lose their power to discriminate.

That is why, with many features, it is common to **reduce dimensionality** before clustering (PCA, [04.2](04-2-linear-algebra.md)). Data often has an **intrinsic dimensionality** much lower than its number of columns: in lesson 07, two features were in practice just one (99.9% of the variance in one component).

> [!TIP]
> **Red teamer's view**
> 1. **Change the feature that dominates the distance.** If the detector does not standardize features, the largest-scale one decides everything. Adjusting that feature, for example volume, places the host in the benign cluster even with odd behavior on the others.
> 2. **Cosine ignores volume.** A detector based on cosine similarity sees a traffic profile ten times larger, in the same proportion, as identical to normal. Exfiltration that keeps the proportion between features gets through.
> 3. **Aim for a high silhouette in the right group.** To hide, being "close" to a benign cluster is not enough: you have to be **closer to it than to any other**. Monitoring the silhouette of new points is a cheap defense.
> 4. **Malware family clusters can be artifacts.** K-Means always returns k groups. Attribution of authorship or campaign based on clusters alone, without validation, can be challenged or manipulated.
> 5. **More features is not more security.** In high dimensions, distances concentrate and anomalies get diluted; the attacker has more room to hide.

## Hands-on with Python

```python
import numpy as np

dist = lambda a, b: round(float(np.linalg.norm(np.array(a) - np.array(b))), 2)

# The unit changes the nearest neighbor
print(dist([500, 3], [520, 80]), dist([500, 3], [900, 4]))         # 79.6 400.0 (KB)
print(dist([0.5, 3], [0.52, 80]), dist([0.5, 3], [0.9, 4]))        # 77.0 1.08  (MB)

# Euclidean, Manhattan and cosine
x, y = np.array([3, 4]), np.array([6, 8])
cos = x @ y / (np.linalg.norm(x) * np.linalg.norm(y))
print(np.linalg.norm(x - y), np.abs(x - y).sum(), round(float(cos), 3))   # 5.0 7 1.0

# Average silhouette
P = {"A": (2, 1), "B": (3, 2), "C": (2, 3), "D": (9, 8), "E": (10, 9), "F": (8, 10)}

def silhouette(groups):
    total = []
    for g in groups:
        for p in g:
            a = np.mean([dist(P[p], P[q]) for q in g if q != p])
            b = min(np.mean([dist(P[p], P[q]) for q in h]) for h in groups if h is not g)
            total.append((b - a) / max(a, b))
    return round(float(np.mean(total)), 2)

print(silhouette([["A", "B", "C"], ["D", "E", "F"]]))   # 0.82
print(silhouette([["A", "B", "D"], ["C", "E", "F"]]))   # -0.02

# Curse of dimensionality
print([round(0.9 ** d, 6) for d in (2, 10, 100)])       # [0.81, 0.348678, 2.7e-05]
```

In real life, use scikit-learn's `StandardScaler` or `RobustScaler` and `silhouette_score`, always inside a `Pipeline`.

## Summary

- Without standardization, a feature's **unit** decides who is similar; standardize, normalize or use robust scaling.
- **Euclidean** measures straight-line distance, **Manhattan** adds up per axis and **cosine** only looks at direction; the choice depends on what matters in the problem.
- The **silhouette** compares the distance to one's own group with the distance to the neighbor: close to 1 is good, close to 0 is a border, negative is the wrong group.
- K-Means **always** finds k groups; check tendency, stability and domain sense.
- In **high dimensions**, distances lose contrast; reduce dimensionality before clustering.
- For the attacker: the dominant feature, cosine's blindness to volume, a high silhouette in the benign cluster and high dimensions as a hiding place.

## Check your understanding

<details><summary>1. Why did measuring volume in KB or MB change A's nearest neighbor?</summary>

Because, without standardization, the feature with larger numbers dominates the distance. In KB, the volume differences (hundreds) outweigh the port differences (tens); in MB, the opposite happens. The choice of unit unintentionally became a choice of weight.
</details>

<details><summary>2. Two hosts have a cosine similarity of 1.0 but a large Euclidean distance. What does that say about them?</summary>

That they have the same **profile** (same proportion between features) but different volumes: one does the same as the other, at a larger scale.
</details>

<details><summary>3. A point has a silhouette of −0.4. What does that indicate and what would you do?</summary>

That it is, on average, closer to another group than to its own: it was probably assigned to the wrong group or it is an anomaly. It is worth investigating the point and revisiting the number of groups or the features.
</details>

<details><summary>4. You run K-Means with k = 5 on log data and get five groups. Does that prove there are five kinds of behavior?</summary>

No. K-Means always returns k groups, even on data with no structure. You need to check clustering tendency, the silhouette, group stability and whether they make sense to someone who knows the environment.
</details>

<details><summary>5. Why does a distance-based anomaly detector tend to work worse with 200 features than with 10?</summary>

Because of the curse of dimensionality: in high dimensions, the distances between points all look alike, and the gap between "near" and "far" shrinks. Anomalies stop standing out. Reducing dimensionality first helps.
</details>

---

← [07 · Unsupervised learning](07-unsupervised-learning.md) · **Next:** [07.2 · Anomaly detection in depth](07-2-anomaly-detection-deep-dive.md) →

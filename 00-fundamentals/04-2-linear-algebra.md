# 04.2 · Linear algebra for ML

> 🇺🇸 English · 🇧🇷 [Português](04-2-linear-algebra.pt-BR.md)

| | |
|-|-|
| **Track** | [AI Fundamentals](README.md) · Deep dive into lesson [04 · Essential math](04-essential-math.md) |
| **Level** | Deep dive |
| **Prerequisites** | [04 · Essential math](04-essential-math.md) (reading [05](05-linear-logistic-regression.md) and [07](07-unsupervised-learning.md) helps) |
| **Reading time** | ~30 min |
| **You will learn** | Matrix multiplication and why order matters, transpose, identity, inverse and determinant, eigenvalues and eigenvectors, where the linear regression equation and PCA come from, and how all of it shows up in model extraction, detector evasion and robustness |

## Where we left off

[Lesson 04](04-essential-math.md) showed vectors, cosine similarity and **matrix × vector** multiplication as a neural network layer. Along the track, a "closed formula" for linear regression ([lesson 05](05-linear-logistic-regression.md)) and the "directions of greatest variation" of PCA ([lesson 07](07-unsupervised-learning.md)) showed up without explanation. Both come from the same tools, which this deep dive introduces.

## Matrix multiplication

Multiplying two matrices A × B means applying matrix × vector multiplication to **each column of B**. The entry at row i, column j of the result is the dot product of row i of A with column j of B.

```text
B = | 1  2 |        C = | 0  1 |
    | 3  4 |            | 1  0 |

B × C = | 2  1 |    C × B = | 3  4 |
        | 4  3 |            | 1  2 |
```

**Order matters**: `B × C ≠ C × B`. Multiplying B by C on the right swapped B's **columns**; on the left, it swapped the **rows**. In neural networks, this is how layers compose: applying W₁ and then W₂ is applying `W₂ × W₁` ([lesson 09](09-neural-networks.md) used this to show that stacked linear layers are worth just one).

The shapes also need to match: an m × n matrix only multiplies an n × p one, and the result is m × p.

## Transpose, identity and inverse

| Operation | What it does | Example with B |
|-----------|--------------|----------------|
| **Transpose** Bᵀ | Swaps rows and columns | `Bᵀ = [[1, 3], [2, 4]]` |
| **Identity** I | A matrix with 1 on the diagonal and 0 elsewhere; `I × v = v` | `I = [[1, 0], [0, 1]]` |
| **Inverse** B⁻¹ | The matrix that undoes B: `B × B⁻¹ = I` | `B⁻¹ = [[−2, 1], [1.5, −0.5]]` |
| **Trace** tr(B) | Sum of the diagonal | 1 + 4 = 5 |

For a 2 × 2 matrix, the inverse has a direct formula:

```text
| a b |⁻¹       1     |  d  −b |
| c d |    = ─────── × | −c   a |
              ad − bc
```

The number `ad − bc` in the denominator is the **determinant**. For B: `1 × 4 − 2 × 3 = −2`.

## Determinant: when the inverse does not exist

The determinant measures how much the matrix **stretches or shrinks areas** (volumes, in more dimensions). If it is **zero**, the matrix "flattens" space into a lower dimension, and information is lost for good: there is no inverse.

```text
S = | 1  2 |      det(S) = 1 × 4 − 2 × 2 = 0
    | 2  4 |
```

S's second column is twice the first. In data, this is what happens with **redundant features**: "size in KB" and "size in bytes", or "packets" and "volume" being nearly proportional ([lesson 07](07-unsupervised-learning.md)). Such matrices are called **singular**, and algorithms that need to invert them break or become unstable.

## The linear regression equation

Remember the "closed formula" from lesson 05? It is:

```text
w = (Xᵀ X)⁻¹ Xᵀ y
```

With the four apartments from lesson 05 (areas 40, 60, 80 and 100; prices 210, 310, 370 and 470), the matrix X has a column of 1s (for the bias b) and a column of areas:

```text
Xᵀ X = |   4     280  |      Xᵀ y = |   1360  |
       | 280   21600  |             | 103600  |

det(Xᵀ X) = 4 × 21600 − 280² = 8000

w = (Xᵀ X)⁻¹ Xᵀ y = | 46  |   →   b = 46, w = 4.2
                    | 4.2 |
```

It is exactly the `4.2 × area + 46` line that lesson 05 found. The 05.1 deep dive will derive this equation step by step.

### When Xᵀ X is singular: regularization to the rescue

With redundant features, `Xᵀ X` becomes singular and has no inverse. **Ridge** regression (the L2 regularization from [03.1](03-1-evaluation-regularization.md)) fixes it by adding λ to the diagonal:

```text
w = (Xᵀ X + λ I)⁻¹ Xᵀ y
```

For the matrix S above, the determinant goes from **0** to **0.51** with λ = 0.1: the matrix has an inverse again. That is one of the practical reasons for L2: besides curbing overfitting, it **stabilizes** the computation.

## Eigenvalues and eigenvectors

Most vectors change **direction** when multiplied by a matrix. A few special vectors only change **size**: they are the **eigenvectors**, and the scale factor is the **eigenvalue**:

```text
A × v = λ × v
```

Example with `A = [[2, 1], [1, 2]]`:

| Vector | A × vector | Result |
|--------|------------|--------|
| (1, 1) | (3, 3) | The same vector × **3**: eigenvector with eigenvalue 3 |
| (1, −1) | (1, −1) | The same vector × **1**: eigenvector with eigenvalue 1 |
| (1, 0) | (2, 1) | Changed direction: not an eigenvector |

Two useful properties: the **sum** of the eigenvalues is the trace (3 + 1 = 4 = 2 + 2) and the **product** is the determinant (3 × 1 = 3 = 2 × 2 − 1 × 1).

### PCA is an eigenvector decomposition

In [lesson 07](07-unsupervised-learning.md), PCA found the principal component **(0.457, 0.890)** and said it explained **99.9%** of the variation. Where did that come from? From the data's **covariance matrix** (which measures how the features vary together):

```text
Cov = | 1.667  3.233 |
      | 3.233  6.300 |
```

The covariance's eigenvectors are the principal directions, and the eigenvalues are the **variance** along each direction:

| Eigenvalue | Eigenvector | Share of the variance |
|------------|-------------|-----------------------|
| 7.961 | (0.457, 0.890) | 7.961 / 7.967 = **99.9%** |
| 0.006 | perpendicular to the first | 0.1% |

That is PCA: compute the covariance, decompose it into eigenvectors and keep the ones with the largest eigenvalues.

## How much a matrix can amplify

Eigenvalues (and, for non-symmetric matrices, **singular values**) tell how much a matrix can stretch a vector. In the matrix A above, a vector in the (1, 1) direction is stretched 3 times; in the (1, −1) direction, it does not change. The largest of these factors is the **spectral norm**: the **most** the layer can amplify a perturbation in its input.

> [!TIP]
> **Red teamer's view**
> 1. **Model extraction is solving a linear system.** In [lesson 05](05-linear-logistic-regression.md), d + 1 queries recovered the weights of a logistic regression. Formally, the attacker builds a matrix from the queries and inverts it; that is why the queries must be **linearly independent** (non-zero determinant). Redundant queries add nothing.
> 2. **PCA-based detectors have blind spots.** Reconstruction error only sees deviations **outside** the principal directions. An attack that moves along the dominant eigenvector, respecting the learned correlation, passes with no reconstruction error ([mimicry, lesson 07](07-unsupervised-learning.md)). The eigenvectors are the map of what the detector does **not** watch.
> 3. **Layers amplify perturbations in specific directions.** A perturbation aligned with each layer's direction of greatest amplification grows as it crosses the network; that is part of why adversarial examples work with such small changes ([lesson 09](09-neural-networks.md)). Robustness defenses cap the layers' spectral norm.
> 4. **Redundant features make the model unstable.** In an unregularized model, the weights of nearly collinear features can become huge and of opposite signs; a small change in one of them changes the output a lot, which the attacker can exploit.

## Hands-on with Python

```python
import numpy as np

B = np.array([[1, 2], [3, 4]])
C = np.array([[0, 1], [1, 0]])
print(B @ C)                       # [[2 1] [4 3]]
print(C @ B)                       # [[3 4] [1 2]]  -> order matters
print(B.T, np.trace(B))            # transpose and trace (5)
print(round(np.linalg.det(B), 3))  # -2.0
print(np.linalg.inv(B))            # [[-2.  1. ] [ 1.5 -0.5]]

# Singular matrix and the ridge fix
S = np.array([[1, 2], [2, 4]])
print(round(np.linalg.det(S), 3), round(np.linalg.det(S + 0.1 * np.eye(2)), 3))   # 0.0 0.51

# Normal equation with the apartments from lesson 05
X = np.array([[1, 40], [1, 60], [1, 80], [1, 100]])
y = np.array([210, 310, 370, 470])
print(np.linalg.solve(X.T @ X, X.T @ y).round(3))   # [46.   4.2]

# Eigenvalues and eigenvectors
A = np.array([[2, 1], [1, 2]])
values, vectors = np.linalg.eigh(A)
print(values)                      # [1. 3.]

# PCA from lesson 07 through the covariance's eigenvectors
cov = np.array([[1.667, 3.233], [3.233, 6.300]])
values, vectors = np.linalg.eigh(cov)
print(values.round(3), (values[-1] / values.sum()).round(3))   # [0.006 7.961] 0.999
```

In practice, prefer `np.linalg.solve` or `np.linalg.lstsq` over computing the inverse explicitly: they are faster and numerically more stable.

## Summary

- **Matrix multiplication** composes transformations, and order matters (`AB ≠ BA`).
- **Transpose** swaps rows and columns; the **identity** changes nothing; the **inverse** undoes the matrix and only exists if the **determinant** is non-zero.
- Redundant features produce **singular** matrices; L2 regularization adds λ to the diagonal and brings the inverse back.
- Linear regression has the solution `w = (XᵀX)⁻¹Xᵀy`, which reproduces the line from lesson 05.
- **Eigenvectors** are the directions the matrix only stretches; **PCA** is the eigenvector decomposition of the covariance.
- For the red teamer: model extraction is linear algebra, PCA detectors do not see attacks along the principal directions, and layers amplify perturbations in specific directions.

## Check your understanding

<details><summary>1. One layer applies W₁ and the next applies W₂. Which single matrix represents both, if there is no activation between them?</summary>

`W₂ × W₁` (the one applied first goes on the right). That is why stacked linear layers are equivalent to a single one, as seen in lesson 09.
</details>

<details><summary>2. Your dataset has "file size in KB" and "file size in bytes". What happens to linear regression through the normal equation, and how do you fix it?</summary>

The two columns are proportional, so `XᵀX` becomes singular (zero determinant) and has no inverse. Fix it by dropping the redundant feature or using ridge regularization, which adds λ to the diagonal.
</details>

<details><summary>3. Is the vector (2, 0) an eigenvector of the matrix A = [[2, 1], [1, 2]]?</summary>

No. `A × (2, 0) = (4, 2)`, which is not a multiple of (2, 0): the direction changed.
</details>

<details><summary>4. In a PCA, the first eigenvalue is 9 and the second is 1. What share of the variance does the first component explain?</summary>

9 / (9 + 1) = 90%.
</details>

<details><summary>5. Why does a mimicry attack against a PCA-based detector tend to move along the dominant eigenvector?</summary>

Because the detector measures reconstruction error, which only grows when the point leaves the principal directions. Moving along the dominant eigenvector preserves the correlation the detector learned, and the point keeps being reconstructed almost perfectly.
</details>

---

← [04.1 · Logarithms, exponentials and entropy](04-1-logs-and-entropy.md) · **Next lesson in the track:** [05 · Linear and logistic regression](05-linear-logistic-regression.md) →

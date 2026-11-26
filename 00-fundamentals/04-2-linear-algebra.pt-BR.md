# 04.2 · Álgebra linear para ML

> 🇧🇷 Português · 🇺🇸 [English](04-2-linear-algebra.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [04 · Matemática essencial](04-essential-math.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [04 · Matemática essencial](04-essential-math.pt-BR.md) (ajuda ter lido a [05](05-linear-logistic-regression.pt-BR.md) e a [07](07-unsupervised-learning.pt-BR.md)) |
| **Tempo de leitura** | ~30 min |
| **Você vai aprender** | Multiplicação de matrizes e por que a ordem importa, transposta, identidade, inversa e determinante, autovalores e autovetores, de onde vêm a equação da regressão linear e o PCA, e como tudo isso aparece em extração de modelos, evasão de detectores e robustez |

## Onde paramos

A [aula 04](04-essential-math.pt-BR.md) mostrou vetores, similaridade de cosseno e a multiplicação **matriz × vetor** como uma camada de rede neural. Ao longo da trilha apareceram, sem explicação, uma "fórmula fechada" para a regressão linear ([aula 05](05-linear-logistic-regression.pt-BR.md)) e as "direções de maior variação" do PCA ([aula 07](07-unsupervised-learning.pt-BR.md)). As duas saem das mesmas ferramentas, que este aprofundamento apresenta.

## Multiplicação de matrizes

Multiplicar duas matrizes A × B é aplicar a multiplicação matriz × vetor a **cada coluna de B**. A entrada da linha i, coluna j do resultado é o produto escalar da linha i de A com a coluna j de B.

```text
B = | 1  2 |        C = | 0  1 |
    | 3  4 |            | 1  0 |

B × C = | 2  1 |    C × B = | 3  4 |
        | 4  3 |            | 1  2 |
```

**A ordem importa**: `B × C ≠ C × B`. Multiplicar B por C à direita trocou as **colunas** de B; à esquerda, trocou as **linhas**. Em redes neurais, isso é a composição de camadas: aplicar W₁ e depois W₂ é aplicar `W₂ × W₁` (a [aula 09](09-neural-networks.pt-BR.md) usou isso para mostrar que camadas lineares empilhadas valem uma só).

O formato também precisa casar: uma matriz m × n só multiplica uma n × p, e o resultado é m × p.

## Transposta, identidade e inversa

| Operação | O que faz | Exemplo com B |
|----------|-----------|---------------|
| **Transposta** Bᵀ | Troca linhas por colunas | `Bᵀ = [[1, 3], [2, 4]]` |
| **Identidade** I | Matriz com 1 na diagonal e 0 no resto; `I × v = v` | `I = [[1, 0], [0, 1]]` |
| **Inversa** B⁻¹ | A matriz que desfaz B: `B × B⁻¹ = I` | `B⁻¹ = [[−2, 1], [1.5, −0.5]]` |
| **Traço** tr(B) | Soma da diagonal | 1 + 4 = 5 |

Para uma matriz 2 × 2, a inversa tem fórmula direta:

```text
| a b |⁻¹       1     |  d  −b |
| c d |    = ─────── × | −c   a |
              ad − bc
```

O número `ad − bc` no denominador é o **determinante**. Para B: `1 × 4 − 2 × 3 = −2`.

## Determinante: quando a inversa não existe

O determinante mede o quanto a matriz **estica ou encolhe áreas** (volumes, em mais dimensões). Se ele é **zero**, a matriz "achata" o espaço numa dimensão menor, e informação se perde para sempre: não há inversa.

```text
S = | 1  2 |      det(S) = 1 × 4 − 2 × 2 = 0
    | 2  4 |
```

A segunda coluna de S é o dobro da primeira. Em dados, isso é o que acontece com **features redundantes**: "tamanho em KB" e "tamanho em bytes", ou "pacotes" e "volume" quase proporcionais ([aula 07](07-unsupervised-learning.pt-BR.md)). Matrizes assim são chamadas de **singulares**, e algoritmos que precisam invertê-las quebram ou ficam instáveis.

## A equação da regressão linear

Lembra da "fórmula fechada" da aula 05? Ela é:

```text
w = (Xᵀ X)⁻¹ Xᵀ y
```

Com os quatro apartamentos da aula 05 (áreas 40, 60, 80 e 100; preços 210, 310, 370 e 470), a matriz X tem uma coluna de 1 (para o viés b) e uma coluna de áreas:

```text
Xᵀ X = |   4     280  |      Xᵀ y = |   1360  |
       | 280   21600  |             | 103600  |

det(Xᵀ X) = 4 × 21600 − 280² = 8000

w = (Xᵀ X)⁻¹ Xᵀ y = | 46  |   →   b = 46, w = 4,2
                    | 4,2 |
```

É exatamente a reta `4,2 × área + 46` que a aula 05 encontrou. O [05.1 · Mínimos quadrados](05-1-least-squares.pt-BR.md) deriva essa reta passo a passo.

### Quando Xᵀ X é singular: a regularização salva

Com features redundantes, `Xᵀ X` fica singular e não tem inversa. A regressão **ridge** (a regularização L2 do [03.1](03-1-evaluation-regularization.pt-BR.md)) resolve somando λ na diagonal:

```text
w = (Xᵀ X + λ I)⁻¹ Xᵀ y
```

Na matriz S acima, o determinante sai de **0** para **0,51** com λ = 0,1: a matriz volta a ter inversa. Esse é um dos motivos práticos da L2: além de frear o overfitting, ela **estabiliza** a conta.

## Autovalores e autovetores

A maioria dos vetores muda de **direção** quando multiplicada por uma matriz. Alguns vetores especiais só mudam de **tamanho**: são os **autovetores**, e o fator de escala é o **autovalor**:

```text
A × v = λ × v
```

Exemplo com `A = [[2, 1], [1, 2]]`:

| Vetor | A × vetor | Resultado |
|-------|-----------|-----------|
| (1, 1) | (3, 3) | O mesmo vetor × **3**: autovetor com autovalor 3 |
| (1, −1) | (1, −1) | O mesmo vetor × **1**: autovetor com autovalor 1 |
| (1, 0) | (2, 1) | Mudou de direção: não é autovetor |

Duas propriedades úteis: a **soma** dos autovalores é o traço (3 + 1 = 4 = 2 + 2) e o **produto** é o determinante (3 × 1 = 3 = 2 × 2 − 1 × 1).

### O PCA é uma decomposição em autovetores

Na [aula 07](07-unsupervised-learning.pt-BR.md), o PCA encontrou o componente principal **(0,457; 0,890)** e disse que ele explicava **99,9%** da variação. De onde veio isso? Da **matriz de covariância** dos dados (que mede como as features variam juntas):

```text
Cov = | 1,667  3,233 |
      | 3,233  6,300 |
```

Os autovetores da covariância são as direções principais, e os autovalores são a **variância** em cada direção:

| Autovalor | Autovetor | Fração da variância |
|-----------|-----------|---------------------|
| 7,961 | (0,457; 0,890) | 7,961 / 7,967 = **99,9%** |
| 0,006 | perpendicular ao primeiro | 0,1% |

O PCA é isso: calcular a covariância, decompor em autovetores e ficar com os de maior autovalor.

## Quanto uma matriz pode amplificar

Os autovalores (e, para matrizes não simétricas, os **valores singulares**) dizem quanto uma matriz pode esticar um vetor. Na matriz A acima, um vetor na direção (1, 1) é esticado 3 vezes; na direção (1, −1), não muda. O maior desses fatores é a **norma espectral**: o **máximo** que a camada pode amplificar uma perturbação na entrada.

> [!TIP]
> **Visão do red teamer**
> 1. **Extração de modelo é resolver um sistema linear.** Na [aula 05](05-linear-logistic-regression.pt-BR.md), d + 1 consultas recuperavam os pesos de uma regressão logística. Formalmente, o atacante monta uma matriz com as consultas e a inverte; por isso as consultas precisam ser **linearmente independentes** (determinante diferente de zero). Consultas redundantes não acrescentam nada.
> 2. **Detectores por PCA têm pontos cegos.** O erro de reconstrução só vê desvios **fora** das direções principais. Um ataque que se move ao longo do autovetor dominante, respeitando a correlação aprendida, passa sem erro de reconstrução ([mimetismo, aula 07](07-unsupervised-learning.pt-BR.md)). Os autovetores são o mapa do que o detector **não** vigia.
> 3. **Camadas amplificam perturbações em direções específicas.** Uma perturbação alinhada com a direção de maior amplificação de cada camada cresce ao atravessar a rede; é parte do motivo de adversarial examples funcionarem com mudanças tão pequenas ([aula 09](09-neural-networks.pt-BR.md)). Defesas de robustez limitam a norma espectral das camadas.
> 4. **Features redundantes deixam o modelo instável.** Num modelo sem regularização, pesos de features quase colineares podem ficar enormes e de sinais opostos; uma pequena mudança numa delas muda muito a saída, algo que o atacante pode explorar.

## Na prática com Python

```python
import numpy as np

B = np.array([[1, 2], [3, 4]])
C = np.array([[0, 1], [1, 0]])
print(B @ C)                       # [[2 1] [4 3]]
print(C @ B)                       # [[3 4] [1 2]]  -> a ordem importa
print(B.T, np.trace(B))            # transposta e traço (5)
print(round(np.linalg.det(B), 3))  # -2.0
print(np.linalg.inv(B))            # [[-2.  1. ] [ 1.5 -0.5]]

# Matriz singular e o conserto da ridge
S = np.array([[1, 2], [2, 4]])
print(round(np.linalg.det(S), 3), round(np.linalg.det(S + 0.1 * np.eye(2)), 3))   # 0.0 0.51

# Equação normal com os apartamentos da aula 05
X = np.array([[1, 40], [1, 60], [1, 80], [1, 100]])
y = np.array([210, 310, 370, 470])
print(np.linalg.solve(X.T @ X, X.T @ y).round(3))   # [46.   4.2]

# Autovalores e autovetores
A = np.array([[2, 1], [1, 2]])
valores, vetores = np.linalg.eigh(A)
print(valores)                     # [1. 3.]

# PCA da aula 07 via autovetores da covariância
cov = np.array([[1.667, 3.233], [3.233, 6.300]])
valores, vetores = np.linalg.eigh(cov)
print(valores.round(3), (valores[-1] / valores.sum()).round(3))   # [0.006 7.961] 0.999
```

Na prática, prefira `np.linalg.solve` ou `np.linalg.lstsq` a calcular a inversa explicitamente: são mais rápidos e numericamente mais estáveis.

## Resumo

- A **multiplicação de matrizes** compõe transformações, e a ordem importa (`AB ≠ BA`).
- **Transposta** troca linhas por colunas; **identidade** não muda nada; **inversa** desfaz a matriz e só existe se o **determinante** for diferente de zero.
- Features redundantes geram matrizes **singulares**; a regularização L2 soma λ na diagonal e devolve a inversa.
- A regressão linear tem a solução `w = (XᵀX)⁻¹Xᵀy`, que reproduz a reta da aula 05.
- **Autovetores** são as direções que a matriz só estica; o **PCA** é a decomposição em autovetores da covariância.
- Para o red teamer: extração de modelo é álgebra linear, detectores por PCA não veem ataques ao longo das direções principais, e camadas amplificam perturbações em direções específicas.

## Teste seu entendimento

<details><summary>1. Uma camada aplica W₁ e a seguinte aplica W₂. Qual matriz única representa as duas, se não houver ativação entre elas?</summary>

`W₂ × W₁` (a primeira aplicada fica à direita). Por isso camadas lineares empilhadas equivalem a uma só, como visto na aula 09.
</details>

<details><summary>2. Seu dataset tem "tamanho do arquivo em KB" e "tamanho do arquivo em bytes". O que acontece com a regressão linear pela equação normal, e como resolver?</summary>

As duas colunas são proporcionais, então `XᵀX` fica singular (determinante zero) e não tem inversa. Resolva removendo a feature redundante ou usando regularização ridge, que soma λ na diagonal.
</details>

<details><summary>3. O vetor (2, 0) é autovetor da matriz A = [[2, 1], [1, 2]]?</summary>

Não. `A × (2, 0) = (4, 2)`, que não é um múltiplo de (2, 0): a direção mudou.
</details>

<details><summary>4. Num PCA, o primeiro autovalor é 9 e o segundo é 1. Que fração da variância o primeiro componente explica?</summary>

9 / (9 + 1) = 90%.
</details>

<details><summary>5. Por que um ataque de mimetismo contra um detector por PCA tende a se mover ao longo do autovetor dominante?</summary>

Porque o detector mede o erro de reconstrução, que só cresce quando o ponto sai das direções principais. Mover-se ao longo do autovetor dominante preserva a correlação que o detector aprendeu, e o ponto continua sendo reconstruído quase perfeitamente.
</details>

---

← [04.1 · Logaritmos, exponenciais e entropia](04-1-logs-and-entropy.pt-BR.md) · **Próxima aula da trilha:** [05 · Regressão linear e logística](05-linear-logistic-regression.pt-BR.md) →

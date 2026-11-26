# 06.2 · SVM e Naive Bayes a fundo

> 🇧🇷 Português · 🇺🇸 [English](06-2-svm-naive-bayes-deep-dive.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [06 · Árvores, Naive Bayes e SVM](06-trees-naive-bayes-svm.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [06 · Árvores, Naive Bayes e SVM](06-trees-naive-bayes-svm.pt-BR.md), [04.1 · Logaritmos e entropia](04-1-logs-and-entropy.pt-BR.md), [04.2 · Álgebra linear](04-2-linear-algebra.pt-BR.md) |
| **Tempo de leitura** | ~30 min |
| **Você vai aprender** | Como a SVM calcula a margem, o que são margem suave, hinge loss e o parâmetro C, como funcionam os kernels polinomial e RBF (e o γ), as variantes do Naive Bayes, por que a suavização de Laplace existe, e como cada detalhe vira ataque |

## Onde paramos

Na [aula 06](06-trees-naive-bayes-svm.pt-BR.md), a SVM foi apresentada como "a estrada mais larga entre os dois bairros", e o truque do kernel separou pontos que nenhuma reta separava. O Naive Bayes filtrou spam com 95,4% de certeza e caiu para 8,7% com três palavras "boas". Agora vamos às contas: o que a SVM otimiza, o que os hiperparâmetros fazem, quais são as versões do Naive Bayes e por que um detalhe de implementação, a suavização, decide se uma única palavra consegue **vetar** a detecção.

## SVM: a margem em números

A fronteira de uma SVM linear é o hiperplano `w · x + b = 0`. Os pontos de cada classe ficam dos lados `w · x + b ≥ 1` e `w · x + b ≤ −1`, e a distância entre essas duas "beiras da estrada" é:

```text
margem = 2 / ‖w‖
```

**Maximizar a margem é minimizar ‖w‖** (a norma da [aula 04](04-essential-math.pt-BR.md)): pesos menores, estrada mais larga.

### Um exemplo em uma dimensão

Arquivos com uma pontuação de suspeita: legítimos em 1 e 2, maliciosos em 4 e 5. Os pontos mais próximos da outra classe são 2 e 4, os **vetores de suporte**:

```text
w × 4 + b = +1      w × 2 + b = −1      →   w = 1,  b = −3
fronteira: x = 3        margem = 2 / 1 = 2   (exatamente a distância entre 2 e 4)
```

Os pontos 1 e 5 não aparecem na conta: podiam estar em qualquer lugar além da margem, e a fronteira seria a mesma.

### Margem suave: hinge loss e o parâmetro C

Dados reais têm ruído: um malicioso no meio dos legítimos torna a separação perfeita impossível. A SVM de **margem suave** aceita violações, mas cobra por elas com a **hinge loss**:

```text
hinge = máx(0, 1 − y × (w · x + b))       (y = +1 malicioso, −1 legítimo)
```

Com a fronteira acima (w = 1, b = −3):

| Ponto | Classe | y × (w·x + b) | Hinge | Situação |
|-------|--------|---------------|-------|----------|
| x = 2 | legítimo | 1,0 | **0** | Na beira certa da margem |
| x = 2,5 | legítimo | 0,5 | **0,5** | Do lado certo, mas dentro da margem |
| x = 4 | malicioso | 1,0 | **0** | Na beira certa da margem |
| x = 3,5 | malicioso | 0,5 | **0,5** | Dentro da margem |
| x = 1,5 | malicioso | −1,5 | **2,5** | Do lado errado: classificado como legítimo |

O objetivo da SVM equilibra as duas coisas:

```text
minimizar   ½ ‖w‖²  +  C × Σ hinge
            (margem larga)  (poucas violações)
```

| C | Comportamento |
|---|---------------|
| **Pequeno** | Prioriza a margem larga e tolera erros: mais regularização, menos overfitting |
| **Grande** | Pune cada violação e entorta a fronteira para acertar todos os pontos de treino, inclusive ruído |

É o mesmo papel do λ no [03.1](03-1-evaluation-regularization.pt-BR.md), só que invertido: aqui, C maior significa **menos** regularização.

## Kernels: produto escalar em outro espaço

A SVM só usa os dados através de **produtos escalares** entre pontos. Um kernel é uma função que devolve o produto escalar num espaço transformado, **sem construir esse espaço**.

### O kernel polinomial, conferido à mão

O kernel `K(x, z) = (x · z + 1)²` para x = (1, 2) e z = (3, 1):

```text
x · z = 1×3 + 2×1 = 5        K(x, z) = (5 + 1)² = 36
```

O mesmo número sai se transformarmos cada ponto explicitamente em 6 dimensões, `φ(x) = (x₁², x₂², √2·x₁x₂, √2·x₁, √2·x₂, 1)`, e fizermos o produto escalar:

```text
φ(x) = (1, 4, 2√2, √2, 2√2, 1)
φ(z) = (9, 1, 3√2, 3√2, √2, 1)
φ(x) · φ(z) = 9 + 4 + 12 + 6 + 4 + 1 = 36
```

O kernel fez em uma conta o que exigiria criar 6 features. Com graus maiores ou mais features, o espaço explícito explode, e o kernel continua barato.

### O kernel RBF e o γ

O kernel mais usado é o **RBF** (gaussiano), que mede **semelhança por proximidade**:

```text
K(x, z) = e^(−γ × ‖x − z‖²)
```

| Distância entre os pontos | γ = 1 | γ = 0,1 |
|---------------------------|-------|---------|
| 0 | 1,000 | 1,000 |
| 1 | 0,368 | 0,905 |
| 2 | 0,018 | 0,670 |

| γ | Cada ponto de treino influencia… | Risco |
|---|----------------------------------|-------|
| **Alto** | Só a vizinhança imediata: a fronteira contorna cada ponto, formando "ilhas" | Overfitting, memorização |
| **Baixo** | Uma região ampla: fronteira suave | Underfitting |

C e γ são os dois hiperparâmetros da SVM com RBF e são escolhidos juntos por validação cruzada ([03.1](03-1-evaluation-regularization.pt-BR.md)).

## Naive Bayes: as variantes

A ideia é sempre a mesma da aula 06 (teorema de Bayes com features independentes). O que muda é **como** calcular a probabilidade de cada feature:

| Variante | Features | Como modela | Uso típico |
|----------|----------|-------------|-----------|
| **Multinomial** | Contagens (quantas vezes cada palavra aparece) | Frequência relativa de cada palavra na classe | Classificação de texto, spam |
| **Bernoulli** | Presença ou ausência (0/1) | Probabilidade de a palavra aparecer; a **ausência** também conta como evidência | Textos curtos, features binárias |
| **Gaussiana** | Números contínuos | Uma curva normal (média e desvio) por feature e por classe | Tamanho de anexo, número de links, métricas de rede |

### Naive Bayes gaussiano

Uma feature contínua, o **tamanho do anexo** (MB): no treino, spam tem média 2 e desvio 1; legítimo tem média 5 e desvio 2. Para um anexo de 3 MB, a "probabilidade" de cada classe vem da altura da curva normal naquele ponto:

| Classe | Densidade em x = 3 |
|--------|-------------------|
| Spam (média 2, desvio 1) | 0,242 |
| Legítimo (média 5, desvio 2) | 0,121 |

Com os priors da aula 06 (30% spam, 70% legítimo): `P(spam | 3 MB) = 0,3 × 0,242 / (0,3 × 0,242 + 0,7 × 0,121) ≈ 0,46`. Se o anexo tiver 6 MB, a densidade do spam cai para 0,0001 e o legítimo domina.

### Suavização de Laplace e o veto de uma palavra

No treino, a palavra "reunião" apareceu em **0 de 100** spams. Sem suavização, `P(reunião | spam) = 0`, e como o Naive Bayes **multiplica** as probabilidades:

```text
pontuação do spam = 0,3 × 0,6 × 0,4 × 0 = 0     →   P(spam) = 0
```

**Uma única palavra zera tudo**, não importa quantas evidências de spam o e-mail tenha. A **suavização de Laplace** soma 1 a todas as contagens:

```text
P(reunião | spam)     = (0 + 1) / (100 + 2) = 0,0098
P(reunião | legítimo) = (30 + 1) / (100 + 2) = 0,304
```

Com a suavização, o e-mail "grátis + senha + reunião" fica com **P(spam) ≈ 0,40**: a palavra ainda pesa, mas não tem mais poder de veto. Na prática, as implementações também trabalham com **somas de log-probabilidades** ([04.1](04-1-logs-and-entropy.pt-BR.md)), por causa do underflow.

> [!TIP]
> **Visão do red teamer**
> 1. **Procure o veto.** Num Naive Bayes sem suavização (ou com suavização mínima), basta uma palavra que nunca apareceu em spam para zerar a detecção. Teste palavras raras e típicas de e-mail legítimo; é a forma extrema do *good word attack* da aula 06.
> 2. **C grande e γ alto deixam a SVM envenenável.** Uma SVM que persegue cada ponto de treino se dobra para acomodar poucos exemplos plantados perto da margem ([data poisoning](../04-data-attacks/data-poisoning.pt-BR.md)). E um RBF com γ alto forma "ilhas" ao redor dos pontos de treino, deixando vales entre elas por onde uma entrada evade.
> 3. **Os vetores de suporte são dados de treino.** Um modelo de SVM salvo guarda os vetores de suporte, que são **exemplos reais do treino**. Roubar o arquivo do modelo é vazar parte do dataset, com tudo o que ele tiver de sensível ([arquivos de modelo](../04-data-attacks/malicious-model-files.pt-BR.md), seção de privacidade).
> 4. **Naive Bayes gaussiano tem fronteiras previsíveis.** Conhecendo médias e desvios, o atacante sabe exatamente para qual faixa de valores mover uma feature contínua para a outra classe dominar, como passar o anexo de 3 MB para 6 MB.

## Na prática com Python

```python
import numpy as np

# Margem e hinge loss com w = 1, b = -3
w, b = 1.0, -3.0
print(2 / abs(w))                                   # 2.0
for x, y in [(2, -1), (2.5, -1), (3.5, 1), (1.5, 1)]:
    print(x, max(0.0, 1 - y * (w * x + b)))        # 0.0, 0.5, 0.5, 2.5

# Kernel polinomial = produto escalar no espaço expandido
x, z = np.array([1.0, 2.0]), np.array([3.0, 1.0])
phi = lambda v: np.array([v[0]**2, v[1]**2, np.sqrt(2)*v[0]*v[1],
                          np.sqrt(2)*v[0], np.sqrt(2)*v[1], 1.0])
print((x @ z + 1) ** 2, round(phi(x) @ phi(z), 6))   # 36.0 36.0

# Kernel RBF
rbf = lambda d, g: np.exp(-g * d ** 2)
print([round(float(rbf(d, 1.0)), 3) for d in (0, 1, 2)])    # [1.0, 0.368, 0.018]
print([round(float(rbf(d, 0.1)), 3) for d in (0, 1, 2)])    # [1.0, 0.905, 0.67]

# O veto de uma palavra e a suavização de Laplace
spam, legit = 0.3 * 0.6 * 0.4, 0.7 * 0.05 * 0.1      # "grátis" + "senha" (aula 06)
print(spam * 0 / (spam * 0 + legit * 0.3))           # 0.0 -> veto
p_s, p_l = (0 + 1) / (100 + 2), (30 + 1) / (100 + 2)
print(round(spam * p_s / (spam * p_s + legit * p_l), 3))   # 0.399

# Naive Bayes gaussiano
normal = lambda x, m, s: np.exp(-(x - m) ** 2 / (2 * s * s)) / (s * np.sqrt(2 * np.pi))
a, c = 0.3 * normal(3, 2, 1), 0.7 * normal(3, 5, 2)
print(round(a / (a + c), 3))                         # 0.462
```

Na vida real: `sklearn.svm.SVC(kernel="rbf", C=..., gamma=...)` e `MultinomialNB(alpha=1.0)`, `BernoulliNB` e `GaussianNB`, em que `alpha` é a suavização.

## Resumo

- A SVM linear maximiza a **margem = 2/‖w‖**, definida só pelos **vetores de suporte**.
- A **margem suave** aceita violações e cobra a **hinge loss**; **C** controla o equilíbrio (C grande = menos regularização).
- **Kernels** calculam produtos escalares em espaços transformados sem construí-los; no **RBF**, **γ** controla o alcance de cada ponto.
- O Naive Bayes tem variantes **multinomial**, **Bernoulli** e **gaussiana**; a **suavização de Laplace** impede que uma probabilidade zero vete toda a decisão.
- Para o atacante: o veto de uma palavra, SVMs com C e γ altos, vetores de suporte que vazam dados de treino e fronteiras gaussianas previsíveis.

## Teste seu entendimento

<details><summary>1. Numa SVM linear, ‖w‖ = 0,5. Qual a largura da margem?</summary>

margem = 2 / ‖w‖ = 2 / 0,5 = 4.
</details>

<details><summary>2. Um ponto legítimo tem y × (w·x + b) = 0,2. Qual a hinge loss e o que ela indica?</summary>

hinge = 1 − 0,2 = 0,8. O ponto está do lado certo da fronteira, mas dentro da margem.
</details>

<details><summary>3. Uma SVM com RBF acerta 100% no treino e vai mal na validação. Que hiperparâmetros você ajustaria e em que direção?</summary>

Reduziria o γ (para cada ponto influenciar uma região maior, com fronteira mais suave) e/ou reduziria o C (para tolerar mais violações e priorizar a margem). As duas mudanças aumentam a regularização.
</details>

<details><summary>4. Por que um Naive Bayes sem suavização pode ser evadido com uma única palavra?</summary>

Porque se a palavra nunca apareceu em spam no treino, P(palavra | spam) = 0, e o produto de todas as probabilidades da classe spam vira zero, independentemente das outras evidências. A suavização de Laplace dá a toda palavra uma probabilidade mínima diferente de zero.
</details>

<details><summary>5. Por que roubar o arquivo de uma SVM treinada pode ser um vazamento de dados, e não só de propriedade intelectual?</summary>

Porque o modelo guarda os vetores de suporte, que são exemplos reais do conjunto de treino. Quem tem o arquivo tem esses exemplos, com qualquer informação sensível que eles contenham.
</details>

---

← [06.1 · Árvores de decisão a fundo](06-1-decision-trees-deep-dive.pt-BR.md) · **Próxima aula da trilha:** [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md) →

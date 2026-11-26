# 04.1 · Logaritmos, exponenciais e entropia

> 🇧🇷 Português · 🇺🇸 [English](04-1-logs-and-entropy.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [04 · Matemática essencial](04-essential-math.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [04 · Matemática essencial](04-essential-math.pt-BR.md) (ajuda ter lido a [05 · Regressão linear e logística](05-linear-logistic-regression.pt-BR.md)) |
| **Tempo de leitura** | ~25 min |
| **Você vai aprender** | Por que ML usa exponenciais e logaritmos o tempo todo, o que é informação e entropia, de onde vem a log loss, o que são divergência KL e perplexidade, e como tudo isso aparece em ataques e defesas |

## Onde paramos

A [aula 04](04-essential-math.pt-BR.md) mostrou a softmax, e a [aula 05](05-linear-logistic-regression.pt-BR.md) usou a log loss `−ln(p)` para treinar a regressão logística. Nas duas, apareceram `e^x` e `ln(x)` sem muita explicação. A [aula 06](06-trees-naive-bayes-svm.pt-BR.md) usou a impureza de Gini e deixou de fora a outra medida clássica, a **entropia**. Este aprofundamento preenche essas lacunas.

## Exponenciais: crescer multiplicando

Uma exponencial é uma multiplicação repetida: `2^3 = 2 × 2 × 2 = 8`. A base mais usada em ML é o número **e ≈ 2,718**:

| x | −1 | 0 | 1 | 2 |
|---|----|---|---|---|
| e^x | 0,368 | 1 | 2,718 | 7,389 |

Três propriedades explicam por que ela aparece tanto:

- **Sempre positiva**: `e^x > 0` para qualquer x. Por isso a softmax usa `e^z`: transforma qualquer logit, até negativo, num peso positivo.
- **Amplifica diferenças**: um logit 2 vira 7,389, enquanto um logit 1 vira 2,718. A diferença de 1 no logit virou um fator de quase 3. É isso que deixa a softmax "decidida".
- **Transforma soma em produto**: `e^(a+b) = e^a × e^b`.

## Logaritmos: a pergunta inversa

O logaritmo responde: **"a que expoente preciso elevar a base para chegar neste número?"**

```text
log₂(8) = 3        porque 2³ = 8
log₁₀(1000) = 3    porque 10³ = 1000
ln(e) = 1          ln é o logaritmo na base e (logaritmo natural)
```

As propriedades que importam para ML:

| Propriedade | Exemplo | Por que importa |
|-------------|---------|-----------------|
| `log(a × b) = log(a) + log(b)` | `log₂(4 × 8) = 2 + 3 = 5` | Produtos viram somas, muito mais fáceis de calcular e derivar |
| `log(1) = 0` | — | Certeza total (probabilidade 1) não custa nada |
| `log(x) < 0` para 0 < x < 1 | `ln(0,5) = −0,693` | Logaritmo de probabilidade é sempre negativo ou zero; por isso a log loss tem um sinal de menos |
| Cresce devagar | `log₁₀(1.000.000) = 6` | Comprime números gigantes em escalas manejáveis |

### O problema que o logaritmo resolve: underflow

O Naive Bayes da [aula 06](06-trees-naive-bayes-svm.pt-BR.md) multiplica uma probabilidade por palavra. Num e-mail de 400 palavras, cada uma com probabilidade 0,1:

```text
0,1^400 = 10^−400
```

O menor número positivo que um `float64` comum representa fica perto de `10^−308`. Abaixo disso, o computador arredonda para **zero** (*underflow*), e o classificador quebra: todas as classes ficam com pontuação 0. Com logaritmos, o produto vira soma:

```text
ln(0,1^400) = 400 × ln(0,1) = 400 × (−2,303) = −921,0
```

Um número perfeitamente comum. Por isso, na prática, os modelos trabalham com **log-probabilidades**.

### Log-odds: o logit da regressão logística

Na [aula 05](05-linear-logistic-regression.pt-BR.md), a extração do modelo desfazia a sigmoide com `z = ln(p / (1 − p))`. Essa quantidade é o **log-odds** (ou *logit*): o logaritmo da razão entre a chance de "sim" e a de "não". Com p = 0,9, as chances são 9 para 1, e `ln(9) = 2,197`. O modelo linear trabalha nessa escala, que vai de −∞ a +∞, e a sigmoide a traduz de volta para probabilidade.

## Informação: quanto uma notícia surpreende

A teoria da informação mede a **surpresa** de um evento pela sua probabilidade:

```text
informação(x) = −log₂ p(x)    (em bits)
```

| Evento | Probabilidade | Informação |
|--------|---------------|------------|
| Moeda honesta dar cara | 1/2 | **1 bit** |
| Acertar um número de 1 a 8 | 1/8 | **3 bits** |
| Um servidor estável continuar no ar | 0,99 | **0,0145 bit** |

Quanto mais raro, mais informação. Um evento certo (p = 1) não traz informação nenhuma. A unidade **bit** aparece porque, com log na base 2, 1 bit é exatamente a resposta de uma pergunta de sim ou não equilibrada.

## Entropia: a surpresa média

A **entropia** é a informação **média** de uma distribuição, ou seja, o quanto o resultado é imprevisível:

```text
H(p) = − Σ p(x) × log₂ p(x)
```

| Distribuição | Entropia | Leitura |
|--------------|----------|---------|
| Moeda honesta (0,5 / 0,5) | **1 bit** | Máxima incerteza entre dois resultados |
| Moeda viciada (0,9 / 0,1) | **0,469 bit** | Bem mais previsível |
| Quatro resultados iguais (0,25 cada) | **2 bits** | Duas perguntas de sim/não resolvem |
| Resultado certo (1 / 0) | **0** | Nenhuma incerteza |

### Entropia nas árvores de decisão

Na [aula 06](06-trees-naive-bayes-svm.pt-BR.md), a árvore escolhia a pergunta que mais reduzia a impureza de Gini. A entropia é a alternativa clássica, e a redução de entropia tem nome: **ganho de informação**. Os dois critérios costumam escolher perguntas parecidas; o aprofundamento das árvores faz a conta completa.

## Entropia cruzada: o nome verdadeiro da log loss

Quando usamos uma distribuição **q** (o que o modelo prevê) para descrever uma realidade **p** (o rótulo verdadeiro), o custo médio é a **entropia cruzada**:

```text
H(p, q) = − Σ p(x) × log q(x)
```

Num problema de classificação, o rótulo verdadeiro tem probabilidade 1 na classe certa e 0 nas outras. A soma inteira se reduz a um único termo:

```text
H(p, q) = − log q(classe certa)
```

Essa é exatamente a **log loss** da aula 05. Se o modelo deu 0,9 para a classe certa, a perda é `−ln(0,9) = 0,105` (em *nats*, a unidade do logaritmo natural) ou `−log₂(0,9) = 0,152` bit. Treinar um classificador ou um LLM é, literalmente, **minimizar a entropia cruzada** entre as previsões e os dados.

### Divergência KL: o custo extra do modelo errado

A diferença entre a entropia cruzada e a entropia verdadeira é a **divergência de Kullback-Leibler**:

```text
KL(p ‖ q) = H(p, q) − H(p) = Σ p(x) × log₂( p(x) / q(x) )
```

Se a realidade é uma moeda honesta (p = 0,5 / 0,5), mas o modelo acredita que ela é viciada (q = 0,9 / 0,1):

```text
H(p, q) = 1,737 bit    H(p) = 1 bit    KL = 0,737 bit
```

Os 0,737 bit são o **preço de acreditar na distribuição errada**. A KL é zero só quando q = p, e aparece no treino de VAEs ([aula 12](12-diffusion-models.pt-BR.md)) e no alinhamento de LLMs, onde limita o quanto o modelo ajustado pode se afastar do original.

## Perplexidade: "entre quantas opções o modelo hesita?"

A **perplexidade** é a entropia convertida de volta para "número de opções":

```text
perplexidade = 2^H
```

| Distribuição do próximo token | Entropia | Perplexidade | Leitura |
|-------------------------------|----------|--------------|---------|
| Quatro tokens igualmente prováveis | 2 bits | **4** | O modelo hesita entre 4 opções |
| Um token com 90%, outro com 10% | 0,469 bit | **1,38** | Quase decidido |

Num LLM ([aula 11](11-llms.pt-BR.md)), a perplexidade de um texto mede o quanto ele é "natural" para o modelo: texto comum tem perplexidade baixa, sequências estranhas têm perplexidade alta.

> [!TIP]
> **Visão do red teamer**
> 1. **Filtros de perplexidade** barram os sufixos adversariais do tipo GCG ([jailbreaks](../02-prompt-injection/jailbreaks.pt-BR.md)), que são sequências de tokens absurdas e, portanto, de perplexidade altíssima ([defesa em camadas](../08-defense/prompt-injection-defense.pt-BR.md)). A resposta dos atacantes foi buscar sufixos **legíveis**, de perplexidade baixa.
> 2. **Exfiltração por pistas é uma conta de entropia.** Um código de 4 dígitos tem `log₂(10⁴) ≈ 13,3` bits; cada resposta de sim/não revela no máximo 1 bit. Logo, cerca de 14 perguntas bem escolhidas bastam ([injeção direta](../02-prompt-injection/direct-prompt-injection.pt-BR.md)). Filtros que olham só a resposta inteira não percebem o vazamento bit a bit.
> 3. **Loss baixa denuncia dados de treino.** Um modelo costuma ter entropia cruzada menor em exemplos que viu no treino. Ataques de *membership inference* (seção de privacidade) exploram exatamente essa diferença.
> 4. **Adversarial examples maximizam a log loss.** O FGSM da [aula 09](09-neural-networks.pt-BR.md) sobe o gradiente da entropia cruzada em relação à entrada.

## Na prática com Python

```python
import numpy as np

# Underflow: o produto vira zero, a soma de logs não
print(0.1 ** 400)                 # 0.0
print(400 * np.log(0.1))          # -921.03...

def entropia(p):
    p = np.array(p, dtype=float)
    p = p[p > 0]
    return -(p * np.log2(p)).sum()

print(entropia([0.5, 0.5]))                    # 1.0
print(round(entropia([0.9, 0.1]), 3))          # 0.469
print(entropia([0.25] * 4))                    # 2.0

# Entropia cruzada com rótulo verdadeiro = log loss
print(round(-np.log(0.9), 3))                  # 0.105 (nats)

# Divergência KL: moeda honesta descrita como viciada
p, q = np.array([0.5, 0.5]), np.array([0.9, 0.1])
print(round((p * np.log2(p / q)).sum(), 3))    # 0.737

# Perplexidade e exfiltração por pistas
print(round(2 ** entropia([0.9, 0.1]), 2))     # 1.38
print(round(np.log2(10 ** 4), 1))              # 13.3 bits num código de 4 dígitos
```

## Resumo

- **Exponenciais** são sempre positivas e amplificam diferenças, por isso estão na softmax.
- **Logaritmos** transformam produtos em somas e evitam o *underflow*: modelos trabalham com log-probabilidades.
- **Informação** mede surpresa (`−log₂ p`); **entropia** é a surpresa média, a medida de incerteza de uma distribuição.
- A **log loss** é a **entropia cruzada** com rótulo verdadeiro; a **divergência KL** é o custo extra de usar a distribuição errada.
- **Perplexidade** traduz entropia em "número de opções" e é base de filtros contra sufixos adversariais.

## Teste seu entendimento

<details><summary>1. Por que um Naive Bayes ingênuo, que multiplica probabilidades diretamente, pode classificar tudo como "empate" em textos longos?</summary>

Porque o produto de centenas de probabilidades menores que 1 fica menor que o menor número que o computador representa e vira zero (*underflow*). Todas as classes ficam com pontuação 0. Somar log-probabilidades resolve.
</details>

<details><summary>2. Qual distribuição tem mais entropia: um classificador que dá 50% para cada classe ou um que dá 99% para uma delas? O que isso diz sobre confiança?</summary>

O de 50/50 (1 bit, contra cerca de 0,08 bit). Entropia baixa significa que o modelo está **confiante**, o que não quer dizer que esteja certo.
</details>

<details><summary>3. Por que treinar um classificador com log loss é o mesmo que minimizar a entropia cruzada?</summary>

Porque, com o rótulo verdadeiro tendo probabilidade 1 na classe certa, a entropia cruzada se reduz a `−log q(classe certa)`, que é exatamente a log loss.
</details>

<details><summary>4. Um código secreto tem 6 caracteres hexadecimais. Quantas perguntas de sim/não, no mínimo, um atacante precisa para descobri-lo por exfiltração indireta?</summary>

Cada caractere hexadecimal tem 4 bits (16 opções), então o código tem 24 bits. Como cada resposta de sim/não revela no máximo 1 bit, são necessárias pelo menos 24 perguntas bem escolhidas.
</details>

<details><summary>5. Por que um filtro de perplexidade barra sufixos do tipo GCG mas não barra um jailbreak de role-play?</summary>

Os sufixos GCG são sequências de tokens sem sentido, de perplexidade muito alta. Um role-play é escrito em linguagem natural, com perplexidade normal, e passa pelo filtro como qualquer texto comum.
</details>

---

← [04 · Matemática essencial para IA](04-essential-math.pt-BR.md) · **Próxima aula da trilha:** [05 · Regressão linear e logística](05-linear-logistic-regression.pt-BR.md) →

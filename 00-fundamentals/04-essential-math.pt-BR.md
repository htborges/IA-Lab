# 04 · Matemática essencial para IA

> 🇧🇷 Português · 🇺🇸 [English](04-essential-math.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aula 4 de 13 |
| **Tempo de leitura** | ~25 min |
| **Você vai aprender** | A intuição por trás de vetores, matrizes, derivadas, probabilidade e normas, e onde cada uma aparece em ataques a IA |

> [!NOTE]
> **Sem pânico**
> Esta aula não tem demonstrações nem fórmulas complicadas. O objetivo é que você **reconheça** cada conceito quando ele aparecer em um paper, em uma ferramenta ou em um ataque. Todas as contas podem ser feitas na calculadora, e há um bloco de Python no fim para você conferir.

## Por que matemática?

Um modelo de IA é, literalmente, **uma função matemática enorme**. Tudo o que ele recebe (texto, imagem, áudio) vira números, e tudo o que ele faz é operar sobre esses números. Cinco ideias cobrem quase tudo:

| Conceito | Para que serve em IA | Onde aparece em ataques |
|----------|----------------------|-------------------------|
| **Vetores** | Representar dados e significados | Embeddings, RAG, busca por similaridade |
| **Matrizes** | Transformar dados em camadas | Os pesos do modelo, que é o que se rouba ou se envenena |
| **Derivadas e gradientes** | Treinar (ajustar pesos) | Adversarial examples |
| **Probabilidade** | Expressar confiança e incerteza | Confiança do modelo, falsos positivos, membership inference |
| **Normas (distâncias)** | Medir "o quanto mudou" | Orçamento de perturbação de um ataque |

## 1. Vetores: dados viram listas de números

Um **vetor** é uma lista ordenada de números. Um apartamento da aula anterior vira:

```text
apartamento = [50, 2, 3]      # área (m²), quartos, andar
```

Cada posição é uma **dimensão**. Esse vetor tem 3 dimensões. Uma imagem de 28×28 pixels em tons de cinza vira um vetor de 784 números (um por pixel). Em um LLM, cada palavra (ou pedaço de palavra) vira um vetor com centenas ou milhares de dimensões.

### Embeddings: significado como posição

Um **embedding** é um vetor que representa o **significado** de algo. O modelo aprende a colocar coisas parecidas em posições próximas. Um exemplo simplificado com 3 dimensões:

```text
gato     = [0.9, 0.8, 0.1]
cachorro = [0.8, 0.9, 0.2]
carro    = [0.1, 0.2, 0.9]
```

"gato" e "cachorro" apontam para a mesma região, e "carro" aponta para outro lado. Como medir isso?

### Produto escalar e similaridade de cosseno

O **produto escalar** multiplica posição a posição e soma:

```text
[1, 2, 3] · [4, 5, 6] = 1×4 + 2×5 + 3×6 = 4 + 10 + 18 = 32
```

A **similaridade de cosseno** usa o produto escalar para medir o **ângulo** entre dois vetores. O resultado vai de -1 (opostos) a 1 (mesma direção):

```text
similaridade(gato, cachorro) ≈ 0.99   → significados muito próximos
similaridade(gato, carro)    ≈ 0.30   → pouco relacionados
```

> [!TIP]
> **Visão do red teamer**
> É assim que um sistema **RAG** decide quais documentos entregar ao LLM: ele transforma sua pergunta em embedding e busca os documentos com maior similaridade. Se um atacante escrever um documento cujo embedding fica **muito próximo** das perguntas mais comuns, esse documento será recuperado com frequência, levando junto uma prompt injection escondida. Isso é **RAG poisoning** ([seção 05](../05-app-and-system/README.md)).

## 2. Matrizes: transformando dados

Uma **matriz** é uma tabela de números (linhas × colunas). Em IA, a operação mais importante é **multiplicar uma matriz por um vetor**: cada linha da matriz faz um produto escalar com o vetor.

```text
W = | 0.2  0.5  0.1 |      x = [1, 0, 2]
    | 0.4  0.1  0.3 |

W × x = [0.2×1 + 0.5×0 + 0.1×2,  0.4×1 + 0.1×0 + 0.3×2]
      = [0.4, 1.0]
```

O vetor de 3 números virou um vetor de 2 números. Isso é, essencialmente, **uma camada de rede neural**: a matriz `W` contém os **pesos**, e cada camada transforma a representação dos dados em uma nova representação. Um LLM é uma pilha de dezenas de camadas assim, com matrizes gigantes.

> [!TIP]
> **Visão do red teamer**
> Quando se fala em "roubar um modelo" ou em "pesos abertos", estamos falando dessas matrizes. Quem tem os pesos tem o modelo inteiro: pode rodá-lo, estudá-lo e calcular gradientes à vontade (ataque **white-box**). Por isso os arquivos de pesos são ativos valiosos e um vetor de ataque ([seção 04](../04-data-attacks/README.md)).

## 3. Derivadas e gradientes: a direção da mudança

A **derivada** responde: *"se eu mexer um pouquinho na entrada, quanto e para que lado a saída muda?"* É a **inclinação** da função naquele ponto.

Exemplo com `f(x) = x²`:

| x | f(x) | Inclinação (derivada = 2x) | Leitura |
|---|------|----------------------------|---------|
| 3 | 9 | 6 | Subindo forte para a direita |
| 0 | 0 | 0 | Fundo do vale (mínimo) |
| -2 | 4 | -4 | Subindo para a esquerda |

Quando a função tem muitas entradas (um modelo tem milhões de pesos), juntamos todas as derivadas em um vetor chamado **gradiente**. Ele aponta para a direção em que a função **mais cresce**.

### Gradiente descendente com números

Lembra da "montanha no nevoeiro"? Para **minimizar** `f(x) = x²` partindo de `x = 3`, com learning rate `0.1`:

```text
passo 1: inclinação = 6     → x = 3   − 0.1 × 6   = 2.4    → f = 5.76
passo 2: inclinação = 4.8   → x = 2.4 − 0.1 × 4.8 = 1.92   → f ≈ 3.69
...                            x se aproxima de 0, o mínimo
```

Treinar um modelo é exatamente isso, só que `x` são milhões de pesos e `f` é a função de perda.

### Regra da cadeia: como o erro volta pelas camadas

Pense em engrenagens: se A gira 2× mais rápido que B, e B gira 3× mais rápido que C, então A gira 2 × 3 = **6×** mais rápido que C. A **regra da cadeia** faz isso com derivadas: multiplica as inclinações de cada etapa.

O **backpropagation** é a regra da cadeia aplicada camada por camada, de trás para frente: ele calcula quanto cada peso contribuiu para o erro final.

> [!TIP]
> **Visão do red teamer**
> O gradiente pode ser calculado em relação aos **pesos** (para treinar) ou em relação à **entrada** (para atacar). No segundo caso, ele diz exatamente quais pixels ou valores mudar para **aumentar o erro** do modelo. O ataque FGSM faz isso em um único passo: soma à imagem um pequeno ruído na direção do gradiente. É a base da [seção 06](../06-evasion/README.md).

## 4. Probabilidade: confiança e incerteza

Modelos raramente dizem "é X". Eles dizem "é X com 87% de probabilidade".

### Softmax: de pontuações para probabilidades

A última camada de um classificador produz **pontuações** brutas (chamadas *logits*). A função **softmax** as converte em probabilidades que somam 1:

```text
logits:          gato = 2.0    cachorro = 1.0    pássaro = 0.1
exponencial:           7.389              2.718             1.105     (soma = 11.212)
probabilidades:        0.659              0.242             0.099
```

Resultado: **66% gato**, 24% cachorro, 10% pássaro. LLMs fazem o mesmo em cada passo, mas com dezenas de milhares de opções: uma probabilidade para cada token possível.

> [!WARNING]
> **Confiança não é acerto**
> Um modelo pode dar 99% de probabilidade para uma resposta **errada**. Adversarial examples costumam produzir exatamente isso: erro com altíssima confiança. E, se as probabilidades completas forem expostas pela API, elas ajudam o atacante a extrair o modelo ou a descobrir dados de treino.

### Média, variância e normalização

- **Média:** o valor típico. **Variância / desvio padrão:** o quanto os valores se espalham.
- Antes do treino, os dados costumam ser **normalizados** (`z = (x − média) / desvio`) para que nenhuma feature domine as outras só por ter números maiores (área em m² × número de quartos, por exemplo).

### A armadilha da taxa base

Este exemplo é muito relevante para quem trabalha com detecção:

> Um detector de intrusão acerta **99%** dos ataques e só gera alarme falso em **1%** do tráfego normal. Em uma rede com **100 mil eventos**, apenas **100** são ataques.

```text
Ataques reais:   100     → o detector alerta em 99
Eventos normais: 99.900  → 1% de alarme falso = 999 alertas
Total de alertas:          99 + 999 = 1.098

Chance de um alerta ser ataque de verdade: 99 / 1.098 ≈ 9%
```

Um detector "99% preciso" gera alertas que são **falsos em 91% das vezes**. Esse é o raciocínio do **Teorema de Bayes**: a probabilidade final depende muito de quão raro o evento é. Ele volta na aula de Naive Bayes.

## 5. Normas: medindo distâncias e perturbações

Uma **norma** mede o "tamanho" de um vetor, e portanto a **distância** entre dois vetores. Em segurança de IA, ela mede **o quanto um atacante alterou a entrada**. As três mais usadas:

| Norma | O que mede | Em uma imagem alterada |
|-------|------------|------------------------|
| **L2** (euclidiana) | A distância em linha reta | A "energia" total da mudança, somando todos os pixels |
| **L∞** (infinito) | A **maior** mudança individual | Nenhum pixel mudou mais que ε |
| **L0** | **Quantas** posições mudaram | Só alguns poucos pixels foram alterados (ataques esparsos) |

Por exemplo, para a alteração `[0, 0.03, -0.02, 0]`:

```text
L0 = 2           (duas posições mudaram)
L∞ = 0.03        (a maior mudança)
L2 = √(0.03² + 0.02²) ≈ 0.036
```

> [!TIP]
> **Visão do red teamer**
> Papers e ferramentas de adversarial ML (ART, Foolbox) sempre definem o ataque como **"enganar o modelo mudando a entrada no máximo ε em tal norma"**. Um valor clássico em imagens é L∞ com **ε = 8/255**: nenhum pixel muda mais que 8 níveis de 255, uma diferença invisível ao olho humano. Ataques L0 (esparsos) mudam pouquíssimos pixels, mas com força.

## Na prática (Python)

Se quiser conferir as contas desta aula (requer `pip install numpy`):

```python
import numpy as np

# 1. Similaridade de cosseno
gato, cachorro, carro = np.array([0.9, 0.8, 0.1]), np.array([0.8, 0.9, 0.2]), np.array([0.1, 0.2, 0.9])
cos = lambda a, b: a @ b / (np.linalg.norm(a) * np.linalg.norm(b))
print(round(cos(gato, cachorro), 2), round(cos(gato, carro), 2))   # 0.99 0.3

# 2. Uma "camada": matriz × vetor
W = np.array([[0.2, 0.5, 0.1], [0.4, 0.1, 0.3]])
print(W @ np.array([1, 0, 2]))                                       # [0.4 1. ]

# 3. Gradiente descendente em f(x) = x²
x = 3.0
for _ in range(3):
    x -= 0.1 * 2 * x
    print(round(x, 3))                                               # 2.4, 1.92, 1.536

# 4. Softmax
logits = np.array([2.0, 1.0, 0.1])
print(np.round(np.exp(logits) / np.exp(logits).sum(), 3))           # [0.659 0.242 0.099]

# 5. Normas de uma perturbação
d = np.array([0, 0.03, -0.02, 0])
print(np.count_nonzero(d), np.abs(d).max(), round(np.linalg.norm(d), 3))  # 2 0.03 0.036
```

## Resumo

- **Vetores** representam dados e significados. A **similaridade de cosseno** mede o quanto dois significados se parecem e é a base da busca em RAG.
- **Matrizes** são os pesos do modelo, e cada camada é uma multiplicação matriz × vetor.
- **Derivadas e gradientes** mostram a direção da mudança: servem para treinar (ajustando pesos) e para atacar (ajustando a entrada).
- **Probabilidade** expressa confiança, mas confiança alta não é acerto, e a taxa base engana detectores.
- **Normas** medem o tamanho de uma perturbação e definem o "orçamento" de um ataque adversarial.

## Teste seu entendimento

<details><summary>1. Por que dois textos com palavras diferentes podem ser considerados "parecidos" por um sistema RAG?</summary>

Porque a comparação não é feita pelas palavras, e sim pelos **embeddings**. Textos com significado parecido ficam em posições próximas no espaço vetorial e têm alta similaridade de cosseno, mesmo usando palavras diferentes.
</details>

<details><summary>2. Qual a diferença entre usar o gradiente em relação aos pesos e em relação à entrada?</summary>

Em relação aos **pesos**, o gradiente mostra como ajustar o modelo para diminuir o erro (treinamento). Em relação à **entrada**, ele mostra como alterar os dados para aumentar o erro (ataque adversarial).
</details>

<details><summary>3. Um classificador de malware tem 99% de acurácia e 0,5% de falsos positivos. Em um ambiente com 1 malware a cada 10 mil arquivos, os alertas serão confiáveis?</summary>

Não muito. Em 10 mil arquivos: 1 malware (≈1 alerta verdadeiro) e 9.999 limpos × 0,5% ≈ 50 alertas falsos. Só cerca de **1 em cada 51 alertas** (≈2%) seria malware de verdade. É a armadilha da taxa base.
</details>

<details><summary>4. Um ataque altera apenas 5 pixels de uma imagem, mas de forma intensa. Qual norma descreve melhor esse ataque?</summary>

**L0**, que conta quantas posições foram alteradas. É um ataque **esparso**.
</details>

---

← [03 · Como as máquinas aprendem](03-how-machines-learn.pt-BR.md) · **Próxima aula:** [05 · Aprendizado supervisionado I: regressão linear e logística](05-linear-logistic-regression.pt-BR.md) →

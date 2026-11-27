# 07.2 · Detecção de anomalias a fundo

> 🇧🇷 Português · 🇺🇸 [English](07-2-anomaly-detection-deep-dive.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md), [07.1 · Avaliando agrupamentos](07-1-evaluating-clusters.pt-BR.md), [06.2 · SVM e Naive Bayes a fundo](06-2-svm-naive-bayes-deep-dive.pt-BR.md) |
| **Tempo de leitura** | ~30 min |
| **Você vai aprender** | Como funcionam o Isolation Forest, o LOF e o One-Class SVM, por que "longe" depende da densidade local, como escolher o limiar de alerta, e como atacantes escapam de cada detector: combinações incomuns, enxames de eventos e envenenamento do "normal" |

## Onde paramos

A [aula 07](07-unsupervised-learning.pt-BR.md) apresentou três formas de detectar anomalias: distância ao cluster, erro de reconstrução do PCA e Isolation Forest, só citado. O [07.1](07-1-evaluating-clusters.pt-BR.md) mostrou que a escala e a dimensão mudam o que é "perto". Agora vamos por dentro dos três detectores clássicos e, principalmente, entender **onde cada um é cego**.

## Isolation Forest: anomalias se isolam rápido

A ideia é o contrário dos outros métodos: em vez de modelar o normal, o Isolation Forest mede **quão fácil é isolar um ponto** com cortes aleatórios.

Cada árvore escolhe uma feature ao acaso e um valor de corte ao acaso entre o mínimo e o máximo, e repete até cada ponto ficar sozinho. Pontos raros e afastados ficam sozinhos depois de **poucos cortes**; pontos no meio da multidão precisam de **muitos**.

Exemplo numa única feature, com os valores 1, 2, 3, 4, 5 e **50**:

| Ponto | Chance de um único corte aleatório (entre 1 e 50) separá-lo | Leitura |
|-------|-------------------------------------------------------------|---------|
| 50 | (50 − 5) / 49 = **92%** | Quase qualquer corte o isola |
| 3 | 2 / 49 = **4%** (e ainda faltaria separá-lo do outro vizinho) | Precisa de muitos cortes |

### O score

A floresta calcula o **caminho médio** h(x), o número de cortes até isolar o ponto em todas as árvores, e o compara com o caminho esperado para um ponto qualquer numa amostra de n pontos, c(n):

```text
score(x) = 2^( −h(x) / c(n) )        com n = 256, c(n) ≈ 10,2
```

| Caminho médio | Score | Leitura |
|---------------|-------|---------|
| 3 cortes | **0,82** | Perto de 1: anomalia provável |
| 10 cortes | 0,51 | Perto de 0,5: comportamento comum |

Vantagens: é rápido, não precisa de distâncias (escapa da maldição da dimensionalidade do 07.1) e escala para muitos dados.

### O ponto cego: combinações

Os cortes são **alinhados aos eixos**, como os de uma árvore de decisão ([06.1](06-1-decision-trees-deep-dive.pt-BR.md)). Um ponto em que **cada feature, sozinha, é normal**, mas a **combinação** é estranha, como a conexão da aula 07 com poucos pacotes e muito volume, exige muitos cortes para ser isolado e pode passar como comum. Variantes com cortes inclinados (*Extended Isolation Forest*) reduzem esse problema.

## LOF: "longe" depende da vizinhança

O **LOF** (*Local Outlier Factor*) compara a densidade em volta de um ponto com a densidade em volta dos vizinhos dele. A pergunta não é "este ponto está longe?", e sim "**este ponto está mais isolado do que os vizinhos dele costumam estar?**".

### Por que a distância global falha

Uma feature, dois grupos legítimos com densidades bem diferentes, e um ponto suspeito:

| Grupo | Valores | Distância típica até o vizinho mais próximo |
|-------|---------|---------------------------------------------|
| Estações (denso) | 1, 2, 3, 4 | 1 |
| Servidores (esparso) | 100, 110, 120, 130 | 10 |
| Suspeito | **7** | 3 (até o 4) |

Um detector que olhasse só "distância até o vizinho mais próximo" acharia os **servidores** (10) mais estranhos que o **7** (3). Errado: os servidores são esparsos por natureza; o 7 é que está fora do padrão **do grupo de que está perto**.

### Como o LOF calcula

Com k vizinhos (aqui, k = 2):

1. **Densidade local** de cada ponto: o inverso da distância média até os k vizinhos (com um ajuste chamado *distância de alcance*, que suaviza grupos muito apertados).
2. **LOF** de um ponto: a densidade média dos vizinhos dividida pela densidade do próprio ponto.

| LOF | Leitura |
|-----|---------|
| ≈ 1 | Tão denso quanto os vizinhos: normal |
| > 1 | Menos denso que os vizinhos: candidato a anomalia |

No exemplo:

| Ponto | LOF |
|-------|-----|
| 1, 2, 3, 4 (estações) | **1,00** |
| 100, 110, 120, 130 (servidores) | **1,00** |
| 7 (suspeito) | **2,33** |

O LOF trata os dois grupos legítimos como normais, apesar da densidade diferente, e aponta só o 7.

## One-Class SVM: uma fronteira em volta do normal

O **One-Class SVM** usa a ideia da SVM ([06.2](06-2-svm-naive-bayes-deep-dive.pt-BR.md)) com uma única classe: aprende uma fronteira, geralmente com kernel RBF, que **envolve** os dados normais. Tudo o que cai fora da fronteira é anomalia.

| Parâmetro | Efeito |
|-----------|--------|
| **ν** (nu) | Limite para a fração de pontos de treino que podem ficar fora da fronteira. Com ν = 0,05, o modelo aceita deixar até cerca de 5% do treino como "atípico" |
| **γ** | O mesmo do RBF: alto contorna cada ponto (fronteira cheia de recortes); baixo envolve tudo numa forma suave |

É poderoso em poucas dimensões e com dados limpos, mas sensível à escala ([07.1](07-1-evaluating-clusters.pt-BR.md)) e ao que entrou no treino.

## Comparando os detectores

| Detector | Pergunta que faz | Forte em | Fraco em |
|----------|------------------|----------|----------|
| **Distância ao cluster** ([aula 07](07-unsupervised-learning.pt-BR.md)) | Está longe dos centróides? | Simplicidade | Grupos de densidades diferentes |
| **Erro de reconstrução** (PCA, autoencoder) | Respeita as correlações aprendidas? | Combinações incomuns | Ataques que seguem as correlações ([04.2](04-2-linear-algebra.pt-BR.md)) |
| **Isolation Forest** | É fácil de isolar? | Muitos dados, muitas features | Combinações sem valores extremos |
| **LOF** | É menos denso que os vizinhos? | Grupos de densidades diferentes | Enxames; alta dimensão; custo em dados grandes |
| **One-Class SVM** | Está fora da fronteira do normal? | Poucas dimensões, dados limpos | Treino contaminado; escala; ajuste de ν e γ |

Na prática, é comum **combinar** detectores e usar a concordância entre eles como sinal mais forte.

## Escolhendo o limiar

Todo detector devolve um **score**; o alerta depende de onde se corta.

- **Contaminação**: muitas bibliotecas pedem a fração esperada de anomalias e cortam no quantil correspondente. Errar esse número para mais gera alertas falsos; para menos, deixa ataques passarem.
- **Orçamento de alertas**: em operação, a pergunta real é "quantos alertas por dia a equipe consegue investigar?". Avalie com **precisão nos k primeiros** (dos 50 alertas de maior score, quantos eram reais?).
- **Taxa base**: com ataques raros, até um bom detector gera mais falsos positivos que verdadeiros ([aula 04](04-essential-math.pt-BR.md)).

> [!TIP]
> **Visão do red teamer**
> 1. **Contra o Isolation Forest, seja normal em cada feature.** Mantenha cada valor dentro da faixa comum e deixe a estranheza só na **combinação**. Cortes alinhados aos eixos demoram a isolar esse ponto.
> 2. **Contra o LOF, ataque em enxame.** Vários eventos maliciosos parecidos formam um grupinho denso e viram vizinhos uns dos outros. No exemplo, trocando o 7 sozinho por três eventos (6,5, 7 e 7,5), o LOF máximo cai de **2,33** para **1,33**, e os eventos das pontas ficam em 0,87, abaixo do normal. O ataque se esconde em si mesmo.
> 3. **Contra o One-Class SVM, contamine o treino.** Se eventos do atacante entram nos dados usados para aprender o "normal", a fronteira cresce para envolvê-los. Um ν alto facilita ainda mais ([data poisoning](../04-data-attacks/data-poisoning.pt-BR.md)).
> 4. **Mascaramento e inundação.** Muitas anomalias juntas podem esconder umas às outras (*masking*) ou fazer pontos normais parecerem anômalos (*swamping*). Uma onda de ruído barato que gere falsos positivos esgota o orçamento de alertas antes do ataque real.
> 5. **Do lado da defesa,** combine detectores com perguntas diferentes, monitore grupos pequenos e densos que surgem de repente (enxames) e proteja os dados de treino do "normal" como um ativo crítico.

## Na prática com Python

```python
import numpy as np

def lof(xs, k=2):
    xs = np.asarray(xs, float)
    n = len(xs)
    d = np.abs(xs[:, None] - xs[None, :])
    viz = [np.argsort(np.where(np.arange(n) == i, np.inf, d[i]), kind="stable")[:k] for i in range(n)]
    kdist = np.array([d[i, viz[i][-1]] for i in range(n)])
    lrd = np.array([k / sum(max(kdist[o], d[i, o]) for o in viz[i]) for i in range(n)])
    return [round(float(lrd[viz[i]].mean() / lrd[i]), 2) for i in range(n)]

normais = [1, 2, 3, 4, 100, 110, 120, 130]
print(lof(normais + [7]))                  # [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.33]
print(lof(normais + [6.5, 7, 7.5]))        # ... 6.5: 0.87, 7: 1.33, 7.5: 0.87 -> enxame

# Isolation Forest: chance de um corte isolar e o score
print(round(45 / 49, 3), round(2 / 49, 3))                    # 0.918 0.041
c = 2 * (np.log(255) + 0.5772156649) - 2 * 255 / 256          # c(256)
print(round(c, 2), round(2 ** (-3 / c), 3), round(2 ** (-10 / c), 3))   # 10.24 0.816 0.508
```

Na vida real, o scikit-learn tem `IsolationForest(contamination=...)`, `LocalOutlierFactor(n_neighbors=...)` e `OneClassSVM(nu=..., gamma=...)`.

## Resumo

- O **Isolation Forest** mede quantos cortes aleatórios são precisos para isolar um ponto; anomalias se isolam rápido. É cego a combinações sem valores extremos.
- O **LOF** compara a densidade de um ponto com a dos vizinhos, e por isso lida com grupos de densidades diferentes. É cego a enxames.
- O **One-Class SVM** desenha uma fronteira em volta do normal, controlada por **ν** e **γ**. É sensível a treino contaminado.
- Cada detector responde a uma pergunta diferente; combiná-los fortalece o sinal.
- O **limiar** deve refletir o orçamento de alertas e a taxa base, não só a contaminação esperada.
- Para o atacante: normal em cada feature, enxames que se escondem em si mesmos, contaminação do "normal" e inundação de alertas.

## Teste seu entendimento

<details><summary>1. Por que um ponto isolado com poucos cortes recebe score alto no Isolation Forest?</summary>

Porque o score é `2^(−h/c)`: quanto menor o caminho h, mais perto de 1. Poucos cortes significam que o ponto está separado do resto, o que é típico de anomalias.
</details>

<details><summary>2. No exemplo, por que o LOF considera os servidores (100 a 130) normais, mesmo estando a 10 unidades uns dos outros?</summary>

Porque o LOF compara cada ponto com os próprios vizinhos. Os servidores estão tão espaçados quanto os vizinhos deles, então a densidade relativa é 1. O ponto 7 é que está bem menos denso do que o grupo de que está perto.
</details>

<details><summary>3. Um evento malicioso tem cada feature dentro da faixa normal, mas uma combinação que nunca aparece. Qual detector tende a pegá-lo melhor: Isolation Forest padrão ou erro de reconstrução do PCA?</summary>

O erro de reconstrução do PCA, que mede se o ponto respeita as correlações entre as features. O Isolation Forest padrão faz cortes alinhados aos eixos e demora a isolar um ponto sem valores extremos.
</details>

<details><summary>4. Por que três eventos maliciosos parecidos podem passar despercebidos pelo LOF, quando um só seria detectado?</summary>

Porque os três viram vizinhos uns dos outros e formam um grupinho denso. A densidade de cada um passa a ser parecida com a dos vizinhos (os outros eventos maliciosos), e o LOF cai para perto de 1.
</details>

<details><summary>5. O que o parâmetro ν do One-Class SVM controla, e por que um atacante gostaria que ele fosse alto?</summary>

ν limita a fração de pontos de treino que podem ficar fora da fronteira. Com ν alto, o modelo tolera mais pontos atípicos no treino e desenha uma fronteira mais frouxa, o que facilita que eventos do atacante, se estiverem no treino ou perto dele, sejam aceitos como normais.
</details>

---

← [07.1 · Avaliando agrupamentos](07-1-evaluating-clusters.pt-BR.md) · **Próxima aula da trilha:** [08 · Aprendizado por reforço](08-reinforcement-learning.pt-BR.md) →

# 07.1 · Avaliando agrupamentos

> 🇧🇷 Português · 🇺🇸 [English](07-1-evaluating-clusters.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md), [04 · Matemática essencial](04-essential-math.pt-BR.md) |
| **Tempo de leitura** | ~25 min |
| **Você vai aprender** | Por que a escala das features decide quem é "parecido", como escolher entre distância euclidiana, Manhattan e cosseno, como a silhueta mede a qualidade de um agrupamento, por que o K-Means sempre encontra grupos, o que é a maldição da dimensionalidade, e como tudo isso ajuda um atacante a se esconder num cluster benigno |

## Onde paramos

Na [aula 07](07-unsupervised-learning.pt-BR.md), o K-Means separou 6 hosts em "estações" e "servidores", e avisamos que normalizar as features era obrigatório. Também usamos o método do cotovelo para escolher k. Mas sem rótulos, como saber se o agrupamento é **bom**? E por que a escala importa tanto? Este aprofundamento responde com números.

## A escala decide quem é parecido

Três hosts, descritos pelo **volume enviado** e pelo **número de portas distintas**:

| Host | Volume | Portas |
|------|--------|--------|
| A | 500 KB | 3 |
| B | 520 KB | 80 |
| C | 900 KB | 4 |

Quem é o vizinho mais próximo de A? Depende da **unidade** do volume:

| Volume medido em | Distância A–B | Distância A–C | Vizinho de A |
|------------------|---------------|---------------|--------------|
| KB | 79,6 | 400,0 | **B** |
| MB | 77,0 | 1,08 | **C** |

**Os mesmos dados, só com outra unidade, dão outra resposta.** Em KB, o volume domina a distância e B (que varre 80 portas) parece gêmeo de A. Em MB, são as portas que dominam. Nenhuma das duas escolhas é "correta"; ambas são **acidentais**.

A solução é colocar todas as features numa escala comparável antes de medir distâncias:

| Técnica | Como funciona | Cuidado |
|---------|---------------|---------|
| **Padronização** (*z-score*) | `(x − média) / desvio`: cada feature fica com média 0 e desvio 1 | Sensível a outliers, que inflam o desvio |
| **Min-max** | `(x − mín) / (máx − mín)`: cada feature vai para o intervalo [0, 1] | Um único valor extremo comprime todos os outros |
| **Escala robusta** | Usa mediana e intervalo interquartil em vez de média e desvio | Mais estável quando há outliers |
| **Log** ([04.1](04-1-logs-and-entropy.pt-BR.md)) | Comprime features que variam em ordens de grandeza (bytes, contagens) | Só para valores positivos |

Assim como no [03.1](03-1-evaluation-regularization.pt-BR.md), a escala deve ser ajustada só com os dados de treino.

## Qual distância usar

Dois hosts com o **mesmo perfil** de tráfego, mas volumes diferentes: x = (3, 4) e y = (6, 8), em que y faz exatamente o dobro de tudo.

| Distância | Fórmula | Valor | Leitura |
|-----------|---------|-------|---------|
| **Euclidiana** | `√Σ (xᵢ − yᵢ)²` | 5,0 | "Bem diferentes": olha a distância em linha reta |
| **Manhattan** | `Σ \|xᵢ − yᵢ\|` | 7 | Soma as diferenças em cada eixo; menos sensível a uma única feature muito diferente |
| **Cosseno** ([aula 04](04-essential-math.pt-BR.md)) | `1 − cos(x, y)` | 0 (similaridade 1,0) | "Idênticos": só olha a **direção**, ignora o tamanho |

A escolha depende do que importa: o **volume** (euclidiana) ou a **proporção** entre as features (cosseno). Para textos e embeddings, o cosseno é o padrão ([aula 13](13-ai-systems.pt-BR.md)); para métricas de rede, costuma-se usar a euclidiana sobre features padronizadas.

## Silhueta: o agrupamento ficou bom?

Sem rótulos, a qualidade de um agrupamento se mede pela pergunta: **cada ponto está mais perto do seu grupo do que do grupo vizinho?** Para cada ponto i:

```text
a = distância média até os outros pontos do próprio grupo
b = distância média até os pontos do grupo vizinho mais próximo
silhueta(i) = (b − a) / máx(a, b)
```

| Silhueta | Significado |
|----------|-------------|
| Perto de **+1** | Bem dentro do próprio grupo, longe dos outros |
| Perto de **0** | Na fronteira entre dois grupos |
| **Negativa** | Provavelmente no grupo errado |

### Com os 6 hosts da aula 07

| Agrupamento | Silhueta média | Destaques |
|-------------|----------------|-----------|
| {A, B, C} e {D, E, F} (o do K-Means) | **0,82** | A: 0,84 · B: 0,85 · D: 0,80 |
| {A, B, D} e {C, E, F} (misturado de propósito) | **−0,02** | D: −0,56 · C: −0,58, os dois no grupo errado |

A silhueta média também ajuda a escolher k: compare a média para k = 2, 3, 4… e fique com o maior valor. É um complemento ao método do cotovelo.

### O host suspeito

O host G = (9, 2) da aula 07, se fosse colocado no grupo das estações, teria `a = 6,71` e `b = 7,04`:

```text
silhueta(G) = (7,04 − 6,71) / 7,04 ≈ 0,05
```

Quase zero: G não pertence de verdade a nenhum grupo. **Pontos com silhueta baixa ou negativa são candidatos naturais a anomalia.**

## O K-Means sempre encontra grupos

O K-Means devolve **k grupos** mesmo quando os dados são completamente aleatórios, sem estrutura nenhuma. Por isso, antes de interpretar clusters:

- verifique a **tendência de agrupamento**: existem grupos de verdade? (estatísticas como a de Hopkins comparam os dados com pontos aleatórios uniformes);
- confira a **silhueta** e a **estabilidade**: se rodar de novo com outra inicialização ou outra amostra, os grupos se mantêm?
- valide com **conhecimento do domínio**: os grupos fazem sentido para um analista?

## A maldição da dimensionalidade

Com muitas features, distâncias se comportam de forma pouco intuitiva. Um jeito de enxergar: num cubo com lado 1, a fração do volume que fica **longe das bordas** (no "miolo" de 90% em cada dimensão) é `0,9^d`:

| Dimensões d | Fração no miolo |
|-------------|-----------------|
| 2 | 81% |
| 10 | 35% |
| 100 | 0,003% |

Em 100 dimensões, praticamente todo ponto está "perto de alguma borda", e as distâncias entre pontos aleatórios ficam todas parecidas: o vizinho mais próximo e o mais distante quase empatam. Agrupamentos e detectores por distância perdem poder de discriminação.

Por isso, em dados com muitas features, é comum **reduzir a dimensionalidade** antes de agrupar (PCA, [04.2](04-2-linear-algebra.pt-BR.md)). Muitas vezes os dados têm uma **dimensionalidade intrínseca** bem menor que o número de colunas: na aula 07, duas features eram, na prática, uma só (99,9% da variância num componente).

> [!TIP]
> **Visão do red teamer**
> 1. **Mexa na feature que domina a distância.** Se o detector não padroniza as features, a de maior escala decide tudo. Ajustar essa feature, por exemplo o volume, coloca o host no cluster benigno mesmo com comportamento estranho nas outras.
> 2. **Cosseno ignora volume.** Um detector baseado em similaridade de cosseno vê um perfil de tráfego dez vezes maior, na mesma proporção, como idêntico ao normal. Exfiltração que mantém a proporção entre as features passa.
> 3. **Busque silhueta alta no grupo certo.** Para se esconder, não basta estar "perto" de um cluster benigno: é preciso estar **mais perto dele do que de qualquer outro**. Monitorar a silhueta dos pontos novos é uma defesa barata.
> 4. **Clusters de famílias de malware podem ser artefatos.** O K-Means sempre devolve k grupos. Atribuições de autoria ou campanha baseadas só em clusters, sem validação, podem ser contestadas ou manipuladas.
> 5. **Mais features não é mais segurança.** Em alta dimensão, as distâncias se concentram e anomalias se diluem; o atacante tem mais espaço para se esconder.

## Na prática com Python

```python
import numpy as np

dist = lambda a, b: round(float(np.linalg.norm(np.array(a) - np.array(b))), 2)

# A unidade muda o vizinho mais próximo
print(dist([500, 3], [520, 80]), dist([500, 3], [900, 4]))         # 79.6 400.0 (KB)
print(dist([0.5, 3], [0.52, 80]), dist([0.5, 3], [0.9, 4]))        # 77.0 1.08  (MB)

# Euclidiana, Manhattan e cosseno
x, y = np.array([3, 4]), np.array([6, 8])
cos = x @ y / (np.linalg.norm(x) * np.linalg.norm(y))
print(np.linalg.norm(x - y), np.abs(x - y).sum(), round(float(cos), 3))   # 5.0 7 1.0

# Silhueta média
P = {"A": (2, 1), "B": (3, 2), "C": (2, 3), "D": (9, 8), "E": (10, 9), "F": (8, 10)}

def silhueta(grupos):
    total = []
    for g in grupos:
        for p in g:
            a = np.mean([dist(P[p], P[q]) for q in g if q != p])
            b = min(np.mean([dist(P[p], P[q]) for q in h]) for h in grupos if h is not g)
            total.append((b - a) / max(a, b))
    return round(float(np.mean(total)), 2)

print(silhueta([["A", "B", "C"], ["D", "E", "F"]]))   # 0.82
print(silhueta([["A", "B", "D"], ["C", "E", "F"]]))   # -0.02

# Maldição da dimensionalidade
print([round(0.9 ** d, 6) for d in (2, 10, 100)])     # [0.81, 0.348678, 2.7e-05]
```

Na vida real, use `StandardScaler` ou `RobustScaler` e `silhouette_score` do scikit-learn, sempre dentro de um `Pipeline`.

## Resumo

- Sem padronização, a **unidade** de uma feature decide quem é parecido; padronize, normalize ou use escala robusta.
- **Euclidiana** mede distância em linha reta, **Manhattan** soma por eixo e **cosseno** só olha a direção; a escolha depende do que importa no problema.
- A **silhueta** compara a distância ao próprio grupo com a distância ao vizinho: perto de 1 é bom, perto de 0 é fronteira, negativa é grupo errado.
- O K-Means **sempre** encontra k grupos; verifique tendência, estabilidade e sentido no domínio.
- Em **alta dimensão**, as distâncias perdem contraste; reduza a dimensionalidade antes de agrupar.
- Para o atacante: feature dominante, cosseno cego ao volume, silhueta alta no cluster benigno e alta dimensão como esconderijo.

## Teste seu entendimento

<details><summary>1. Por que medir o volume em KB ou em MB mudou o vizinho mais próximo de A?</summary>

Porque, sem padronização, a feature com números maiores domina a distância. Em KB, as diferenças de volume (centenas) superam as de portas (dezenas); em MB, acontece o contrário. A escolha da unidade virou, sem querer, uma escolha de peso.
</details>

<details><summary>2. Dois hosts têm similaridade de cosseno 1,0, mas distância euclidiana grande. O que isso diz sobre eles?</summary>

Que têm o mesmo **perfil** (mesma proporção entre as features), mas volumes diferentes: um faz o mesmo que o outro, em escala maior.
</details>

<details><summary>3. Um ponto tem silhueta −0,4. O que isso indica e o que você faria?</summary>

Que ele está, em média, mais perto de outro grupo do que do próprio: provavelmente foi atribuído ao grupo errado ou é uma anomalia. Vale investigar o ponto e revisar o número de grupos ou as features.
</details>

<details><summary>4. Você roda o K-Means com k = 5 em dados de logs e obtém cinco grupos. Isso prova que existem cinco tipos de comportamento?</summary>

Não. O K-Means sempre devolve k grupos, mesmo em dados sem estrutura. É preciso verificar a tendência de agrupamento, a silhueta, a estabilidade dos grupos e se eles fazem sentido para quem conhece o ambiente.
</details>

<details><summary>5. Por que um detector de anomalias por distância tende a funcionar pior com 200 features do que com 10?</summary>

Pela maldição da dimensionalidade: em alta dimensão, as distâncias entre os pontos ficam todas parecidas, e a diferença entre "perto" e "longe" diminui. Anomalias deixam de se destacar. Reduzir a dimensionalidade antes ajuda.
</details>

---

← [07 · Aprendizado não supervisionado](07-unsupervised-learning.pt-BR.md) · **Próximo:** [07.2 · Detecção de anomalias a fundo](07-2-anomaly-detection-deep-dive.pt-BR.md) →

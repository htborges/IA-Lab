# 03.1 · Avaliação e regularização

> 🇧🇷 Português · 🇺🇸 [English](03-1-evaluation-regularization.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [03 · Como as máquinas aprendem](03-how-machines-learn.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [03 · Como as máquinas aprendem](03-how-machines-learn.pt-BR.md) (ajuda ter lido a [05 · Regressão linear e logística](05-linear-logistic-regression.pt-BR.md)) |
| **Tempo de leitura** | ~25 min |
| **Você vai aprender** | O que são viés e variância, como a validação cruzada dá uma estimativa mais honesta do desempenho, como escolher a divisão certa para dados de segurança, como L1 e L2 freiam o overfitting, e por que avaliações infladas escondem fraquezas que o atacante encontra |

## Onde paramos

Na [aula 03](03-how-machines-learn.pt-BR.md) dividimos o dataset em treino, validação e teste, e vimos underfitting e overfitting. Ficaram três perguntas: uma única divisão aleatória é suficiente para confiar no número? Que divisão faz sentido quando os dados são logs, malware ou e-mails? E como **impedir** o overfitting, além de só detectá-lo?

## Viés e variância

Os dois tipos de erro de generalização têm nome:

| | Viés alto | Variância alta |
|-|-----------|----------------|
| **O que é** | O modelo é simples demais e erra de forma sistemática | O modelo é sensível demais aos detalhes do treino e muda muito com dados ligeiramente diferentes |
| **Sintoma** | Erro alto no treino e na validação | Erro baixo no treino, alto na validação |
| **Nome na aula 03** | Underfitting | Overfitting |
| **Analogia** | Um atirador que sempre acerta o mesmo ponto, fora do alvo | Um atirador que acerta em volta do alvo, mas espalhado |

Aumentar a capacidade do modelo reduz o viés e aumenta a variância; regularizar faz o contrário. O objetivo é o ponto de equilíbrio, e a forma de encontrá-lo é **medir bem**.

## Validação cruzada

Com uma única divisão treino/validação, o resultado depende da sorte de quais exemplos caíram em cada lado. A **validação cruzada k-fold** reduz essa sorte:

1. Divida os dados em **k partes** (*folds*), por exemplo 5.
2. Treine k vezes: em cada rodada, uma parte fica de validação e as outras k − 1 treinam.
3. Reporte a **média** e o **desvio** dos k resultados.

| Rodada | Parte 1 | Parte 2 | Parte 3 | Parte 4 | Parte 5 |
|--------|---------|---------|---------|---------|---------|
| 1 | **validação** | treino | treino | treino | treino |
| 2 | treino | **validação** | treino | treino | treino |
| 3 | treino | treino | **validação** | treino | treino |
| 4 | treino | treino | treino | **validação** | treino |
| 5 | treino | treino | treino | treino | **validação** |

Cada exemplo é usado para validar exatamente uma vez.

Exemplo com 5 folds e as acurácias de validação de cada rodada:

| Fold | 1 | 2 | 3 | 4 | 5 |
|------|---|---|---|---|---|
| Acurácia | 0,82 | 0,85 | 0,79 | 0,88 | 0,81 |

```text
média = 0,83      desvio padrão ≈ 0,03
```

O desvio importa tanto quanto a média: ele diz o quanto o resultado **oscila** conforme os dados. Um modelo com 0,83 ± 0,03 é bem diferente de um com 0,83 ± 0,15.

> [!NOTE]
> **E o conjunto de teste?**
> A validação cruzada serve para escolher modelos e hiperparâmetros. O conjunto de teste continua separado e é usado **uma única vez**, no fim. Se você ajusta o modelo olhando o teste, ele vira validação e deixa de medir generalização.

### Escolhendo a divisão certa

Dividir aleatoriamente supõe que os exemplos são independentes e vêm da mesma distribuição. Em segurança, isso quase nunca é verdade:

| Divisão | Como funciona | Quando usar |
|---------|---------------|-------------|
| **Aleatória** | Sorteia os exemplos entre os folds | Dados realmente independentes |
| **Estratificada** | Mantém a proporção de cada classe em todos os folds | Classes desbalanceadas, como 1% de ataques: sem isso, um fold pode não ter nenhum ataque |
| **Temporal** | Treina com o passado e valida com o futuro, nunca o contrário | Logs, tráfego, fraude, qualquer dado em que o comportamento muda com o tempo |
| **Por grupo** | Todos os exemplos de um mesmo grupo (usuário, host, família de malware, campanha de phishing) ficam do mesmo lado | Quando exemplos do mesmo grupo são parecidos entre si |

## Vazamento na avaliação

O **vazamento** (*data leakage*) acontece quando informação que o modelo não teria em produção entra no treino ou na avaliação. O resultado é um número bonito e falso. Os casos mais comuns:

| Vazamento | Exemplo |
|-----------|---------|
| **Grupo** | Variantes da mesma família de malware no treino e no teste: o modelo reconhece a família, não o comportamento malicioso |
| **Temporal** | Divisão aleatória em dados de logs: o modelo "vê o futuro" e aprende padrões que ainda não existiam na data simulada |
| **Pré-processamento** | Normalizar ou selecionar features usando o dataset inteiro **antes** de dividir: estatísticas do teste vazam para o treino |
| **Duplicatas** | O mesmo e-mail ou arquivo (ou quase o mesmo) dos dois lados da divisão |
| **Feature atalho** | Um campo que só existe por causa do rótulo, como a pasta de origem dos arquivos ([06.1](06-1-decision-trees-deep-dive.pt-BR.md)) |

Um exemplo hipotético do efeito, para um detector de malware:

| Divisão usada na avaliação | Acurácia reportada |
|----------------------------|-------------------|
| Aleatória (famílias misturadas) | 99% |
| Por família (famílias novas no teste) | 85% |
| Temporal (amostras mais recentes no teste) | 80% |

O número que interessa é o de baixo: é o que se aproxima do que o modelo vai enfrentar contra **amostras novas**.

## Regularização: freando o overfitting

A regularização acrescenta à perda uma **penalidade pelo tamanho dos pesos**, para o modelo preferir soluções mais simples:

```text
perda total = perda nos dados + λ × penalidade(pesos)
```

O hiperparâmetro **λ** (lambda) controla a força do freio.

| Tipo | Penalidade | Efeito |
|------|------------|--------|
| **L2** (ridge, *weight decay*) | λ × Σ w² | Encolhe todos os pesos, mas raramente os zera |
| **L1** (lasso) | λ × Σ \|w\| | Encolhe e **zera** pesos pequenos: faz seleção de features |
| **Elastic net** | Combinação das duas | Meio-termo |

### Um exemplo com números

Imagine um único peso, cujo valor ideal sem regularização seria **4**. Com a perda `(w − 4)²` mais a penalidade:

| λ | Peso com L2 | Peso com L1 |
|---|-------------|-------------|
| 0 | 4,0 | 4,0 |
| 1 | 2,0 | 3,5 |
| 2 | 1,33 | 3,0 |
| 3 | 1,0 | 2,5 |
| 8 | 0,44 | **0** |

```text
L2:  w = 4 / (1 + λ)            nunca chega a zero
L1:  w = máx(0, 4 − λ/2)        chega a zero quando λ ≥ 8
```

A L2 puxa o peso para perto de zero com cada vez menos força; a L1 puxa com força constante e o **zera**. Com muitas features, a L1 elimina as menos úteis, e o modelo fica esparso.

As outras formas de regularização já vistas na trilha seguem a mesma ideia de limitar a complexidade: **dropout** e **early stopping** ([aula 09](09-neural-networks.pt-BR.md) e [09.1](09-1-training-neural-networks.pt-BR.md)), **profundidade máxima e poda** nas árvores ([06.1](06-1-decision-trees-deep-dive.pt-BR.md)). O valor de λ, como todo hiperparâmetro, é escolhido pela **validação cruzada**.

## Deriva: quando o mundo muda

Mesmo uma avaliação perfeita vale para os dados daquele momento. Com o tempo, a distribuição muda (*concept drift*): novos softwares, novos hábitos de usuários, novas campanhas. Em segurança, existe ainda a **deriva adversarial**: os atacantes mudam **porque** o modelo os detecta. Por isso modelos de detecção precisam de monitoramento contínuo e reavaliação com dados recentes.

> [!TIP]
> **Visão do red teamer**
> 1. **Desconfie de métricas altas.** Pergunte como a avaliação foi dividida. Um detector avaliado com divisão aleatória, com famílias ou campanhas misturadas, costuma ser bem mais fraco contra amostras novas, e é exatamente isso que um atacante traz.
> 2. **Avaliação limpa não é avaliação adversarial.** Acurácia em dados normais não diz nada sobre robustez. Peça a **acurácia sob ataque**, medida contra um atacante que conhece o modelo e se adapta.
> 3. **Regularização também é defesa de privacidade.** Modelos com menos overfitting memorizam menos exemplos e vazam menos em ataques de *membership inference* ([09.1](09-1-training-neural-networks.pt-BR.md)).
> 4. **Modelos esparsos têm poucos pontos de apoio.** Um modelo L1 que depende de poucas features é mais fácil de explicar, mas o atacante também só precisa mexer nessas poucas features ([evasão em modelos lineares](05-linear-logistic-regression.pt-BR.md)).
> 5. **Deriva é janela de oportunidade.** Entre o surgimento de uma técnica nova e o re-treino do modelo, ela passa sem ser vista.

## Na prática com Python

```python
import numpy as np

# Validação cruzada: média e desvio dos folds
acuracias = np.array([0.82, 0.85, 0.79, 0.88, 0.81])
print(round(acuracias.mean(), 3), round(acuracias.std(), 3))   # 0.83 0.032

# Regularização em um peso cujo valor ideal é 4
w = np.arange(-10000, 50001) / 10000   # de -1 a 5, passo 0.0001 (inclui o zero exato)
for lam in (1, 3, 8):
    l2 = w[np.argmin((w - 4) ** 2 + lam * w ** 2)]
    l1 = w[np.argmin((w - 4) ** 2 + lam * np.abs(w))]
    print(lam, round(l2, 2), round(l1, 2))
# 1 2.0 3.5
# 3 1.0 2.5
# 8 0.44 0.0

# Divisão temporal: treinar com o passado, validar com o futuro
dias = np.arange(100)                  # índice de tempo de cada exemplo
treino, validacao = dias[dias < 80], dias[dias >= 80]
print(treino.max() < validacao.min())  # True: nada do futuro no treino
```

Na vida real, o scikit-learn tem `cross_val_score`, `StratifiedKFold`, `TimeSeriesSplit` e `GroupKFold`, e os modelos `Ridge`, `Lasso` e `LogisticRegression(penalty="l1" ou "l2")`. Use `Pipeline` para que o pré-processamento seja ajustado só no treino de cada fold.

## Resumo

- **Viés** é erro sistemático (underfitting); **variância** é sensibilidade demais ao treino (overfitting).
- A **validação cruzada k-fold** dá média e desvio, uma estimativa mais honesta que uma divisão única; o teste continua intocado até o fim.
- Em segurança, prefira divisões **estratificadas, temporais e por grupo**; divisões aleatórias inflam o resultado.
- **Vazamento** (grupo, tempo, pré-processamento, duplicatas, atalhos) produz números bonitos e falsos.
- **L2** encolhe os pesos; **L1** zera os menos úteis; λ é escolhido por validação cruzada.
- Para o red teamer: métricas infladas e avaliações sem atacante escondem fraquezas; regularização ajuda na privacidade; deriva abre janelas.

## Teste seu entendimento

<details><summary>1. Um modelo tem erro de 30% no treino e 31% na validação. Viés ou variância alta? O que tentar?</summary>

Viés alto (underfitting): o erro é alto nos dois e quase igual. Tente um modelo com mais capacidade, mais features ou menos regularização.
</details>

<details><summary>2. Por que a validação cruzada reporta também o desvio padrão, e não só a média?</summary>

Porque o desvio mostra o quanto o desempenho varia conforme os dados usados. Uma média boa com desvio alto indica um modelo instável, cujo desempenho em produção é imprevisível.
</details>

<details><summary>3. Você avalia um detector de malware com divisão aleatória e obtém 99%. Que divisão você pediria para refazer a avaliação, e por quê?</summary>

Por família (e, se possível, temporal). Com divisão aleatória, variantes da mesma família ficam no treino e no teste, e o modelo pode estar só reconhecendo famílias conhecidas. A divisão por família mede a capacidade de detectar malware novo.
</details>

<details><summary>4. Qual a diferença prática entre L1 e L2 no exemplo da página com λ = 8?</summary>

A L2 deixou o peso em cerca de 0,44: encolhido, mas ainda presente. A L1 zerou o peso, eliminando a feature do modelo. A L1 faz seleção de features; a L2 não.
</details>

<details><summary>5. Por que normalizar as features com o dataset inteiro antes de dividir em treino e teste é um vazamento?</summary>

Porque a média e o desvio usados na normalização foram calculados com os dados de teste também. Informação do teste entra no treino, e a avaliação fica otimista. O pré-processamento deve ser ajustado só nos dados de treino de cada divisão.
</details>

---

← [03 · Como as máquinas aprendem](03-how-machines-learn.pt-BR.md) · **Próxima aula da trilha:** [04 · Matemática essencial para IA](04-essential-math.pt-BR.md) →

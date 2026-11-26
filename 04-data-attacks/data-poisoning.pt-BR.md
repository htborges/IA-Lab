# Data Poisoning

> 🇧🇷 Português · 🇺🇸 [English](data-poisoning.md)

| Campo | Valor |
|-------|-------|
| **Categoria** | Dados |
| **OWASP LLM Top 10** | LLM04:2025 Data and Model Poisoning |
| **MITRE ATLAS** | AML.T0020 Poison Training Data |
| **Alvo** | Qualquer modelo treinado ou re-treinado com dados que o atacante influencia: classificadores, detectores de anomalia, LLMs (pré-treino, fine-tuning, feedback) |
| **Acesso do atacante** | Escrita em alguma fonte de dados de treino. Não precisa de acesso ao modelo |
| **Severidade** | Média a Crítica (depende do que o modelo decide e de quanto tempo o envenenamento passa despercebido) |
| **Lab** | Exemplo numérico e código nesta página |
| **Pré-requisitos** | Aula [03 · Como as máquinas aprendem](../00-fundamentals/03-how-machines-learn.pt-BR.md), Aula [05 · Regressão linear e logística](../00-fundamentals/05-linear-logistic-regression.pt-BR.md) |

## TL;DR

O atacante insere ou altera exemplos de treino para mudar o que o modelo aprende: piorar o modelo em geral, ou fazê-lo errar **num caso específico** que interessa ao atacante. O modelo resultante parece normal e passa nas métricas, porque os dados de avaliação costumam vir da mesma fonte envenenada.

## Conceito

### Objetivos do atacante

| Objetivo | O que acontece | Exemplo |
|----------|----------------|---------|
| **Disponibilidade** | A qualidade do modelo cai para todo mundo | Um filtro de spam passa a errar tanto que é desligado |
| **Integridade direcionada** | O modelo continua bom, mas erra **entradas escolhidas** | A família de malware do atacante passa a ser classificada como benigna |
| **Backdoor** | O modelo erra só quando a entrada tem um **gatilho** | Tem página própria: [backdoors em modelos](model-backdoors.pt-BR.md) |

### Métodos

| Método | Como funciona |
|--------|---------------|
| **Label flipping** | Trocar o rótulo de exemplos existentes (marcar malware como benigno) |
| **Injeção de exemplos** | Adicionar exemplos novos, com o rótulo que o atacante quer, perto da região que ele quer mudar |
| **Clean-label** | Exemplos com rótulo **correto**, mas com features construídas para deslocar a fronteira. Passam por revisão humana dos rótulos |
| **Envenenamento gradual** | Pequenas doses a cada re-treino, para mudar o "normal" aos poucos ([aula 07](../00-fundamentals/07-unsupervised-learning.pt-BR.md)) |

### Onde o atacante escreve

- **Feedback de usuários**: botões "isso é spam / não é spam", correções, avaliações de respostas usadas para re-treino.
- **Dados públicos e scraping**: páginas web, wikis, repositórios de código, fóruns. Pesquisas mostraram ser viável envenenar datasets em escala web, por exemplo comprando domínios expirados que ainda constam nas listas de URLs de um dataset.
- **Rotulagem terceirizada**: plataformas de crowdsourcing ou fornecedores de rótulos.
- **Fine-tuning de LLMs**: datasets de instruções e de preferências compartilhados em hubs públicos. Um estudo de 2025 indicou que algumas centenas de documentos maliciosos bastaram para implantar um comportamento em LLMs de vários tamanhos: o que importa é o **número absoluto** de exemplos, não a proporção do dataset.
- **Bases de RAG**: não muda os pesos, mas o efeito é parecido em tempo de inferência ([injeção indireta](../02-prompt-injection/indirect-prompt-injection.pt-BR.md)).

## Superfície de Ataque e Pré-requisitos

- O sistema treina ou re-treina com dados que o atacante consegue influenciar
- Não há rastreabilidade da origem de cada exemplo nem revisão antes do treino
- A avaliação usa dados da mesma fonte, e não um conjunto confiável separado

## Exploração

### Um exemplo com números

Um detector classifica arquivos por uma pontuação de suspeita, usando o método mais simples possível: calcula a **média** de cada classe e põe o limiar no meio.

| Classe | Pontuações no treino | Média |
|--------|---------------------|-------|
| Benigno | 1, 2, 3, 4 | 2,5 |
| Malicioso | 7, 8, 9, 10 | 8,5 |

```text
limiar = (2,5 + 8,5) / 2 = 5,5   → acima de 5,5 é malicioso
```

O malware do atacante tem pontuação **7**: detectado. Ele consegue enviar amostras pelo canal de "falso positivo" que os clientes usam para reportar erros, e reporta **4 arquivos com pontuação 10** como benignos:

| Classe | Pontuações no treino | Média |
|--------|---------------------|-------|
| Benigno (envenenado) | 1, 2, 3, 4, 10, 10, 10, 10 | 6,25 |
| Malicioso | 7, 8, 9, 10 | 8,5 |

```text
novo limiar = (6,25 + 8,5) / 2 = 7,375   → o malware com pontuação 7 agora passa
```

Quatro exemplos bastaram. O detector continua pegando os malwares de pontuação 8, 9 e 10, então as métricas gerais mal mudam, e ninguém percebe que **aquele** malware passou a ser liberado.

### O mesmo efeito em código

```python
import numpy as np

def treinar(benigno, malicioso):
    return (np.mean(benigno) + np.mean(malicioso)) / 2

benigno, malicioso = [1, 2, 3, 4], [7, 8, 9, 10]
print(treinar(benigno, malicioso))                   # 5.5
print(treinar(benigno + [10] * 4, malicioso))        # 7.375

alvo = 7
for limiar in (5.5, 7.375):
    print(limiar, "detectado" if alvo > limiar else "liberado")
# 5.5 detectado
# 7.375 liberado
```

Num modelo real (regressão logística, árvores, redes), o mecanismo é o mesmo, com mais dimensões: os pontos envenenados puxam a fronteira de decisão ([aulas 05](../00-fundamentals/05-linear-logistic-regression.pt-BR.md) e [06](../00-fundamentals/06-trees-naive-bayes-svm.pt-BR.md)).

### Num teste autorizado

1. Mapeie os **caminhos de escrita** nos dados de treino e a frequência de re-treino.
2. Combine com o cliente um **objetivo inofensivo e verificável** (por exemplo, uma amostra de teste específica que deve passar a ser classificada errado).
3. Injete o **mínimo** de exemplos pelo caminho real e meça após o re-treino, num ambiente de homologação.
4. Reporte quantos exemplos foram necessários e se algum controle (revisão, detecção de outliers) percebeu.

## Variações

- **Envenenamento de preferências (RLHF)**: avaliações falsas ensinam o modelo a preferir respostas com certo viés.
- **Envenenamento de embeddings**: documentos que distorcem o espaço vetorial de um sistema de busca.
- **Envenenamento de código**: repositórios públicos com padrões inseguros que modelos de código aprendem a sugerir.
- **Envenenamento de detectores não supervisionados**: o "sapo na panela" da [aula 07](../00-fundamentals/07-unsupervised-learning.pt-BR.md).

## Detecção

- **Proveniência**: saber de onde veio cada exemplo (fonte, data, usuário) permite isolar e remover lotes suspeitos.
- **Detecção de outliers nos dados de treino**: exemplos muito distantes do resto da própria classe (como os "benignos" com pontuação 10).
- **Consistência de rótulos**: comparar o rótulo de cada exemplo com o que um modelo treinado em dados confiáveis prevê.
- **Conjunto de avaliação confiável e separado**, nunca alimentado pelos mesmos canais do treino.
- **Monitoramento por classe e por segmento**: quedas localizadas de recall, não só a métrica geral.
- **Diff entre versões do dataset** antes de cada re-treino.

## Mitigação

| Controle | Camada | Eficácia |
|----------|--------|----------|
| Proveniência e versionamento dos dados (snapshots com hash) | Dados | Alta |
| Revisão e limites para dados vindos de usuários (taxa, reputação, amostragem humana) | Dados | Alta |
| Conjunto de avaliação confiável e testes de regressão com casos críticos | Avaliação | Alta |
| Sanitização: remoção de outliers e de exemplos com rótulo inconsistente | Dados | Média |
| Técnicas de treino robusto (por exemplo, limitar a influência de cada exemplo) | Treino | Média |
| Re-treino com aprovação e possibilidade de rollback | Processo | Média |

## Referências

- [OWASP LLM04:2025 Data and Model Poisoning](https://genai.owasp.org/llmrisk/llm042025-data-and-model-poisoning/)
- [MITRE ATLAS AML.T0020](https://atlas.mitre.org/techniques/AML.T0020)
- Biggio, Nelson & Laskov, *Poisoning Attacks against Support Vector Machines* (2012)
- Carlini et al., *Poisoning Web-Scale Training Datasets is Practical* (2023)
- Souly et al., *Poisoning Attacks on LLMs Require a Near-constant Number of Poison Samples* (2025)

> Os IDs do OWASP e do MITRE ATLAS mudam entre versões. Confira nas páginas oficiais antes de citar num relatório.

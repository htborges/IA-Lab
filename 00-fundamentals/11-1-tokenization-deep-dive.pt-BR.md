# 11.1 · Tokenização a fundo

> 🇧🇷 Português · 🇺🇸 [English](11-1-tokenization-deep-dive.md)

| | |
|-|-|
| **Trilha** | [Fundamentos de IA](README.pt-BR.md) · Aprofundamento da aula [11 · IA generativa e LLMs](11-llms.pt-BR.md) |
| **Nível** | Aprofundamento |
| **Pré-requisitos** | [11 · LLMs e Transformers](11-llms.pt-BR.md) |
| **Tempo de leitura** | ~30 min |
| **Você vai aprender** | Por que LLMs usam pedaços de palavra, como o algoritmo BPE constrói um vocabulário (com conta à mão), o que mudam o byte-level BPE, o WordPiece e o SentencePiece, e como a tokenização abre brechas: filtros contornados, tokens especiais forjados, glitch tokens e custo |

## Onde paramos

Na [aula 11](11-llms.pt-BR.md) vimos que o modelo não lê letras nem palavras, mas **tokens**, e mostramos uma divisão ilustrativa de "Ignore as instruções anteriores". Ficaram abertas as perguntas: **quem decide** onde cortar cada palavra, por que "senha" e "SENHA" viram sequências diferentes, e por que isso importa tanto para segurança.

## Por que pedaços de palavra?

Existem três escolhas possíveis para a "unidade" do texto:

| Unidade | Vantagem | Problema |
|---------|----------|----------|
| **Caractere** | Vocabulário minúsculo, nenhuma palavra desconhecida | Sequências enormes: o contexto acaba rápido e o modelo precisa aprender a soletrar tudo |
| **Palavra inteira** | Sequências curtas | Vocabulário gigante (cada forma verbal, cada nome, cada erro de digitação) e palavras fora do vocabulário viram um token "desconhecido" |
| **Subpalavra** | Meio-termo: palavras comuns viram um token, palavras raras viram alguns pedaços | É o que os LLMs usam |

Com subpalavras, "hacker" pode ser um token só, e uma palavra nunca vista se quebra em pedaços conhecidos, sem nunca virar "desconhecido".

## BPE: construindo o vocabulário à mão

O **BPE** (*Byte Pair Encoding*) é o algoritmo mais usado. A ideia é simples: começar com caracteres e **fundir repetidamente o par vizinho mais frequente**.

### O corpus

Um corpus mínimo, com a frequência de cada palavra:

| Palavra | hack | hacks | hacker | tracker | track |
|---------|------|-------|--------|---------|-------|
| Frequência | 5 | 2 | 6 | 3 | 4 |

O vocabulário inicial são os caracteres: `h a c k s e r t`. Cada palavra começa quebrada em letras, e as fusões nunca atravessam a fronteira entre palavras.

### As fusões

Em cada passo, contamos todos os pares de símbolos vizinhos, **ponderados pela frequência da palavra**, e fundimos o par mais comum. Em caso de empate, usamos a ordem alfabética (cada implementação tem sua regra de desempate).

| Passo | Par mais frequente | Contagem | Como ficam as palavras |
|-------|-------------------|----------|------------------------|
| 1 | `a` + `c` | 20 (empatado com `c k`) | h·**ac**·k, t·r·**ac**·k·e·r … |
| 2 | `ac` + `k` | 20 | h·**ack**, t·r·**ack**·e·r … |
| 3 | `h` + `ack` | 13 | **hack**, **hack**·s, **hack**·e·r … |
| 4 | `e` + `r` | 9 | **hack**·**er**, t·r·ack·**er** |
| 5 | `r` + `ack` | 7 (empatado com `t r`) | t·**rack**·er, t·**rack** |
| 6 | `t` + `rack` | 7 | **track**·er, **track** |
| 7 | `hack` + `er` | 6 | **hacker** |

Como conferir o passo 1: o par `a c` aparece em todas as palavras, então soma 5 + 2 + 6 + 3 + 4 = 20.

Depois de 7 fusões, o vocabulário tem 8 caracteres + 7 tokens novos = **15 tokens**:

```text
h a c k s e r t  ac ack hack er rack track hacker
```

E o corpus fica assim:

| Palavra | Tokens |
|---------|--------|
| hack | `hack` |
| hacks | `hack` `s` |
| hacker | `hacker` |
| track | `track` |
| tracker | `track` `er` |

### Tokenizando palavras novas

Para tokenizar um texto novo, o tokenizador aplica as fusões **na ordem em que foram aprendidas**:

| Palavra nova | Tokens | Observação |
|--------------|--------|------------|
| hackers | `hacker` `s` | Reaproveita os pedaços conhecidos |
| tracked | `track` `e` `d` | "ed" nunca foi fundido neste corpus |
| attack | `a` `t` `t` `ack` | Palavra rara para este vocabulário: vira 4 tokens |

Esse é o padrão em qualquer LLM: palavras frequentes no treino do tokenizador ficam compactas, e as raras se fragmentam. Um tokenizador real faz dezenas ou centenas de milhares de fusões sobre bilhões de palavras, e chega a vocabulários de 30 mil a mais de 200 mil tokens.

## Variações do algoritmo

| Tokenizador | Diferença principal | Onde aparece |
|-------------|---------------------|--------------|
| **BPE em bytes** (*byte-level*) | Começa dos 256 valores de byte em vez de caracteres. Qualquer texto, em qualquer idioma ou com qualquer emoji, pode ser representado; nunca existe símbolo desconhecido | Famílias GPT e muitos modelos abertos |
| **WordPiece** | Escolhe a fusão que mais aumenta a probabilidade do corpus, não só a mais frequente; marca continuações de palavra (como `##s`) | BERT e derivados |
| **Unigram / SentencePiece** | Começa com um vocabulário grande e vai **removendo** os tokens que menos fazem falta; trata o espaço como um caractere comum, o que funciona bem em idiomas sem espaços | T5, vários modelos multilíngues |

Detalhes que mudam a tokenização na prática:

- **Espaço faz parte do token**: `"senha"` no início do texto e `" senha"` no meio de uma frase costumam ser tokens diferentes.
- **Maiúsculas e acentos** geram sequências diferentes: `senha`, `Senha` e `SENHA` podem não ter nenhum token em comum.
- **Idioma importa**: o tokenizador aprendeu fusões com o texto que viu. Idiomas menos presentes nesse texto, como o português em muitos modelos, se quebram em mais pedaços, e o mesmo conteúdo custa mais tokens.

## Tokens especiais

Além dos pedaços de texto, o vocabulário tem **tokens especiais** que nunca deveriam vir do usuário: fim de texto, início e fim de cada mensagem, marcadores de papel (`system`, `user`, `assistant`) do template de chat ([aula 11](11-llms.pt-BR.md)), marcadores de chamada de ferramenta.

Eles são a "pontuação estrutural" da conversa. Se um texto digitado pelo usuário for convertido no **token especial de verdade**, e não nos pedaços comuns que formam aquela string, o usuário consegue forjar a estrutura: fechar a própria mensagem e abrir uma falsa mensagem de sistema. Por isso as bibliotecas de tokenização têm opções para tratar strings de tokens especiais vindas do usuário como texto comum, e por isso elas precisam estar ativadas.

> [!TIP]
> **Visão do red teamer**
> 1. **Filtros por palavra não enxergam tokens.** Uma blocklist procura a string "ignore"; o modelo enxerga tokens. Variações de maiúsculas, espaços extras, hífens, letras parecidas de outros alfabetos (*homóglifos*) e caracteres invisíveis mudam completamente a tokenização, e o modelo, que aprendeu a ler texto "sujo", ainda entende o pedido ([jailbreaks](../02-prompt-injection/jailbreaks.pt-BR.md), token smuggling).
> 2. **Tokens especiais forjados.** Teste se strings de marcadores de chat e de fim de mensagem digitadas pelo usuário ou presentes em documentos são tratadas como texto ou como estrutura. Se forem estrutura, a injeção vira falsificação de papel ([injeção direta](../02-prompt-injection/direct-prompt-injection.pt-BR.md)).
> 3. **Glitch tokens.** Alguns tokens entraram no vocabulário (por aparecerem muito no texto usado para treinar o tokenizador) mas quase nunca apareceram no treino do modelo. Os embeddings deles ficaram mal treinados, e pedir ao modelo para repeti-los já provocou respostas absurdas, recusas e alucinações em modelos conhecidos.
> 4. **Custo e negação de serviço.** Texto que se fragmenta muito (Unicode raro, strings aleatórias, certos idiomas) consome muito mais tokens pelo mesmo número de caracteres. Limites medidos em caracteres não protegem um orçamento medido em tokens (LLM10).
> 5. **Contar letras é difícil para o modelo** porque ele não vê letras. Isso explica erros em tarefas de "soletrar", e é por isso que pedir a saída soletrada ou com separadores escapa de filtros de match exato ([vazamento de system prompt](../02-prompt-injection/system-prompt-leakage.pt-BR.md)).

## Na prática com Python

Um BPE completo, em Python puro, que reproduz as fusões desta página:

```python
from collections import Counter

corpus = {"hack": 5, "hacks": 2, "hacker": 6, "tracker": 3, "track": 4}
palavras = {p: list(p) for p in corpus}

def fundir(tokens, a, b):
    saida, i = [], 0
    while i < len(tokens):
        if i < len(tokens) - 1 and tokens[i] == a and tokens[i + 1] == b:
            saida.append(a + b)
            i += 2
        else:
            saida.append(tokens[i])
            i += 1
    return saida

fusoes = []
for _ in range(7):
    pares = Counter()
    for p, toks in palavras.items():
        for a, b in zip(toks, toks[1:]):
            pares[(a, b)] += corpus[p]
    (a, b), n = min(pares.items(), key=lambda kv: (-kv[1], kv[0]))   # mais frequente; empate: alfabético
    fusoes.append((a, b))
    palavras = {p: fundir(t, a, b) for p, t in palavras.items()}
    print(a, "+", b, n)
# a + c 20 · ac + k 20 · h + ack 13 · e + r 9 · r + ack 7 · t + rack 7 · hack + er 6

def tokenizar(palavra):
    toks = list(palavra)
    for a, b in fusoes:
        toks = fundir(toks, a, b)
    return toks

for p in ("hackers", "tracked", "attack"):
    print(p, tokenizar(p))
# hackers ['hacker', 's']
# tracked ['track', 'e', 'd']
# attack ['a', 't', 't', 'ack']
```

Para ver tokenizadores reais, use a biblioteca do próprio modelo: `tiktoken` (modelos da OpenAI) ou `AutoTokenizer` do Hugging Face (modelos abertos). Compare o número de tokens da mesma frase em português e em inglês, e de `senha`, `Senha` e `SENHA`.

## Resumo

- LLMs usam **subpalavras**: palavras comuns viram um token e palavras raras se quebram em pedaços, sem nunca haver "palavra desconhecida".
- O **BPE** começa com caracteres (ou bytes) e funde repetidamente o par vizinho mais frequente; para tokenizar, aplica as fusões na ordem aprendida.
- **Byte-level BPE**, **WordPiece** e **Unigram/SentencePiece** são as variações principais; espaço, maiúsculas, acentos e idioma mudam a tokenização.
- **Tokens especiais** dão estrutura à conversa e nunca devem ser forjáveis pelo usuário.
- Para o atacante: filtros por palavra são contornáveis, tokens especiais podem ser forjados, **glitch tokens** desestabilizam o modelo e texto fragmentado aumenta o custo.

## Teste seu entendimento

<details><summary>1. No corpus da página, por que a primeira fusão foi "a + c" com contagem 20?</summary>

Porque o par "a c" aparece em todas as cinco palavras (hack, hacks, hacker, tracker, track), e a contagem é ponderada pela frequência de cada uma: 5 + 2 + 6 + 3 + 4 = 20. O par "c k" também somou 20, e o empate foi decidido pela ordem alfabética.
</details>

<details><summary>2. Por que "attack" virou 4 tokens, enquanto "hacker" virou 1?</summary>

Porque o vocabulário foi aprendido num corpus em que "hacker" era frequente e "attack" não aparecia. As fusões aprendidas só cobrem o pedaço "ack"; o resto fica em caracteres soltos. Palavras raras para o tokenizador sempre se fragmentam mais.
</details>

<details><summary>3. Qual a vantagem do BPE em bytes sobre o BPE em caracteres?</summary>

Como o vocabulário base tem os 256 valores de byte, qualquer texto pode ser representado, inclusive emojis, alfabetos raros e caracteres corrompidos. Nunca existe símbolo desconhecido.
</details>

<details><summary>4. Uma aplicação bloqueia mensagens com a palavra "password". Por que a troca de uma letra latina por uma letra cirílica parecida costuma contornar o filtro e ainda assim ser entendida pelo modelo?</summary>

O filtro compara strings, e a letra cirílica é outro caractere, então a string não bate. Para o modelo, a palavra vira outra sequência de tokens, mas ele aprendeu com muito texto ruidoso e costuma reconhecer a intenção pelo contexto.
</details>

<details><summary>5. O que pode acontecer se o tokenizador converter a string de um marcador de "mensagem do sistema", digitada pelo usuário, no token especial correspondente?</summary>

O usuário passa a controlar a estrutura da conversa: consegue fechar a própria mensagem e abrir uma falsa mensagem de sistema, que o modelo trata com a autoridade de uma instrução do desenvolvedor. É uma forma de injeção por falsificação de papel.
</details>

---

← [11 · IA generativa e LLMs](11-llms.pt-BR.md) · **Próxima aula da trilha:** [12 · Modelos de difusão](12-diffusion-models.pt-BR.md) →

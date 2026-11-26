# <Nome da Técnica>

> 🇧🇷 Português · 🇺🇸 [English](./<arquivo>.md)

| Campo | Valor |
|-------|-------|
| **Categoria** | Prompt Injection / Output / Dados / Sistema / Evasão / Privacidade |
| **OWASP LLM Top 10** | LLMxx:2025 <Nome> |
| **MITRE ATLAS** | AML.Txxxx <Nome> |
| **Alvo** | App LLM / RAG / Agent / Classificador / Pipeline de treino |
| **Acesso do atacante** | Black-box / Gray-box / White-box |
| **Severidade** | Baixa / Média / Alta / Crítica |
| **Lab** | [`labs/<nome-do-lab>`](../labs/<nome-do-lab>/) |
| **Pré-requisitos** | Aula [NN · <título>](../00-fundamentals/<arquivo>.pt-BR.md) |

## TL;DR

Uma ou duas frases: o que o ataque faz e por que funciona.

## Conceito

Como funciona, com suas palavras. Diagrama se ajudar (mermaid).

## Superfície de Ataque e Pré-requisitos

- O que o atacante precisa (acesso, conhecimento, canal de entrada)
- O que torna o alvo vulnerável

## Exploração

Passo a passo contra o lab.

```text
payload / comando
```

Resultado esperado:

```text
saída
```

## Variações

- Variação A: quando e por que usar
- Variação B

## Detecção

- Logs, sinais e heurísticas que revelam o ataque
- Ferramentas (ex.: probe do garak, teste do promptfoo)

## Mitigação

| Controle | Camada | Eficácia |
|----------|--------|----------|
| | Entrada / Modelo / Saída / Arquitetura | Baixa / Média / Alta |

## Referências

- Papers, páginas OWASP/ATLAS, documentação de fornecedores (só fontes públicas)

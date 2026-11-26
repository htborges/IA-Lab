# <Technique Name>

> 🇺🇸 English · 🇧🇷 [Português](./<file>.pt-BR.md)

| Field | Value |
|-------|-------|
| **Category** | Prompt Injection / Output / Data / System / Evasion / Privacy |
| **OWASP LLM Top 10** | LLMxx:2025 <Name> |
| **MITRE ATLAS** | AML.Txxxx <Name> |
| **Target** | LLM app / RAG / Agent / Classifier / Training pipeline |
| **Attacker access** | Black-box / Gray-box / White-box |
| **Severity** | Low / Medium / High / Critical |
| **Lab** | [`labs/<lab-name>`](../labs/<lab-name>/) |
| **Prerequisites** | Lesson [NN · <title>](../00-fundamentals/<file>.md) |

## TL;DR

One or two sentences: what the attack does and why it works.

## Concept

How it works, in your own words. Diagram if it helps (mermaid).

## Attack Surface & Prerequisites

- What the attacker needs (access, knowledge, input channel)
- What makes the target vulnerable

## Exploitation

Step-by-step against the lab.

```text
payload / command
```

Expected result:

```text
output
```

## Variations

- Variant A: when and why to use it
- Variant B

## Detection

- Logs, signals and heuristics that reveal the attack
- Tooling (e.g., garak probe, promptfoo test)

## Mitigation

| Control | Layer | Effectiveness |
|---------|-------|---------------|
| | Input / Model / Output / Architecture | Low / Medium / High |

## References

- Papers, OWASP/ATLAS pages, vendor docs (public sources only)

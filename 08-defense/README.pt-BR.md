# Defesa

> 🇧🇷 Português · 🇺🇸 [English](README.md)

Todo ataque no IA-Lab termina na defesa. Esta seção reúne as defesas que valem para várias técnicas de uma vez, organizadas por camada.

## Princípios

- **Assuma que o modelo pode ser convencido.** Prompt injection não tem correção definitiva; a pergunta certa é "o que acontece quando ela funcionar?".
- **Controles fora do modelo são mais confiáveis** do que instruções dentro do prompt: permissões, validação de saída e arquitetura.
- **Defesa em camadas**: cada camada é imperfeita, mas juntas reduzem a taxa de sucesso e o impacto dos ataques.
- **Meça**: uma defesa só vale o que ela reduz numa bateria de ataques reais, incluindo atacantes que sabem que ela existe.

## Páginas

| Página | Cobre | Status |
|--------|-------|--------|
| [Defesa contra prompt injection em camadas](prompt-injection-defense.pt-BR.md) | Arquitetura, filtros de entrada, prompt, treino do modelo, validação de saída e operação | ✅ |
| Supply chain e integridade de modelos | Proveniência, varredura e registro de artefatos | 🚧 |
| Monitoramento de aplicações LLM | Registro, sinais de ataque e resposta a incidentes | 🚧 |

Cada técnica de ataque também traz suas próprias seções de **Detecção** e **Mitigação**.

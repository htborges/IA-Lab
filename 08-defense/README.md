# Defense

> 🇺🇸 English · 🇧🇷 [Português](README.pt-BR.md)

Every attack in IA-Lab ends with the defense. This section gathers the defenses that apply to several techniques at once, organized by layer.

## Principles

- **Assume the model can be convinced.** Prompt injection has no definitive fix; the right question is "what happens when it works?".
- **Controls outside the model are more reliable** than instructions inside the prompt: permissions, output validation and architecture.
- **Defense in depth**: each layer is imperfect, but together they lower the success rate and impact of attacks.
- **Measure it**: a defense is only worth what it reduces on a battery of real attacks, including attackers who know it is there.

## Pages

| Page | Covers | Status |
|------|--------|--------|
| [Layered prompt injection defense](prompt-injection-defense.md) | Architecture, input filters, prompt, model training, output validation and operations | ✅ |
| Supply chain and model integrity | Provenance, scanning and artifact registries | 🚧 |
| Monitoring LLM applications | Logging, attack signals and incident response | 🚧 |

Each attack technique also has its own **Detection** and **Mitigation** sections.

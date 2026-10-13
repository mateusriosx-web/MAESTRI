# Cadastro de clientes/modelos — por máquina (EXEMPLO, versionável)

Este é o modelo genérico, sem nenhum dado pessoal. **Não edite este arquivo com dados reais.** Para registrar os dados reais desta máquina, copie-o para `MODELOS_CLIENTES.local.md` (ignorado pelo Git — ver `.gitignore`) e preencha lá:

```
cp MODELOS_CLIENTES.example.md MODELOS_CLIENTES.local.md
```

**Não sobrescreva um `MODELOS_CLIENTES.local.md` já existente** — se ele já existir nesta máquina, use-o como está (ou atualize campos pontuais), não copie este exemplo por cima.

Este arquivo separa **configuração local da máquina** (quem roda cada papel, de verdade) das **instruções reutilizáveis** em `.claude/agents/*.md` e `CLAUDE.md` (que não dependem de modelo/cliente nenhum).

**Regra:** só registre fatos confirmados rodando `maestri check "<Nome>"` (ou equivalente) e lendo o banner real. Nunca escreva um modelo "porque devia ser esse". Nunca inclua e-mail, usuário de conta, token ou qualquer dado pessoal/de conta neste arquivo — se precisar anotar a conta usada, isso vai só no `.local.md`.

## Papéis e terminais

| Papel | Terminal Maestri | Cliente | Modelo | Confirmado em |
|---|---|---|---|---|
| `cto` | | | | |
| `backend-dev` | | | | |
| `frontend-dev` | | | | |
| `spec-lookup` | | | | |
| `test-runner` | | | | |
| `data-analyst` | | | | |
| `devops-infra` | | | | |
| `security-auditor` | | | | |
| `qa-e2e` | | | | |
| `tech-writer` | | | | |
| `calc-auditor` | | | | |
| `migration-guardian` | | | | |

## Autenticação de ferramentas (não é login de IA, é CLI auxiliar)

| Ferramenta | Onde autentica | Confirmado em |
|---|---|---|
| `gh` (GitHub CLI) | | |
| `rtk` | | |
| `serena` (Serena MCP) | | |

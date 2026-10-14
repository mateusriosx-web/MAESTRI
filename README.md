# MAESTRI_TEMPLATE

Modelo reutilizável de "vibe coding" para projetos em Node.js, TypeScript, React, SaaS e automações de processo — governança de agentes (CTO + especialistas) e ferramentas de redução de token (Graphify, RTK, Serena, UI UX Pro Max) já configuradas e testadas.

## Para preparar este workspace num caminho/máquina novo

Depois de clonar, peça ao seu agente/CLI:

> Clone \<URL\> e siga as instruções do repositório para preparar este workspace.

Isso deve levar o agente direto a **[`PREPARACAO.md`](./PREPARACAO.md)** — o único procedimento de preparação deste repositório (identifica a raiz do projeto e qual fluxo seguir — só estrutura, projeto novo, ou projeto existente —, assume o papel de `cto` sem recrutar outro, instala/valida ferramentas, adapta nomes/caminhos, apresenta o catálogo de papéis e a escolha de cliente/modelo/permissão, orienta autenticações, valida ferramentas por execução real e registra tudo no diário com um estado final — preparado/validado/parcial/bloqueado). Não há um segundo procedimento em outro arquivo — se algo parecer duplicado, é bug de documentação, avise.

## Mapa do repositório

| Arquivo | O que é | Muda ao duplicar para outro projeto? |
|---|---|---|
| **`PREPARACAO.md`** | Procedimento único de preparação de workspace novo | Não — é o mesmo processo sempre |
| **`CLAUDE.md`** | Governança: papéis, fluxo de delegação, premissas, ferramentas | Parcialmente — a seção "Sobre este template" vira a descrição real do projeto; o resto é permanente |
| **`.claude/agents/*.md`** | Instruções de cada papel (`cto`, `backend-dev`, `frontend-dev`, etc.) | Não — genéricas por design |
| **`MODELOS_CLIENTES.example.md`** | Modelo genérico/vazio do cadastro de clientes, sem dados pessoais | Não — é o template do cadastro |
| **`MODELOS_CLIENTES.local.md`** | Cadastro real (contas, e-mails) — **ignorado pelo Git**, nunca versionado | **Sim, sempre** — crie copiando o `.example.md`; nunca sobrescreva um já existente |
| **`GUIAS.md`** | Guias de referência (instalar ferramentas, levar a outra máquina, checklist de entrega) | Não |
| **`scripts/setup-maquina.ps1`** | Instalador idempotente das ferramentas do template | Não |
| **`DIARIO_DE_BORDO.md`** | Registro de continuidade do projeto | **Sim, sempre** — recomeça limpo em cada projeto novo |
| **`.serena/project.yml`** | Config da Serena (MCP) para este caminho específico | **Sim, sempre** — recriar, nunca copiar |

## Pré-requisitos da máquina

Python 3, Node.js + npm/npx, `uv`, Git, PowerShell 5.1+. `PREPARACAO.md` → Passo 4 detecta o que falta e orienta a instalação.

## Orientação Prisma opcional

Consulte [PRISMA_SKILLS.md](./PRISMA_SKILLS.md) somente quando o projeto usar Prisma. As três skills oficiais estão incluídas localmente; preservar versão/provider, sem instalar ORM ou conectar bancos durante o preparo do template.

## Orientação Better Auth opcional

Consulte [BETTER_AUTH.md](./BETTER_AUTH.md) somente quando o projeto precisar de autenticação/controle de acesso. Nada instalado localmente (sem licença declarada no repositório oficial de skills) — guia aponta para a documentação/skills oficiais, consultadas sob demanda.

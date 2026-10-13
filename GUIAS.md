# Guias de reuso do MAESTRI_TEMPLATE

## Guia 1 — Instalar ferramentas, autenticar clientes e validar conexões

Pré-requisitos confirmados nesta máquina em 2026-10-13: Python 3 (para Graphify/Serena/UI UX Pro Max), Node.js + npm/npx (para UI UX Pro Max e `gh`), `uv` (para instalar a Serena), Git, PowerShell 5.1+.

1. **Graphify:** `python -m graphify install --platform claude` na raiz do projeto, depois `python -m graphify update .`. Teste real: `python -m graphify query "<qualquer pergunta sobre o código>"` — deve retornar algo, não erro.
2. **RTK:** baixar o binário da release oficial (`rtk-ai/rtk`) para `<pasta de bin do usuário>\rtk.exe` e garantir que está no `PATH`. Teste real: `rtk --version`.
3. **Serena:** `uv tool install -p 3.13 serena-agent`. Criar config do projeto: `serena project create --name <nome> --language typescript .` (gera `.serena/project.yml`). Registrar no cliente real (ex. `agy mcp add serena --command "<caminho>\serena.exe start-mcp-server --context antigravity --agent-interface tools --project <caminho-do-projeto> --transport stdio --enable-web-dashboard False --open-web-dashboard False"`) — **isso edita config GLOBAL do cliente nesta máquina** (sem suporte a escopo por projeto no `agy`); avise o usuário antes. Teste real: `agy mcp list` mostra `serena` como `enabled`; dentro do terminal real, confirmar que `find_symbol`/`find_referencing_symbols`/`replace_symbol_body` aparecem na lista de ferramentas.
4. **UI UX Pro Max:** `npx ui-ux-pro-max-cli init --ai claude` na raiz do projeto (escopo local, sem `-g`). Teste real: `python .claude/skills/ui-ux-pro-max/scripts/search.py --domain ux "empty state"` deve retornar resultado(s) do CSV.
5. **`gh` (GitHub CLI), se for versionar:** baixar o binário da release oficial (`cli/cli`), copiar para pasta de bin do usuário. Autenticar com `gh auth login --hostname github.com --git-protocol https --web` (device flow — usuário faz login manual no navegador, não dá para automatizar sem intervenção humana). Teste real: `gh auth status`.

**O que não dá para validar sem rodar na máquina de destino:** login/autenticação de cada cliente de IA (Antigravity/`agy`, Codex, etc.) é sempre ação manual do usuário — nenhum script automatiza login de IA.

## Guia 2 — Duplicar o template para um projeto novo

**Procedimento único, não duplicado aqui: ver `PREPARACAO.md` na raiz do repositório.** Esse é o fluxo que também cobre o caso de alguém clonar o repositório do zero e pedir "prepare este workspace" — mantido num só lugar para não haver duas versões divergentes do mesmo passo a passo.

## Guia 3 — Levar o template para outra máquina

1. **Canvas Maestri:** não há comando de export/import de canvas na CLI (`maestri --help` confirmado em 2026-10-13 sem nenhum comando `export`/`import`). Na máquina nova, recrie os terminais com `maestri recruit` (Maestro only) e `maestri connect`, ou copie manualmente a config do Maestri se o app tiver isso na interface (ação manual, fora do que esta sessão conseguiu confirmar).
2. **Cópia da pasta-base:** copiar a pasta do projeto inteira (código + `.claude/` + `.serena/project.yml` + `.gitignore` + este `GUIAS.md`) — não é preciso copiar `node_modules/`, `graphify-out/cache/`, `.rtk/`.
3. **Preparação do ambiente novo:** rodar `scripts/setup-maquina.ps1` (ver abaixo) para instalar/validar RTK, Serena, Graphify e a skill UI UX Pro Max na máquina nova.
4. **O que nunca é copiado:** credenciais, sessões, tokens, logins de IA — cada ferramenta/cliente é autenticado de novo, manualmente, na máquina nova.
5. **Reconectar terminais Maestri:** depende de ação manual na interface do Maestri (Maestro Mode) — esta sessão não tem ferramenta para automatizar isso.

## Guia 4 — Checklist da primeira entrega num projeto novo a partir do template

- [ ] `CLAUDE.md` atualizado com o domínio de negócio real do projeto (não genérico).
- [ ] `MODELOS_CLIENTES.local.md` existe (criado a partir de `MODELOS_CLIENTES.example.md`, sem sobrescrever um já existente) e está preenchido com fatos confirmados (não herdados do template). Confirmar que ele está no `.gitignore` e não aparece em `git status` como rastreável.
- [ ] `.serena/project.yml` recriado apontando pro caminho certo; MCP da Serena validado (`agy mcp list` + chamada real de uma ferramenta).
- [ ] Graphify atualizado (`python -m graphify update .`) refletindo o código real do projeto.
- [ ] `.gitignore` revisado — cobre os segredos reais do projeto (ex.: credenciais de integração específica).
- [ ] Versionamento próprio decidido (`git init` + remoto, se for o caso).
- [ ] `calc-auditor.md`/`migration-guardian.md` criados e revisados com o usuário **antes** da primeira vez que algum dos dois for ativado (se o projeto tiver cálculo financeiro ou schema de banco).
- [ ] Primeira entrega real passou pelo fluxo de delegação e relatório verificável (`[RESULTADO]/[ARQUIVOS ALTERADOS]/[VERIFICAÇÃO]/[PENDÊNCIAS-RISCOS]`), confirmado pelo `cto` com evidência pontual — não só pelo relato do executor.

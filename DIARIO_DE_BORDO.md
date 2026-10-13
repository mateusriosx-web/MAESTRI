# Diário de Bordo — MAESTRI_TEMPLATE

Registro de continuidade do projeto. Toda sessão nova deve consultar este arquivo antes de reconstruir estado por outros meios.

**Nota sobre este diário:** ele foi reiniciado em 2026-10-13 quando este workspace (antes "AUTOMACAO_HD", um hub de automações da HD Serviços) foi transformado em **MAESTRI_TEMPLATE**, um modelo reutilizável genérico. O histórico completo anterior (automações planejadas, decisões específicas daquele projeto, validações de ferramentas feitas naquele contexto) foi **preservado no backup**, não apagado — ver "Backup" abaixo. Este diário recomeça limpo porque o conteúdo antigo não é genérico (é específico de um projeto que não existe mais aqui).

## ESTADO ATUAL

- **Tarefa ativa:** repositório tornado autossuficiente para preparar workspace novo (`README.md` + `PREPARACAO.md`) — concluída.
- **Responsável:** `cto` (sessão principal).
- **Etapa:** concluída — ver entrada "Repositório autossuficiente (README.md + PREPARACAO.md)" abaixo.
- **Próximo passo:** usuário decide quando clonar/duplicar este template para o primeiro projeto real (fluxo: "Clone \<URL\> e siga as instruções do repositório para preparar este workspace" → `PREPARACAO.md`).
- **Bloqueios:** nenhum.
- **Referências:** `README.md`, `PREPARACAO.md`, `CLAUDE.md`, `MODELOS_CLIENTES.md`, `GUIAS.md`, `scripts/setup-maquina.ps1`, entradas "Transformação em template" e "Repositório autossuficiente" abaixo.

## 2026-10-13 — Transformação em template (MAESTRI_TEMPLATE)

Usuário autorizou (depois de reconfirmar o pedido completo, que tinha chegado truncado numa primeira colagem) transformar o projeto AUTOMACAO_HD, sem mais uso planejado como hub de automações da HD Serviços, num modelo reutilizável de vibe coding para Node.js/TypeScript/React/SaaS/automações.

### Backup (antes de qualquer alteração)

Cópia completa da pasta feita **fora dela**, antes de qualquer edição: `C:\Users\mateu\.gemini\antigravity-ide\BACKUPS\AUTOMACAO_HD_backup_20261013_182731`. Verificado com `diff -rq` contra a pasta original — nenhuma diferença (cópia íntegra). Contém o histórico completo anterior (diário antigo, notas de automações, tudo).

**Export de canvas:** não existe comando de export/import de canvas na CLI do Maestri (`maestri --help` conferido — nenhum comando `export`/`import` listado). Não foi possível exportar o canvas por essa via; a posição/notas/conexões continuam intactas no canvas real (nada foi movido/apagado), só não há um arquivo de backup separado do canvas em si.

### Workspace renomeado, caminho físico preservado

`maestri workspace rename "AUTOMACAO_HD" "MAESTRI_TEMPLATE"` — confirmado via `maestri workspace list`: título agora `MAESTRI_TEMPLATE`, caminho continua `...\scratch\AUTOMACAO_HD` (deliberado, documentado em `CLAUDE.md` como configuração desta máquina, não identidade do template).

### Terminais — nenhum interrompido

`maestri list` conferido antes de qualquer edição: 11 terminais conectados, nenhuma tarefa ativa sinalizada (só uma nota antiga em ANALISTA DE DADOS, não uma tarefa em execução). Nenhum terminal foi reiniciado, nenhuma tarefa foi enviada, nenhum cliente/modelo foi trocado nesta tarefa.

### Conteúdo de negócio removido das instruções ativas

Trocas de identidade (`AUTOMACAO_HD` → `MAESTRI_TEMPLATE`/"este template") em `CLAUDE.md` e todos os `.claude/agents/*.md`, incluindo a remoção da frase "hub de automações de processo da HD Serviços / grupo econômico" (único ponto com referência de negócio real encontrado via `grep`). Caminho físico da máquina preservado onde faz sentido (configuração, não identidade) — documentado em seção própria do `CLAUDE.md`.

### Equipe realinhada ao pedido

Tabela de agentes em `CLAUDE.md` reorganizada em "Principal" (`cto`, `backend-dev`, `frontend-dev`, `spec-lookup`, `test-runner`) e "Sob demanda" (`data-analyst`, `security-auditor`, `qa-e2e`, `devops-infra`, `tech-writer`, `calc-auditor`/`migration-guardian` como "sob demanda, condicional" — instrução ainda não existe para os dois últimos, confirmado via `ls .claude/agents/`). Adicionada nota explícita: papéis são responsabilidades, não dependem de cliente/modelo específico — essa separação agora vive em `MODELOS_CLIENTES.md`.

### Ferramentas — re-testadas nesta máquina, não reinstaladas do zero

- **RTK 0.52.0:** `rtk --version` confirmado.
- **Serena (serena-agent 2.0.0):** `uv tool list` confirma instalada; `.serena/project.yml` já existe.
- **Graphify 0.9.8:** `python -m graphify --version` confirmado; grafo atualizado ao final desta tarefa.
- **UI UX Pro Max:** já presente em `.claude/skills/ui-ux-pro-max/`.

Essas quatro foram comprovadas de novo via `scripts/setup-maquina.ps1` (ver abaixo), rodado 2x nesta máquina para confirmar idempotência — saída idêntica na 2ª execução, nenhuma duplicação.

### Arquivos novos criados

- **`MODELOS_CLIENTES.md`** — cadastro de modelo/cliente real por papel, confirmado via `maestri check` em cada um dos 11 terminais nesta máquina (todos rodando Antigravity CLI 1.3.4 / Gemini 3.8 Flash / mesma conta — sem diversidade de modelo configurada hoje, documentado como fato desta máquina, não exigência do template). Inclui tabela vazia para preencher numa máquina nova.
- **`GUIAS.md`** — 4 guias: (1) instalar ferramentas/autenticar/validar; (2) duplicar o template para um projeto novo; (3) levar o template para outra máquina; (4) checklist da primeira entrega.
- **`scripts/setup-maquina.ps1`** — instalador PowerShell idempotente para as ferramentas do template (não instala dependências de uma aplicação futura — ver separação de escopo no próprio script). **Bug real encontrado e corrigido durante a validação:** a primeira versão, salva com acento/travessão em UTF-8 sem BOM, quebrava o parser do Windows PowerShell 5.1 (caracteres acentuados mal decodificados viravam aspas curvas que o tokenizer aceita como delimitador de string de verdade) — reescrito em ASCII puro, revalidado com o parser real (`[System.Management.Automation.Language.Parser]::ParseFile`) e **executado de verdade 2x** nesta máquina (não só revisado por leitura). Segundo bug encontrado e corrigido na mesma validação: `$ErrorActionPreference = "Stop"` abortava o script num warning inofensivo do Graphify (stderr de binário nativo redirecionado virando erro terminante) — trocado para `"Continue"`.
- **`.gitignore`** atualizado para cobertura completa de Node/TS/React (build/test/editor/segredos) — **não foi feito `git init`/commit/push nesta tarefa** (git já existia de uma tarefa anterior; só o conteúdo do arquivo foi editado).

### O que não foi testado / fica pendente

- Os ramos de instalação do zero do `setup-maquina.ps1` (baixar RTK, instalar Serena via `uv`, registrar MCP global, instalar UI UX Pro Max via `npx`) — não exercitados nesta sessão porque tudo já estava instalado. Não declarar que o script "funciona numa máquina limpa" sem testar numa de verdade.
- Export/import de canvas do Maestri — sem comando de CLI; depende de ação manual na interface (Maestro Mode), não confirmado nesta tarefa.
- RTK fora do PATH desta sessão PowerShell (está no PATH do Bash) — achado real, registrado como pendência manual no próprio script.
- Registro da Serena no MCP global não foi repetido nesta tarefa (já estava registrado de uma tarefa anterior) — nenhuma mudança de configuração global foi feita agora.

### Simulação documental de 3 fluxos (sem enviar tarefa a nenhum agente)

**Fluxo 1 — automação simples (script sem tela, sem dado financeiro):** usuário descreve o processo ao `cto` → `cto` identifica `backend-dev` OU `data-analyst` como responsável único, propõe plano curto (sem `frontend-dev`/auditores, pois nenhum gatilho existe) → aprovação do usuário → delegação com o "Modelo de delegação" → `test-runner` confirma execução → `cto` relata e atualiza este diário. Equipe mínima: `cto` + 1 executor + `test-runner`.

**Fluxo 2 — SaaS com interface (tela React/TS, sem dado financeiro):** mesmo início, mas o `cto` já identifica o gatilho "tela" e inclui `frontend-dev` + `qa-e2e` no plano desde o começo. `frontend-dev` usa a skill UI UX Pro Max sob demanda (consulta de padrão de UI antes de implementar) e a Serena para localizar/editar símbolos já existentes. `backend-dev`/`data-analyst` entrega a lógica antes; `frontend-dev` consome depois (sequência coordenada, nunca em paralelo no mesmo arquivo). `qa-e2e` valida o clique ponta a ponta. Equipe: `cto` + responsável de lógica + `frontend-dev` + `qa-e2e` + `test-runner`.

**Fluxo 3 — mudança financeira (toca dado financeiro ou sincronização sem supervisão):** o `cto` identifica o gatilho "dado financeiro" no plano e exige, antes de passar para o `test-runner`, que o responsável (`backend-dev`/`data-analyst`) escreva o teste automatizado do cenário principal — nunca o `test-runner`, que só executa e reporta depois. Se a automação tiver cálculo financeiro relevante, o `cto` avisa o usuário que `calc-auditor` seria o papel certo, mas **não o ativa** sem antes criar e revisar `.claude/agents/calc-auditor.md` com o usuário (não existe ainda). `cto` confere evidência pontual do teste e do relatório antes de declarar a entrega pronta.

### Verificação de consistência final

- `CLAUDE.md` × `.claude/agents/*.md`: nenhuma referência remanescente a "AUTOMACAO_HD" como identidade (só como caminho físico documentado, ver seção dedicada do `CLAUDE.md`).
- `.maestri/roles/*/CLAUDE.md`/`AGENTS.md` × `role.json`: caminho do `working_directory` em cada role continua apontando para a pasta física real (correto, não é identidade de projeto).
- Arquivos novos (`MODELOS_CLIENTES.md`, `GUIAS.md`, `scripts/setup-maquina.ps1`, `.gitignore`) revisados contra padrão de segredo/credencial — nenhum achado (nenhum token, senha ou sessão incluído).
- `python -m graphify update .` rodado ao final para refletir os arquivos novos/renomeados.

## 2026-10-13 — Repositório autossuficiente (README.md + PREPARACAO.md)

Pedido: fazer com que clonar o repositório e pedir "siga as instruções do repositório para preparar este workspace" baste, sem o usuário colar prompt longo de novo.

**Arquivos novos:**
- **`README.md`** — ponto de entrada único, com o mapa do repositório (o que é permanente vs. específico de máquina/projeto) e o apontamento direto para `PREPARACAO.md`.
- **`PREPARACAO.md`** — procedimento único de preparação, com 8 passos: (1) identificar raiz e conferir correspondência com workspace Maestri (`maestri list`/`workspace list`); (2) assumir o papel `cto` (ler `CLAUDE.md`+`cto.md`); (3) perguntar só o que não pode ser detectado (nome do projeto, domínio de negócio, confirmação de stack, autorização para recrutar terminais, autorização para mudança global); (4) instalar/validar via `scripts/setup-maquina.ps1`; (5) adaptar nome/caminhos (`CLAUDE.md`, `.serena/project.yml`, `MODELOS_CLIENTES.md`); (6) preparar equipe/recrutar agentes só com suporte Maestri + autorização, checando `maestri list` antes para não duplicar; (7) orientar autenticações, pedir autorização antes de mudança global; (8) registrar no diário.

**Sem duplicação de regra:** `GUIAS.md` (Guia 2, antes "Duplicar o template") foi reduzido a um ponteiro para `PREPARACAO.md` — o passo a passo deixou de existir em dois lugares. `CLAUDE.md` recebeu uma nota no topo apontando para `PREPARACAO.md` em vez de descrever o procedimento ali.

**Papéis não fixam fornecedor/modelo:** confirmado — `PREPARACAO.md` Passo 6 já instrui a consultar `MODELOS_CLIENTES.md` ou perguntar, nunca fixar um cliente no papel; coerente com a tabela de `CLAUDE.md` (já corrigida na tarefa anterior).

**Validação do fluxo — revisão documental, não teste em máquina limpa:** reli `README.md` e `PREPARACAO.md` de ponta a ponta como um agente sem contexto leria (caminho de leitura: README → PREPARACAO → CLAUDE.md/cto.md → script). Achados: nenhuma referência residual a "AUTOMACAO_HD" nos dois arquivos novos (`grep` confirmou); nenhuma contradição encontrada entre `GUIAS.md` Guia 1 (comandos manuais de referência) e `PREPARACAO.md` Passo 4 (mesmo conjunto de ferramentas, via script). **Isto não é um teste real** — não foi clonado um repositório novo nem executado numa máquina/caminho limpo; é revisão de leitura/consistência do texto. Ficou pendente testar de verdade clonando para um caminho novo.

**Pendência real:** o fluxo completo (clone → PREPARACAO.md → script → adaptação → recrutamento) nunca foi executado ponta a ponta numa pasta nova — só revisado por leitura e pelos testes pontuais de ferramentas já feitos nas tarefas anteriores.

## 2026-10-13 — Cadastro pessoal de clientes/modelos removido do conteúdo versionável

Pedido: impedir que o cadastro real de clientes/modelos (que contém dados de conta pessoais) entre em algum commit do template.

**Estado do Git conferido antes de qualquer mudança:** `MODELOS_CLIENTES.md` estava **não rastreado** (`??` no `git status`) — nunca tinha sido commitado nem estava staged. Nenhum `git rm --cached` foi necessário por esse motivo específico.

**Mudança estrutural:**
- `MODELOS_CLIENTES.md` renomeado para **`MODELOS_CLIENTES.local.md`** (contém dados pessoais, nunca versionado).
- **`.gitignore`** recebeu a entrada `MODELOS_CLIENTES.local.md`.
- **`MODELOS_CLIENTES.example.md`** criado — estrutura genérica, campos vazios, sem nenhum dado pessoal (versionável).
- `README.md`, `GUIAS.md`, `PREPARACAO.md` e `CLAUDE.md` atualizados: toda referência ao cadastro agora aponta para `.local.md` (dado real) com instrução de criá-lo a partir do `.example.md` sem sobrescrever um já existente.

**Verificação de dados pessoais executada (busca real, não suposição):** o padrão do e-mail pessoal foi buscado em toda a árvore de trabalho (excluindo `.git`/`node_modules`) e em `graphify-out/` depois de uma atualização do Graphify — o único arquivo remanescente com o e-mail é o próprio `MODELOS_CLIENTES.local.md`, confirmado ignorado pelo Git via `git check-ignore -v`. `MODELOS_CLIENTES.example.md` não deu match em `check-ignore` (está disponível para versionar).

**Histórico de commits (não alterado):** `git log --all -p` e `git log --all -S "<e-mail>"` mostraram só **uma** ocorrência em todo o histórico — o campo de autor do commit `c341695` (metadado de autoria do Git, não conteúdo de arquivo). Nenhum conteúdo de arquivo com o e-mail foi encontrado em commits anteriores. **Nenhuma reescrita de histórico nem force-push foi feita** — não era necessário (o único arquivo pessoal nunca tinha sido commitado) e não foi autorizado.

**Achado adicional, fora do pedido original, reportado sem alterar:** `CLAUDE.md` ainda menciona o usuário GitHub `mateusriosx-web` (não é o e-mail, é o nome de usuário público do repositório remoto já documentado) — não removido, pois é informação operacional legítima sobre onde o repositório está hospedado, não o endereço de e-mail pedido nesta tarefa. Fica registrado para o usuário decidir se quer tratar isso também.

**Não houve commit nem push nesta tarefa** — só edição de arquivos locais, conforme autorizado.

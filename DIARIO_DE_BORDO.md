# Diário de Bordo — MAESTRI_TEMPLATE

Registro de continuidade do projeto. Toda sessão nova deve consultar este arquivo antes de reconstruir estado por outros meios.

**Nota sobre este diário:** ele foi reiniciado em 2026-10-13 quando este workspace (antes "AUTOMACAO_HD", um hub de automações da HD Serviços) foi transformado em **MAESTRI_TEMPLATE**, um modelo reutilizável genérico. O histórico completo anterior (automações planejadas, decisões específicas daquele projeto, validações de ferramentas feitas naquele contexto) foi **preservado no backup**, não apagado — ver "Backup" abaixo. Este diário recomeça limpo porque o conteúdo antigo não é genérico (é específico de um projeto que não existe mais aqui).

## ESTADO ATUAL

- **Tarefa ativa:** ajustes de portabilidade (7 frentes) + complementos (calc-auditor/migration-guardian, 3 simulações, exclusões Graphify, registro RTK, alcance de `-AutoYes`/`-ConfirmGlobalChanges`, skills Prisma) — committed em `cfb6b8a`. Depois: guia Better Auth sob demanda — concluído, sem commit ainda. Ver entradas "Ajustes de portabilidade pós-teste em outra máquina", "Três simulações documentais..." e "Better Auth: guia central sob demanda, sem skill local" abaixo.
- **Responsável:** `cto` (sessão principal).
- **Estado desta preparação (escala Preparado/Validado/Parcial/Bloqueado, ver `PREPARACAO.md` Passo 10):** **Parcial** nesta máquina — Graphify/Serena/UI UX Pro Max OK, RTK com binário fora do PATH desta sessão PowerShell (achado pré-existente, não novo) e registro MCP global da Serena pendente de autorização explícita (`-ConfirmGlobalChanges`), ambos esperados/não-bloqueantes.
- **Próximo passo:** usuário decide quando testar o fluxo completo (clone → `PREPARACAO.md` → script → adaptação → recrutamento) numa máquina/pasta realmente limpa, quando autorizar escolha real de cliente/modelo por papel, e quando commitar o guia Better Auth — nada disso foi feito ainda.
- **Bloqueios:** nenhum.
- **Referências:** `README.md`, `PREPARACAO.md`, `CLAUDE.md`, `MODELOS_CLIENTES.local.md`, `GUIAS.md`, `scripts/setup-maquina.ps1`, `.claude/agents/calc-auditor.md`, `.claude/agents/migration-guardian.md`, `.graphifyignore`, `PRISMA_SKILLS.md`, `BETTER_AUTH.md`, entradas de 2026-10-14 abaixo.

## 2026-10-14 — Ajustes de portabilidade pós-teste em outra máquina

Pedido do usuário: corrigir o `MAESTRI_TEMPLATE` com base em achados de um teste real de preparação em outra máquina (lista de 7 frentes). Trabalho feito só na pasta do template, sem tocar outros projetos/config global, com backup prévio e sem commit/push.

**Backup (antes de qualquer edição):** cópia dos arquivos a tocar (`CLAUDE.md`, `DIARIO_DE_BORDO.md`, `GUIAS.md`, `PREPARACAO.md`, `README.md`, `MODELOS_CLIENTES.example.md`, `MODELOS_CLIENTES.local.md`, `scripts/`, `.claude/`) em `C:\Users\mateu\.gemini\antigravity-ide\BACKUPS\MAESTRI_TEMPLATE_backup_20261014_092734`.

**Escopo entregue nesta rodada (5 das 7 frentes, por decisão explícita do usuário):**

1. **Separação estrutura/projeto novo/projeto existente (`PREPARACAO.md`):** Passo 1 agora detecta Fluxo A (só estrutura, sem domínio/código ainda), Fluxo B (projeto novo) e Fluxo C (projeto existente sendo incorporado ao template) por sinais no repositório (presença de `automacoes/` com conteúdo, histórico Git de negócio, `CLAUDE.md`/agentes próprios), antes de perguntar qualquer coisa de negócio. Fluxo C exige resolução arquivo por arquivo com backup, nunca `git init`/exclusão em massa como padrão, e registra divergência de remoto Git sem alterá-lo. Passo 3 (perguntas) e Passo 5 (adaptação) agora remetem a qual fluxo pedir/pular cada pergunta.
2. **Portabilidade (`CLAUDE.md`):** seção "Configuração desta máquina" reescrita para deixar explícito que caminho físico, versões de ferramenta e nome de workspace são fatos datados desta máquina, nunca instrução a copiar; adicionada a ressalva de que pastas em `.maestri/roles/*/` não comprovam terminal real conectado (só `maestri list` prova).
3. **Script (`scripts/setup-maquina.ps1`):** adicionados `-NonInteractive`/`-AutoYes`/`-ConfirmGlobalChanges`; função `Confirm-Action` trata EOF/entrada vazia como `[PENDENTE]` (nunca como recusa); função `Invoke-Checked` confere `$LASTEXITCODE` real de cada comando externo (antes só Graphify tinha essa checagem); detecção de Graphify agora cobre módulo Python, `uv tool list` e executável direto (antes só módulo Python); seção RTK agora testa o subcomando real do hook (`rtk hook antigravity --help`) além de `rtk --version`; resumo final ganhou um estado agregado (`PREPARADO`/`PARCIAL`/`BLOQUEADO`) coerente com os 4 estados definidos no novo Passo 10 do `PREPARACAO.md` (o 4º estado, `VALIDADO`, depende de execução real das ferramentas, que o script não faz).
4. **Equipe sem duplicação (`PREPARACAO.md` Passo 6/7 novos):** passo explícito de apresentar o catálogo completo de papéis para seleção (distinguindo recrutar de acionar), reafirmando que a própria sessão assume `cto` sem recrutar outro, e checagem de `maestri list` antes de recrutar para não duplicar nem interromper terminal com trabalho ativo. Passo 7 novo cobre escolha de cliente/modelo/permissão por papel, com aprovação explícita separada para permissão total, e conferência do que de fato iniciou.
5. **Critérios de conclusão (`PREPARACAO.md` Passo 9/10 novos):** Passo 9 diferencia instalado/configurado/conectado/executado para Serena, Graphify, RTK e UI UX Pro Max, com a instrução explícita de não usar teste de outra máquina como prova nesta. Passo 10 define os 4 estados (Bloqueado/Parcial/Preparado/Validado) e exige registrá-los no diário por ferramenta/cliente/terminal.

**Investigação real feita (RTK 0.46.0 vs. hook preparado em 0.52.0):** nesta máquina só há o binário 0.52.0 instalado (`rtk --version` confirmado) — não foi possível reproduzir o cenário com 0.46.0 real. Confirmado, sim, que o hook do Antigravity (`.agents/plugins/rtk/hooks.json`) chama o subcomando `rtk hook antigravity`, e que esse subcomando responde `--help` com exit 0 na versão 0.52.0 instalada aqui. A causa da falha relatada com 0.46.0 **não foi confirmada nem descartada** — ficou registrada no script/procedimento como hipótese a testar (o subcomando pode não existir em binários mais antigos), nunca como fato. Não atribuir a causa à versão sem testar o binário 0.46.0 de verdade.

**Verificação real executada (não só leitura):** `scripts/setup-maquina.ps1` reescrito foi parse-checado (`[System.Management.Automation.Language.Parser]::ParseFile` — sem erro) e **rodado de verdade 2x** nesta máquina com `-NonInteractive -AutoYes` (sem `-ConfirmGlobalChanges`, de propósito, para confirmar que a mudança global fica `[PENDENTE]` e não é assumida): resultado idêntico nas duas execuções, exit codes reais conferidos (Graphify `update`/`install` via `$LASTEXITCODE`), nenhuma duplicação de instalação, nenhum vazamento de valor booleano solto no console (bug encontrado e corrigido durante a própria validação: 3 chamadas de `Invoke-Checked` fora de `if`/sem captura imprimiam `True`/`False` soltos no resumo). `python -m graphify update .` rodado ao final para refletir os arquivos alterados (2241 nós, 2767 arestas, 175 comunidades).

**O que ficou pendente desta rodada específica (ver entrada seguinte, "complementos", para o que foi fechado depois):** escolha real de cliente/modelo/permissão (nenhum terminal recrutado/reiniciado/trocado); execução real da Serena (`find_symbol` etc. de dentro de BACK/FRONT); os 3 cenários pedidos cobertos só na forma do procedimento, não simulados ponta a ponta. Nenhum commit/push feito; nenhuma config global alterada.

## 2026-10-14 — Três simulações documentais do procedimento (README → PREPARACAO.md), não teste em máquina limpa

**Isto é revisão de leitura/consistência do texto, começando pelo `README.md` como um agente novo leria, nunca uma execução real numa máquina/pasta limpa de verdade** — nenhum clone novo foi feito, nenhum comando dos cenários abaixo foi de fato rodado fora do que já está registrado na entrada anterior desta data.

### Cenário 1 — Máquina nova, só estrutura, sem domínio de negócio (Fluxo A)

- **Decisões detectáveis pelo agente, sem perguntar:** `README.md` aponta direto a `PREPARACAO.md`; Passo 1 encontra `CLAUDE.md`/`.claude/agents/`/`.gitignore` na raiz (estrutura válida); sem `automacoes/` com conteúdo e sem histórico Git de negócio → Fluxo A. Pastas em `.maestri/roles/*/`, se existirem copiadas do template original, são reconhecidas como não-prova de terminal (Passo 1.2) — só `maestri list` decide.
- **Perguntas indispensáveis:** só as de autorização (Passo 3, itens 4/5) — recrutar terminais agora? mudança de config global agora? Nome/domínio/stack **não são perguntados** (Fluxo A pula isso).
- **Ações previstas:** Passo 4 (`setup-maquina.ps1`) instala/valida RTK, Serena, Graphify, UI UX Pro Max; Passo 5 é majoritariamente pulado (nada de domínio para gravar); Passo 6 apresenta o catálogo de papéis só se houver `.maestri/` e autorização, mas não recruta por padrão; Passo 7 só roda se algo for de fato recrutado; Passo 9 fica pendente de execução real; Passo 10 registra o estado.
- **Critério de conclusão:** `Preparado` quando as 4 ferramentas estiverem `[OK]` sem `[FALHA]`/`[PENDENTE]` genuíno; `Validado` exigiria também a execução real do Passo 9, que normalmente não faz sentido cobrar aqui (ainda não há código de projeto para a Serena indexar, por exemplo) — registrar como `Preparado` com essa ressalva, não forçar `Validado` artificialmente.

### Cenário 2 — Projeto novo, equipe e cliente/modelo escolhidos (Fluxo B)

- **Decisões detectáveis:** mesmos sinais do Passo 1, mas o usuário já descreveu o que vai construir → Fluxo B.
- **Perguntas indispensáveis:** nome do projeto, domínio de negócio real, confirmação de stack Node/TS/React (Passo 3, itens 1–3) — aqui sim, porque vão preencher `CLAUDE.md`; autorizações de recrutamento/config global (itens 4–5).
- **Ações previstas:** Passo 4 igual ao Cenário 1; Passo 5 preenche `CLAUDE.md`/`.serena/project.yml`/`MODELOS_CLIENTES.local.md` de verdade com os dados coletados; Passo 6 apresenta o catálogo completo (tabela de papéis) e checa `maestri list` antes de recrutar, para não duplicar; Passo 7 detecta clientes disponíveis na máquina (Claude Code/Codex/Antigravity, só os instalados), apresenta cliente+modelo+permissão por papel antes de recrutar, pede aprovação separada para permissão total, e confirma depois o que de fato iniciou; Passo 8 orienta autenticações; Passo 9 roda a validação real por ferramenta já que agora há projeto de verdade para testar contra.
- **Critério de conclusão:** `Validado` só depois que cada papel recrutado tiver cliente/modelo/permissão confirmados de verdade (não só pedido) e a Serena/Graphify/RTK/UI UX Pro Max tiverem passado pela execução real do Passo 9 — não só instalados.

### Cenário 3 — Projeto existente, preservando governança/histórico (Fluxo C)

- **Decisões detectáveis:** `automacoes/` com conteúdo real, histórico Git com commits de negócio, `CLAUDE.md`/`.claude/agents/` próprios diferentes do template → Fluxo C (Passo 1.3). Remoto Git do projeto, se diferente do remoto herdado do template, é identificado e registrado, nunca alterado sozinho.
- **Perguntas indispensáveis:** só nome (se divergir do já documentado) e autorizações — domínio/stack são lidos do próprio projeto, não perguntados; e, para cada arquivo que o template normalmente cria/sobrescreve (`CLAUDE.md`, `.claude/agents/*.md`, `.gitignore`, `scripts/setup-maquina.ps1`, `GUIAS.md`, `README.md`, `PREPARACAO.md`), a decisão explícita por arquivo (manter o do projeto / adotar o do template / mesclar) é levantada com o usuário, nunca assumida.
- **Ações previstas:** backup do arquivo existente antes de qualquer sobrescrita; `.git` do projeto nunca é substituído/excluído; Passo 4 roda igual (ferramentas são aditivas, não conflitam com código do projeto); Passo 5 só toca os arquivos que a decisão por arquivo autorizou, tipicamente mesclando seções de governança em vez de substituir `CLAUDE.md`/`DIARIO_DE_BORDO.md` próprios; Passo 6/7 seguem iguais ao Cenário 2, mas sem recrutar papel que já exista; Passo 9 confirma que a integração de ferramentas (Serena/Graphify) não tocou em nada do código/histórico do projeto.
- **Critério de conclusão:** `Validado` exige, além do mesmo padrão do Cenário 2, confirmação explícita de que nenhum arquivo do projeto foi sobrescrito silenciosamente (cada conflito tem decisão registrada) e que o histórico Git/diário próprios permanecem intactos.

### Complementos fechados nesta mesma data (pedido de "completar lacunas")

Depois da rodada acima, o usuário pediu para completar as lacunas restantes. Fechado nesta mesma data, só na pasta do template, sem commit/push, sem recrutar/reiniciar/enviar tarefa a terminal:

1. **`calc-auditor.md`/`migration-guardian.md` criados** (`.claude/agents/`), genéricos, consistentes com a governança central deste `CLAUDE.md`, sem regra de negócio de outro projeto (ex. Analise de Custos). `CLAUDE.md`, `PREPARACAO.md` (Passo 6/item de pré-requisito) e `.claude/agents/cto.md` atualizados para refletir que a instrução genérica existe, mas ainda precisa de revisão com o usuário por automação real antes do primeiro acionamento — não é a mesma coisa que "ativado".
2. **Três simulações documentais completas registradas** (ver entrada acima, "Três simulações documentais do procedimento") — decisões detectáveis, perguntas indispensáveis, ações previstas e critério de conclusão por cenário (A/B/C), explicitamente marcadas como revisão de leitura, não teste real.
3. **Exclusões do Graphify revisadas e corrigidas:** criado `.graphifyignore` na raiz excluindo `.claude/skills/*/data/**` e `.claude/skills/*/scripts/tests/fixtures/**` (dados internos extensos de skills — ex. `phosphor-icons-upstream.json` 808KB, `google-font-licenses.json` 424KB — que não ajudam a navegar a arquitetura e só incham o grafo). `.gitignore` já cobria `node_modules/`, segredos (`.env`/`*.pem`/`*.key`/`*.cert`), builds e `MODELOS_CLIENTES.local.md` — confirmado por leitura, sem achado. **Verificação real:** `python -m graphify update . --force` rodado; confirmado via `detect()` (chamado diretamente em Python) que os arquivos do `.graphifyignore` saem da lista de arquivos candidatos; confirmado via leitura de `graphify-out/graph.json` que **zero nós** vêm desses caminhos (0 ocorrências buscadas programaticamente); `manifest.json` antigo (que ainda listava os caminhos excluídos, resquício de antes do `.graphifyignore` existir) foi removido e reconstruído do zero — confirmado limpo depois. Query real de uma relação conhecida (`python -m graphify explain "calc-auditor"`) retornou as conexões corretas do arquivo novo.
4. **Registro do RTK corrigido:** a falha de RTK 0.46.0 sem o subcomando `hook antigravity` é tratada explicitamente como **evidência externa relatada pelo usuário (teste real na máquina de destino), não reproduzida nesta sessão** — esta máquina só tem o binário 0.52.0, onde o subcomando foi confirmado via `rtk hook antigravity --help` (exit 0). `scripts/setup-maquina.ps1`, `PREPARACAO.md` (Passo 9) e o comentário do bloco RTK no script foram reescritos para não atribuir a causa à versão sem teste local, e para deixar explícito que o uso direto do RTK (`rtk ls`/`rtk grep -r`/`rtk git status`/`rtk test <cmd>`) continua disponível sempre que o hook automático estiver `[FALHA]`/pendente — o preparo verifica a capacidade do subcomando antes de contar com o hook, nunca depois.
5. **Alcance de `-AutoYes`/`-ConfirmGlobalChanges` documentado explicitamente:** cabeçalho do script e `PREPARACAO.md` Passo 4 agora deixam claro que `-AutoYes` nunca autoriza (a) mudança de configuração GLOBAL (só `-ConfirmGlobalChanges` faz isso, e só para o registro MCP da Serena), (b) permissão total a cliente/agente (decisão do Passo 7, sempre separada), ou (c) recrutar/reiniciar/enviar tarefa a terminal Maestri (Passo 6, sempre manual). Comportamento já estava correto no código (`Confirm-Action -AllowAutoYes:$false` no prompt de mudança global) — **confirmado de novo por execução real**: rodei o script 2x com `-NonInteractive -AutoYes` (sem `-ConfirmGlobalChanges`) e o registro MCP global continuou `[PENDENTE]` nas duas vezes.

**O que ainda não foi feito (pendência real, fora do que pode ser verificado sem recrutar/executar terminal):**
- Nenhum cliente/modelo real foi detectado/escolhido/aplicado a um papel — nenhum terminal foi recrutado, reiniciado ou teve cliente/modelo trocado, conforme instruído em ambas as rodadas.
- A Serena não teve uma chamada de `find_symbol`/edição de exemplo executada de dentro de um terminal real BACK/FRONT — pendência não-bloqueante, igual já registrado em 2026-10-13.
- Os 3 cenários continuam sendo revisão documental (leitura/consistência do procedimento), não uma execução ponta a ponta numa máquina/pasta realmente limpa — isso só acontece quando alguém clonar de verdade.
- Nenhum commit/push feito nesta tarefa. Nenhuma config global desta máquina alterada (registro MCP da Serena continua pendente, como estava).

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

## 2026-10-14 — Prisma Skills locais

Incluídas prisma-cli, prisma-client-api e prisma-orm-setup da origem oficial prisma/skills, licença MIT, revisão be16a8740d01363d13552b317042431ee8dfc581. Guia PRISMA_SKILLS.md centraliza compatibilidade por versão e leitura explícita sob demanda; README, CLAUDE, preparação e CTO/BACK/Migration/SPEC/TESTER apontam para ele. Nenhum ORM, MCP ou banco foi instalado, atualizado ou acessado. Instalação e referências conferidas localmente; uso em terminais reais e em banco ainda não testado.

**Commit:** `cfb6b8a` (junto com os complementos de portabilidade da entrada anterior) — autorizado explicitamente pelo usuário depois desta entrada ter sido escrita; sem push.

## 2026-10-14 — Better Auth: guia central sob demanda, sem skill local

Pedido: integrar orientação oficial de Better Auth (https://better-auth.com/docs/introduction, https://github.com/better-auth/better-auth, licença MIT) para uso sob demanda em projetos Node/TS/React (login/sessão, verificação de e-mail/2FA, organizações/papéis, autorização no backend/isolamento entre tenants, cookies/segredo/origens).

**Achado antes de instalar:** existe repositório oficial de skills (`https://github.com/better-auth/skills`, mantido pela própria better-auth — `alex@better-auth.com`, `marketplace.json` v1.0.0, commit `20c9e88a5c007461a703f1c213572b073196113e`), com 6 skills (`best-practices`, `create-auth`, `emailAndPassword`, `organization`, `twoFactor`, `security`) cobrindo exatamente os tópicos pedidos. **Mas esse repositório não declara licença** (API do GitHub: `license: null`; nenhum arquivo `LICENSE`) — diferente do caso Prisma (MIT explícito). Registrado ao usuário antes de copiar qualquer arquivo; decisão do usuário: **não instalar localmente**, só referenciar a origem oficial.

**O que foi feito:** criado `BETTER_AUTH.md` (guia central) documentando origem/licença do framework (MIT) e a ausência de licença do repositório de skills (por isso nenhuma cópia local), os tópicos a orientar, responsabilidades (BACK implementa+testa, Segurança revisa, Migration revisa schema, TESTER executa, FRONT integra sem assumir que UI esconde = proteção), os testes de aceite esperados (acesso por papel, isolamento entre organizações, expiração/revogação de sessão, logout, recuperação de senha) e a regra de projeto existente (identificar auth atual antes de qualquer adoção, nunca migrar automaticamente). Referenciado em `README.md`, `CLAUDE.md`, `PREPARACAO.md` e nas seções "Better Auth (sob demanda)" de `.claude/agents/backend-dev.md`, `security-auditor.md`, `migration-guardian.md`, `test-runner.md`, `frontend-dev.md`.

**Verificações reais executadas:** `gh api repos/better-auth/skills` (license null, default branch, commit HEAD), `gh api .../contents/*` lendo o frontmatter das 6 `SKILL.md` e o `.claude-plugin/marketplace.json` para confirmar tópicos/versão/autor — não foi assumido por suposição.

**Pendências reais:** nenhum SKILL.md copiado (decisão deliberada pela ausência de licença); nenhuma implementação real de Better Auth num projeto, nenhum teste de aceite executado, nenhum MCP configurado. Nenhum ORM/banco/tela de demonstração criado. Sem commit/push nesta tarefa.

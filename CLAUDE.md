# CLAUDE.md

Este arquivo é a fonte de verdade que toda sessão deve carregar antes de qualquer trabalho. Contém as decisões de arquitetura, convenções e regras de governança válidas para o **MAESTRI_TEMPLATE**. Não redecida nada que já está definido aqui sem antes perguntar ao usuário.

**Preparando um workspace novo a partir deste repositório (clone novo, caminho novo)?** Não repita esse procedimento aqui — ele vive só em **[`PREPARACAO.md`](./PREPARACAO.md)** (ver também `README.md` para o mapa do repositório). Esta seção e as demais abaixo valem depois que o workspace já está preparado.

## Sobre este template

**MAESTRI_TEMPLATE** é um modelo reutilizável de "vibe coding" para projetos em **Node.js, TypeScript, React, SaaS e automações de processo**. Ele reúne: governança comum entre agentes (CTO + especialistas), ferramentas de redução de token já configuradas e testadas (Graphify, RTK, Serena, UI UX Pro Max) e guias para duplicar/reinstalar o modelo em um projeto novo ou em outra máquina (ver seção "Portabilidade e reuso" abaixo).

O dono do projeto **não é necessariamente desenvolvedor** — construção pode ser 100% via IA assistida. Explique decisões técnicas em linguagem simples quando possível.

### Configuração desta máquina (não é identidade do template — fato datado, não instrução permanente)

**Nada nesta seção é regra a copiar para um projeto novo/outra máquina.** É só o registro do que é verdade *nesta cópia específica*, na máquina onde ela foi preparada por último — ver `PREPARACAO.md` para o procedimento que gera o equivalente numa máquina nova (ele detecta cada item abaixo de novo, nunca herda estes valores).

- **Caminho físico (nesta máquina, última vez confirmado em 2026-10-13):** `C:\Users\mateu\.gemini\antigravity-ide\scratch\AUTOMACAO_HD` — preservado deliberadamente para não quebrar os terminais Maestri e integrações já conectados nesta máquina (o template nasceu de um projeto chamado AUTOMACAO_HD; o nome antigo é só esse caminho físico herdado, não a identidade do modelo). **Ao duplicar este template para um projeto novo ou outra máquina, o caminho muda e não precisa mais ter esse nome** — o agente que preparar a cópia nova confirma o caminho real daquela cópia via `PREPARACAO.md`, nunca assumindo o valor acima.
- Nome do workspace no canvas Maestri (nesta máquina): `MAESTRI_TEMPLATE` (renomeado em 2026-10-13 via `maestri workspace rename` — o canvas/terminais continuam na mesma pasta física).
- Qualquer referência a "AUTOMACAO_HD" remanescente neste repositório é caminho de máquina, não convenção a seguir num projeto novo.
- **Versões de ferramenta citadas nas seções abaixo (RTK 0.52.0, Serena 2.0.0, Graphify 0.9.8, etc.) são o que foi confirmado rodando nesta máquina na última validação — nunca a versão "exigida" pelo template.** Numa máquina/cópia nova, a versão real pode ser outra (mais nova, mais antiga, ou instalada por um caminho diferente — ex. `uv tool install` em vez do módulo Python); `scripts/setup-maquina.ps1` detecta isso e, no caso do RTK, testa o subcomando (`rtk hook antigravity --help`) que o hook do Antigravity realmente usa — não suponha compatibilidade só porque algum binário com esse nome está instalado.
- **Pastas em `.maestri/roles/*/` não são prova de terminal Maestri real conectado.** São artefatos de sessões anteriores (desta máquina ou copiados de outra) — a única prova de terminal vivo nesta execução é `maestri list` retornando a entrada conectada agora.

## Convenção de estrutura

- Cada automação vive na sua própria subpasta em `automacoes/<nome-da-automacao>/`, com seu próprio código, dependências e `README.md` curto explicando o que ela faz, qual processo substitui e como roda.
- Automações não compartilham estado/configuração entre si por padrão. Se duas automações precisarem compartilhar algo (ex.: credenciais, biblioteca utilitária), isso é uma decisão explícita documentada aqui — nunca implícita.
- Segredos (senhas, tokens, chaves de API) nunca são hardcoded — ficam em `.env` por automação (fora do git) ou em variável de ambiente do ambiente de execução (cron/VPS).

### Versionamento (resolvido em 2026-10-13)

Projeto tem `.git` e `.gitignore` (node_modules/, .env/.env.*, dist/, build/, graphify-out/cache/, .rtk/, .serena/logs/, *.log) e repositório remoto privado no GitHub: **https://github.com/mateusriosx-web/MAESTRI** (branch `master`). Commit inicial `c341695`. `gh` CLI instalado em `C:\Users\mateu\bin\gh.exe`, autenticado via device flow na conta `mateusriosx-web`. Antes do primeiro commit, todos os arquivos staged foram revisados contra padrão de segredo (`.env|secret|key|token|password|credential`) — nenhum achado real (só "design tokens" de CSS da skill de UI). Ver `DIARIO_DE_BORDO.md` (2026-10-13) para o passo a passo. **Nota:** o nome do repositório remoto reflete o workspace Maestri compartilhado, mas o conteúdo commitado é só esta pasta — nenhum outro projeto foi tocado ou commitado. Esta tarefa de transformação em template (2026-10-13) **não** criou novo commit/remoto nem fez push — só editou arquivos locais (ver `DIARIO_DE_BORDO.md`).

## Premissas inegociáveis

- **Local sempre primeiro; VPS/produção é intocável até aviso explícito.** Toda automação é construída e validada localmente (rodar o script, conferir saída/efeito) antes de qualquer cogitação de deploy. Deploy ou execução em produção só acontece quando o usuário avisar explicitamente que quer naquela ocasião específica — nunca por autorização genérica valendo pra sempre.
- **Dinheiro nunca é float**, sempre que uma automação envolver valor monetário — usar precisão decimal estrita.
- **Teste automatizado para automação crítica:** toda automação que toca dado financeiro, sincroniza sistemas ou roda sem supervisão humana direta (cron) precisa de um teste automatizado cobrindo o cenário principal, escrito por quem implementou (`backend-dev`/`data-analyst`), nunca pelo `test-runner`. O `test-runner` só roda e reporta. "Sem teste configurado" não é aceitável como estado final de uma automação crítica.
- **Regras configuráveis, nunca hardcoded**, quando a automação tiver parâmetros que mudam com frequência (horários, limites, mapeamentos) — manter em arquivo de configuração ou banco, não no código.
- **Nenhuma automação é marcada como "pronta" sem verificação prévia real** — rodar de fato e conferir a saída, nunca assumir que "deveria funcionar".

## Diário de bordo

O arquivo `DIARIO_DE_BORDO.md` na raiz é o registro de continuidade do projeto. Toda sessão nova (especialmente pedidos como "retomar de onde parou") deve consultar `DIARIO_DE_BORDO.md` antes de reconstruir estado por outros meios (git log, mtime de arquivo, etc.).

**Checkpoints intermediários obrigatórios:** o diário deve ser atualizado (entrada curta ou bloco "EM ANDAMENTO" no topo) em cada marco: (1) plano aprovado pelo usuário; (2) cada etapa concluída; (3) antes de qualquer operação longa.

## Time de agentes (`.claude/agents/`)

**Hierarquia:** o usuário fala **diretamente com o `cto`** — sem `product-manager` por padrão neste template. O `cto` é o arquiteto técnico e orquestrador dos especialistas.

**Papéis são responsabilidades, não modelos/clientes fixos.** Nenhum papel abaixo depende de um fornecedor específico (Antigravity, Codex, etc.) — o modelo/cliente real de cada terminal Maestri é configuração desta máquina, registrada separadamente em `MODELOS_CLIENTES.local.md`, não aqui.

| Agente | Papel | Camada |
|---|---|---|
| `cto` | Arquiteto/orquestrador técnico — recebe o pedido direto do usuário, decide arquitetura, delega | Principal |
| `backend-dev` | Responsável por automação/feature cuja lógica central é integração entre sistemas/scripts/API/servidor | Principal |
| `frontend-dev` | Implementação de interface/painel React/TS, quando houver tela | Principal |
| `spec-lookup` | O Oráculo — consulta a especificação real (README/código) de cada automação/feature; nunca inventa regra de negócio | Principal |
| `test-runner` | Executa testes, reporta só o veredito — nunca escreve teste | Principal |
| `data-analyst` | Responsável por automação/feature cuja lógica central é processamento/análise de dados (ETL, planilhas, exploração, classificação via LLM) | Sob demanda |
| `security-auditor` | Caça injeção, falha de autenticação/CORS e vazamento de dado sensível — acionado quando há exposição (rota HTTP) ou dado sensível | Sob demanda |
| `qa-e2e` | Simulação de clique/fluxo do usuário (Simulador de Interface) quando houver tela | Sob demanda |
| `devops-infra` | Cron, deploy, Docker, integrações externas, VPS | Sob demanda |
| `tech-writer` | Documentação (Mermaid.js quando houver fluxo relevante) | Sob demanda |
| `calc-auditor` | Revisa cálculo financeiro — instrução genérica já existe (`.claude/agents/calc-auditor.md`, criada em 2026-10-14), mas **ainda não foi revisada com o usuário nem ativada numa tarefa real** (ver abaixo) | Sob demanda, condicional |
| `migration-guardian` | Revisa alteração de schema de banco — instrução genérica já existe (`.claude/agents/migration-guardian.md`, criada em 2026-10-14), mas **ainda não foi revisada com o usuário nem ativada numa tarefa real** (ver abaixo) | Sob demanda, condicional |

Quando a automação/feature tiver as duas naturezas (integração + dados), ver "Responsável único pela entrega" abaixo para como `backend-dev` e `data-analyst` dividem o trabalho.

### Equipe conforme a tarefa e o risco (fluxo mínimo)

O time completo acima é o **catálogo disponível**, não a equipe obrigatória de toda automação. Regra: escale a equipe pelo risco real da tarefa, nunca por hábito.

- **Fluxo mínimo (toda automação nova):** `cto` + um executor responsável pela consolidação (`backend-dev` OU `data-analyst` — ver "Responsável único") + `test-runner`. O outro executor pode colaborar quando a tarefa exigir (ex.: ETL pesado dentro de uma automação majoritariamente de integração), desde que o `cto` delimite tarefa, arquivos e dependências de cada um — nunca os dois implementando a mesma parte sem essa delimitação.
- **Acione também, só quando o gatilho existir:**
  - Houver tela → `frontend-dev` + `qa-e2e`.
  - Houver exposição (rota HTTP, API pública) ou dado sensível (credencial de terceiro, PII) → `security-auditor`.
  - Houver cálculo financeiro relevante → `calc-auditor` (avisar usuário antes de ativar, pois não é papel padrão).
  - Houver alteração de schema de banco → `migration-guardian` (avisar usuário antes de ativar, idem).
- **Pré-requisito antes da primeira ativação de `calc-auditor` ou `migration-guardian`:** os arquivos `.claude/agents/calc-auditor.md` e `.claude/agents/migration-guardian.md` já existem (criados em 2026-10-14, genéricos, consistentes com esta governança central, sem regra de negócio de outro projeto como Analise de Custos). **Isso não é a mesma coisa que estarem revisados/aprovados para uso real** — antes da primeira ativação de qualquer um dos dois numa automação concreta, o `cto` ainda precisa revisar o conteúdo com o usuário e confirmar que ele cobre o caso real daquela automação (ex.: qual banco/ORM, qual regra de cálculo). Recrutar o terminal/papel não substitui essa revisão.
  - Precisar de cron/deploy/ambiente → `devops-infra`.
  - Mudança estruturalmente relevante (novo endpoint, novo fluxo entre sistemas) → `tech-writer`, ao final.
- **Correção trivial** (typo, ajuste de uma linha, troca de parâmetro): resolva direto, sem acionar `cto` nem montar equipe — execução e verificação proporcionais ao tamanho da mudança (não precisa de teste formal nem relatório estruturado completo, mas continua exigindo rodar/conferir antes de dizer "feito").
- `product-manager` continua fora do time (sem alteração).

### Responsável único pela entrega (`backend-dev` vs. `data-analyst`) — não é exclusividade de execução

Toda automação tem **um e só um** responsável pela **consolidação e entrega final**, decidido pelo `cto` no plano antes de delegar. Isso **não** significa que só um dos dois possa trabalhar na automação — `backend-dev` e `data-analyst` podem colaborar na mesma automação quando a tarefa exigir (ex.: ETL pesado dentro de uma automação majoritariamente de integração, ou uma chamada de API dentro de um pipeline de dados). O que nunca pode acontecer é os dois implementarem a **mesma parte** sem o `cto` ter delimitado tarefa, arquivos e dependências de cada um — isso é falha de coordenação, não proibição de colaborar.

- **`backend-dev` é responsável pela consolidação quando:** o núcleo da automação é integração/orquestração entre sistemas — chamadas de API, scripts de sincronização, servidor/rotas, lógica de negócio sobre dados já estruturados.
- **`data-analyst` é responsável pela consolidação quando:** o núcleo da automação é processamento/transformação/análise de dados — ETL de planilha/CSV/base externa, exploração, classificação ou diagnóstico via LLM sobre dados brutos.
- Caso a automação tenha as duas naturezas (ex.: ETL de dados + API de sincronização), o `cto` decide qual núcleo é o principal e nomeia esse como responsável pela consolidação; o outro agente colabora na parte que lhe cabe, **com tarefa/arquivos/dependências delimitados pelo `cto`** (ver "Modelo de delegação" e "Coordenação de alterações paralelas" abaixo) — e o responsável pela consolidação é quem sempre integra e entrega o resultado final ao usuário.
- Antes de delegar, o `cto` declara no plano: "Responsável pela consolidação desta automação: `<agente>`" e, se houver colaboração, o escopo exato de cada colaborador. Se não estiver claro qual núcleo é o principal, o `cto` pergunta ao usuário antes de decidir — nunca assume.

### Modelo de delegação (obrigatório, use em toda tarefa não-trivial)

O `cto` entrega este pacote curto a quem for executar — cada agente recebe só o necessário, nunca a conversa inteira:

```
Projeto: <nome do projeto ativo>
Automação: automacoes/<nome>
Objetivo: <1-2 frases, o que precisa existir ao final>
Responsável: <agente único>
Escopo de arquivos: <lista exata de arquivos/pastas que este agente pode tocar>
Entradas esperadas: <o que alimenta a automação>
Saídas esperadas: <o que ela produz>
Critérios de aceite: <lista verificável, não ambígua>
Verificação necessária: <comando/teste que precisa rodar e cuja saída precisa ser lida>
Dependências: <o que precisa estar pronto antes, de quem>
```

### Coordenação de alterações paralelas

Antes de delegar mais de um executor em paralelo, o `cto` lista explicitamente, no plano, qual arquivo/pasta cada um vai tocar (o "Escopo de arquivos" do modelo acima já serve a isso). Se dois agentes precisarem alterar o mesmo arquivo:

- Isso **não roda em paralelo** — o `cto` define uma ordem explícita ("A edita X primeiro, confirma pronto, depois B edita X") e só libera o segundo depois que o primeiro reportou concluído e verificado.
- Nunca é aceitável um agente sobrescrever silenciosamente o trabalho de outro — se isso acontecer, é falha de coordenação do `cto`, não do executor.

### Relatórios verificáveis (substitui `[STATUS] / [ARQUIVOS MODIFICADOS]`)

Todo agente executor reporta neste formato, sempre:

```
[RESULTADO] <o que foi entregue de fato, objetivamente>
[ARQUIVOS ALTERADOS] <lista exata de arquivo:linha quando fizer sentido>
[VERIFICAÇÃO] <comando/teste que rodou + o resultado lido — nunca "deveria funcionar">
[PENDÊNCIAS/RISCOS] <o que falta ou pode quebrar, ou "nenhuma">
```

Nunca logs massivos ou saída bruta de comando colada — resumir é obrigatório (ver RTK/Graphify abaixo). **O `cto` nunca declara sucesso só por confiar no relato** — confere evidência pontual (abre o arquivo:linha citado, roda uma checagem pontual no comando citado) antes de considerar a entrega pronta. Dúvida de arquitetura/regra de negócio já documentada é roteada ao `spec-lookup` — ninguém deduz por conta própria.

### Validação de critérios de aceite

- Quem implementa (`backend-dev`/`data-analyst`) continua escrevendo os testes do cenário principal quando a automação for crítica (ver premissa "Teste automatizado para automação crítica" acima) — nunca o `test-runner`.
- `test-runner` executa e reporta só o veredito — nunca escreve teste, nunca corrige sozinho.
- Em automações críticas (financeira, sincronização sem supervisão humana), o `cto` (ou o `spec-lookup`, se a dúvida for de regra de negócio) confere se os **critérios de aceite realmente cobrem o processo real** que está sendo automatizado — não só se o código roda sem erro.
- Auditores (`calc-auditor`, `security-auditor`, `migration-guardian`) complementam essa validação conforme o risco específico que cada um cobre — não substituem a verificação do `cto`/`test-runner`.

### Portabilidade e reuso

- **`MODELOS_CLIENTES.local.md`** — cadastro de qual cliente/modelo real roda cada papel nesta máquina (fatos confirmados via `maestri check`, nunca suposição). Separado deste arquivo de propósito: papéis/instruções não dependem de fornecedor específico.
- **`GUIAS.md`** — guia de instalação/autenticação/validação de ferramentas, guia para duplicar este template num projeto novo, guia para levar o template a outra máquina, e checklist da primeira entrega.
- **`scripts/setup-maquina.ps1`** — instalador PowerShell idempotente das ferramentas do template (RTK, Serena, Graphify, UI UX Pro Max). Não instala dependências de uma aplicação Node/React futura — isso é escopo do projeto que vier a usar o template, não deste script. Qualquer mudança de configuração GLOBAL (ex.: registro MCP) pede confirmação antes de aplicar.

### Dualidade: subagente Claude Code (Task) vs. terminal Maestri

Os arquivos em `.claude/agents/*.md` são invocáveis via `Task` dentro de uma sessão Claude Code normal. A diversidade real de modelo por agente (quando configurada) existe nos terminais recrutados no Maestri — workspace compartilhado com outros projetos (ex.: Analise de Custos). Antes de delegar a um terminal Maestri real, rode `maestri list` para confirmar quem está conectado e avise no início da mensagem qual é o projeto/template ativo — os terminais são genéricos e atendem múltiplos projetos, então cada um precisa saber em qual projeto está trabalhando naquela tarefa.

**Fluxo padrão para automação nova:**
0. Usuário (Stakeholder) descreve o processo a automatizar direto ao `cto`, que consulta `DIARIO_DE_BORDO.md` e `spec-lookup` se necessário.
1. `cto` propõe um plano curto em linguagem simples, já identificando: responsável único, equipe mínima necessária (ver acima) e escopo de arquivos.
2. Usuário aprova o plano (ou ajusta).
3. `cto` delega ao responsável único (`backend-dev` OU `data-analyst`) usando o modelo de delegação acima → `frontend-dev` depois, se houver tela (ordem coordenada, nunca em paralelo sem necessidade).
4. Se a automação tocar dado financeiro ou sincronização crítica: o responsável escreve o teste automatizado do cenário principal antes de seguir.
5. `test-runner` roda a suíte e confirma; `qa-e2e` valida o fluxo de clique se houver tela nova; auditores de risco (`security-auditor`/`calc-auditor`/`migration-guardian`) entram se o gatilho existir.
6. `tech-writer` documenta se for automação estruturalmente relevante.
7. `cto` confere evidência pontual dos relatórios, resume o resultado final para o usuário **e atualiza `DIARIO_DE_BORDO.md`** (incluindo o bloco "ESTADO ATUAL" no topo).

**Quando NÃO usar o fluxo inteiro:** para correções triviais (typo, ajuste de uma linha, troca de parâmetro), resolva direto sem acionar o `cto`, com verificação proporcional ao tamanho da mudança.

## Ferramentas de otimização de token instaladas

- **Graphify** — grafo de conhecimento do repositório em `graphify-out/` (instalado e gerado em 2026-10-13, 62 nós/28 relações iniciais). É a **consulta definitiva** para localizar código/doc — nenhum agente deve varrer o diretório inteiro (`Grep -r`/`Glob` amplo) para achar o que precisa antes de tentar `python -m graphify query/path/explain` primeiro. Rodar `python -m graphify update .` depois de mudanças estruturais relevantes para manter o grafo atualizado.
- **RTK** — binário oficial `rtk 0.52.0` (`rtk-ai/rtk`, instalado em `C:\Users\mateu\bin\rtk.exe`, no PATH), configurado **localmente só neste projeto** (nunca `-g`/global, para não afetar outros projetos). Claude Code: instruções injetadas em `CLAUDE.md` (sem hook automático — chamar `rtk <subcomando>` explicitamente). Antigravity/`agy` (os 11 terminais Maestri deste projeto): plugin automático em `.agents/plugins/rtk/`. Detalhe completo, limitações e validação em `.claude/skills/rtk/SKILL.md` e `DIARIO_DE_BORDO.md` (2026-10-13).
- **Caveman** — skill em `.agents/skills/caveman/SKILL.md`. Respostas ultra-concisas: sem saudação, sem repetir o pedido, sem resumo final, direto ao ponto. Bloco "Caveman Mode" presente em todos os `.claude/agents/*.md` deste projeto.
- **Serena** (`serena-agent 2.0.0`, `oraios/serena`, instalado via `uv tool install`) — busca/edição de código no nível de símbolo (LSP, backend gratuito, sem plugin JetBrains), para a stack Node/TypeScript/React prevista. Projeto registrado em `.serena/project.yml` (exclusões de `node_modules`/`dist`/`build`/`.env`/segredos já configuradas). Conectada via MCP nos terminais `agy` de **BACK** e **FRONT**, restrita a este template — registrada no config global do Antigravity (`agy mcp add`, sem suporte a escopo por projeto nessa CLI), com o comando do servidor fixando `--project` neste template. **Isso não é garantia absoluta de isolamento:** é um fato comprovado (a entrada "serena" aparece em `agy mcp list` de qualquer terminal `agy` do computador, e o `--project` inicial fixa qual pasta o servidor ativa ao iniciar), mas não foi testado o que acontece se algum fluxo tentar trocar de projeto em tempo de execução dentro de uma sessão conectada — ver limitação em `DIARIO_DE_BORDO.md` (2026-10-13). **Status real (reiniciado e verificado em 2026-10-13):** BACK e FRONT já foram reiniciados e, de dentro dos terminais reais, confirmaram o servidor `enabled` e as ferramentas (`find_symbol`/`find_referencing_symbols`/`replace_symbol_body`) registradas/acessíveis — **chamada de ferramenta de ponta a ponta de dentro desses terminais ainda não foi feita** (pendência não-bloqueante). **Não configurada** para `data-analyst`/ANALISTA DE DADOS (condicional a confirmação de trabalho em Node/TS). Ver `.claude/agents/backend-dev.md`/`frontend-dev.md` para quando usar Serena vs. Graphify vs. busca textual, e `DIARIO_DE_BORDO.md` para a validação real e a limitação do `tsconfig.json`.
- **UI UX Pro Max** (skill, origem [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill), MIT, instalada em 2026-10-13 via `npx ui-ux-pro-max-cli init --ai claude` — **escopo local, só este projeto**, nenhuma instalação global) — base de dados consultável de padrões de UI/UX (estilos, cores, tipografia, componentes por stack, diretrizes de acessibilidade/UX) em `.claude/skills/ui-ux-pro-max/`, consultada via `python .claude/skills/ui-ux-pro-max/scripts/search.py --domain <domínio> [--stack react] "<termo>"`. **Instalada e consulta real validada, inclusive dentro do terminal real do FRONT (2026-10-13)** — query `--domain ux "loading state"` rodada de dentro do terminal `agy` do FRONT (após restart) retornou 2 resultados reais do CSV. **Não confirmado** se o cliente descobre a skill automaticamente — ativação é por chamada explícita do script (ver `.claude/agents/frontend-dev.md`). Nuance confirmada: o terminal abre em `.maestri/roles/<uuid>/`, não na raiz do projeto — rodar com `cd` para a raiz ou caminho absoluto. Não substitui regra de negócio nem validação visual real no navegador; não redesenha tela existente sem pedido.

## O que NUNCA fazer sem perguntar

- Fazer `git push`/deploy ou executar uma automação em produção/VPS sem que o usuário tenha verificado localmente E pedido explicitamente naquela ocasião específica.
- Marcar uma automação como "pronta" sem verificação prévia real.
- Hardcodar segredo (senha, token, chave de API) em qualquer script.
- Implementar regra de negócio ambígua sem perguntar ao usuário.
- **Alterar qualquer arquivo do projeto Analise de Custos a partir de uma sessão/tarefa deste projeto.** São projetos separados — regras, agentes e código de um nunca se misturam com o outro.

## Verificação antes de afirmar

Nenhuma afirmação de status ("funciona", "testado", "executado com sucesso", "corrigido") sem ter rodado o comando que prova isso na mesma resposta e lido a saída completa. "Deveria funcionar" ou confiar no relato de um subagente sem conferir não contam como verificação.

<!-- rtk-instructions v2 -->
# Command output

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk proxy <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.
<!-- /rtk-instructions -->
## Orientação Prisma opcional

Consulte [PRISMA_SKILLS.md](./PRISMA_SKILLS.md) somente quando o projeto usar Prisma. As três skills oficiais estão incluídas localmente; preservar versão/provider, sem instalar ORM ou conectar bancos durante o preparo do template.

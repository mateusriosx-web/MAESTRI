# Procedimento de preparação (único — não duplique isto em outro arquivo)

Este é o **único** procedimento de preparação do MAESTRI_TEMPLATE. `README.md` só aponta para aqui; `GUIAS.md` (Guia 2) só aponta para aqui. Se algo aqui contradizer outro arquivo, este arquivo vale.

**Quando seguir isto:** sempre que alguém (usuário ou agente) clonar este repositório num caminho novo e pedir para preparar o workspace — tipicamente com uma instrução curta como "Clone \<URL\> e siga as instruções do repositório para preparar este workspace."

**Quem segue isto:** o agente que receber esse pedido assume o papel de `cto` a partir do passo 2 abaixo — leia `CLAUDE.md` e `.claude/agents/cto.md` antes de continuar.

---

## Passo 0 — Antes de tudo: isto é uma revisão de fluxo ou uma preparação real?

Se você está lendo este arquivo para **revisar se o procedimento faz sentido** (sem máquina limpa, sem clone novo de verdade), isso é uma **revisão documental** — deixe claro no seu relatório que não é um teste real em máquina limpa. Se você está preparando um workspace de verdade, siga os passos abaixo executando cada comando, não apenas lendo.

## Passo 1 — Identificar a raiz do projeto e qual fluxo seguir (estrutura só, projeto novo, ou projeto existente)

1. Confirme que o diretório atual (ou o caminho que recebeu) contém `CLAUDE.md`, `.claude/agents/`, `.gitignore` — se não contém, você não está na raiz certa, pare e avise.
2. Verifique se existe `.maestri/` nessa raiz:
   - Se existir: rode `maestri list` e `maestri workspace list`. Confirme se o caminho do workspace ativo no Maestri **é exatamente** esta raiz. Se não for (ex.: o workspace Maestri aponta para outro caminho), isso é uma divergência real — avise o usuário antes de continuar, não assuma qual está certo.
   - Se não existir `.maestri/`: este projeto não tem workspace Maestri associado ainda. Isso não bloqueia o resto da preparação (ferramentas/skills funcionam sem o Maestri), mas a parte de "recrutar agentes" (Passo 6) não pode ser feita — registre como pendência.
   - **Pastas em `.maestri/roles/*/` não são prova de terminal real conectado agora** — são artefatos deixados por sessões anteriores (inclusive de outra máquina, se a pasta foi copiada). A única prova de terminal vivo é `maestri list` retornando a entrada conectada nesta execução. Nunca assuma equipe recrutada só porque a pasta existe.
3. **Detecte qual dos três fluxos abaixo se aplica antes de perguntar qualquer coisa de negócio ao usuário** — isso evita pedir domínio/stack de um projeto que já tem os dois definidos, e evita propor exclusão/substituição de algo que já existe:

   - **Fluxo A — Preparar só a estrutura (sem projeto nenhum ainda).** Sinal: a raiz só tem os arquivos permanentes do template (`CLAUDE.md`, `PREPARACAO.md`, `.claude/agents/*.md`, `GUIAS.md`, `scripts/`, `README.md`) e nenhuma pasta `automacoes/` com conteúdo real, nenhum histórico Git de negócio (olhe `git log --oneline` — se só tiver commits do próprio template, é sinal de Fluxo A ou B). Aqui você **não precisa saber domínio de negócio nem código de aplicação** — só prepara ferramentas/ambiente (Passo 4) e deixa `CLAUDE.md`/time genéricos. Não pule para os Passos 3/5 pedindo domínio de negócio sem necessidade.
   - **Fluxo B — Projeto novo** (a pessoa já sabe o que vai construir, mas não há código ainda). Sinais: pasta `automacoes/` vazia ou ausente, sem histórico Git de negócio. Aqui sim você pergunta domínio de negócio e stack (Passo 3), porque vai preencher `CLAUDE.md` para orientar decisões desde já.
   - **Fluxo C — Projeto existente** sendo incorporado a este template (ex.: alguém está adotando a governança do MAESTRI_TEMPLATE num repositório que já tem código, histórico Git, talvez seu próprio `CLAUDE.md`/agentes/diário). Sinais: `automacoes/` com conteúdo real, histórico Git com múltiplos commits de negócio, `CLAUDE.md`/`.claude/agents/` já existentes com conteúdo diferente do template, remoto Git já configurado para outro repositório. **Neste fluxo:**
     - **Nunca proponha excluir em massa nem substituir o `.git` como procedimento padrão.** Se houver `.git` já existente, ele é preservado — não há `git init` sobrescrevendo histórico.
     - Resolva **conflito arquivo por arquivo**: para cada arquivo que o template normalmente cria/sobrescreve (`CLAUDE.md`, `.claude/agents/*.md`, `.gitignore`, `scripts/setup-maquina.ps1`, `GUIAS.md`, `README.md`, `PREPARACAO.md`), se já existir uma versão do projeto com conteúdo próprio, **não sobrescreva silenciosamente** — faça backup do arquivo existente (cópia com timestamp numa pasta fora do projeto, ou subpasta explícita), compare, e proponha ao usuário um plano explícito por arquivo (manter o do projeto / adotar o do template / mesclar os dois) antes de tocar.
     - Preserve código, diário (`DIARIO_DE_BORDO.md` próprio), agentes customizados e stack própria do projeto — a incorporação deste template adiciona governança/ferramentas, não apaga o que já existe.
     - Se o projeto já tem um remoto Git configurado (`git remote -v`) diferente do remoto herdado deste template (`https://github.com/mateusriosx-web/MAESTRI`, documentado em `CLAUDE.md`), **identifique e registre essa divergência explicitamente no diário, sem alterar o remoto automaticamente** — qual remoto fica é decisão do usuário, nunca assumida.

4. Se não conseguir decidir entre A/B/C pelos sinais acima, pergunte ao usuário diretamente ("isto é uma pasta nova, um projeto novo que você vai descrever, ou um projeto que já existe e está sendo incorporado ao template?") — não adivinhe.

## Passo 2 — Assumir o papel de `cto`

A sessão que executa este procedimento **assume o papel de `cto` diretamente — não recrute outro terminal/agente para o papel `cto`** (ver Passo 6). O papel `cto` continua existindo no catálogo de agentes mesmo quando não há um terminal Maestri dedicado para ele; quem está lendo este arquivo já está exercendo esse papel.

Leia `CLAUDE.md` (raiz) e `.claude/agents/cto.md` por completo antes de prosseguir. A partir daqui você segue as regras de lá (modelo de delegação, relatórios verificáveis, etc.) — este procedimento só cobre a preparação inicial, não substitui aquelas regras.

## Passo 3 — Perguntar só o que não pode ser detectado

Não pergunte o que você consegue checar sozinho (ex.: se o Python está instalado — isso o script do Passo 4 detecta). O que perguntar depende do fluxo identificado no Passo 1:

- **Fluxo A (só estrutura):** não pergunte nome de projeto, domínio de negócio nem stack — nada disso existe ainda. Pergunte só os itens 4 e 5 abaixo (autorizações), e só se forem de fato relevantes agora (ex.: sem `.maestri/`, o item 4 nem se aplica).
- **Fluxo B (projeto novo):** pergunte os 5 itens abaixo.
- **Fluxo C (projeto existente):** não pergunte domínio de negócio nem stack — já estão implícitos no código/histórico existente; confirme-os por leitura (`README.md`/`package.json`/código do projeto), não por pergunta. Pergunte apenas: nome (se divergir do que já está documentado no próprio projeto), autorizações (itens 4 e 5), e as decisões de conflito arquivo por arquivo levantadas no Passo 1.3 (Fluxo C).

1. **Nome do projeto novo** (se for diferente do nome herdado da pasta/template) — não adivinhe.
2. **Domínio de negócio real** (o que o projeto faz de verdade) — necessário para substituir o texto genérico de "Sobre este template" em `CLAUDE.md`; sem isso, o `CLAUDE.md` fica genérico demais para orientar decisões de negócio. **Só pergunte no Fluxo B.**
3. **Se a stack ainda é Node.js/TypeScript/React/SaaS** — se não for, pare e avise que as premissas de stack do template (Serena configurada para TS, UI UX Pro Max, etc.) precisam de revisão antes de seguir. **Só pergunte no Fluxo B; no Fluxo C, confirme por leitura.**
4. **Se autoriza recrutar terminais Maestri reais agora** (Passo 6) — isso cria/reconfigura processos reais, nunca faça sem essa autorização explícita.
5. **Se autoriza mudanças de configuração GLOBAL desta máquina** (registro do MCP da Serena, PATH do usuário) — o script do Passo 4 já pede isso individualmente, mas avise que isso vai acontecer.

Tudo que não está nesta lista, você detecta sozinho nos passos seguintes.

## Passo 4 — Instalar e validar dependências/ferramentas/skills (script idempotente)

Rode interativamente (o script pergunta Y/N a cada instalação/registro e nunca trata ausência de resposta como recusa — fica `[PENDENTE]`):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "<caminho da raiz deste projeto>"
```

Ou de forma não interativa (ex.: dentro de um agente sem stdin), explicitando o que autoriza:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "<caminho>" -NonInteractive -AutoYes
# -AutoYes só cobre instalações locais ao projeto (RTK/Graphify/UI UX Pro Max/Serena).
# Mudança de configuração GLOBAL (registro MCP da Serena) exige, além disso,
# autorização explícita do usuário NESTA ocasião, repassada como -ConfirmGlobalChanges.
```

O script é seguro para reexecução (detecta o que já está instalado, não duplica config). Ele confere o código de saída real de cada comando — nunca declare uma ferramenta "instalada"/"ok" só porque o script terminou sem travar; leia o resumo final (`[OK]`/`[FALHA]`/`[PENDENTE]`/`[MANUAL]` por item e a linha `ESTADO:` no final) e trate cada `[FALHA]`/`[PENDENTE]`/`[MANUAL]` — alguns exigem ação humana (login de IA, por exemplo) que nenhum script automatiza.

**`-AutoYes` não é uma autorização geral.** Ela só responde "sim" para instalações locais ao projeto dentro deste script (RTK/Graphify/UI UX Pro Max/Serena). Ela nunca autoriza mudança de configuração GLOBAL (isso exige `-ConfirmGlobalChanges`, separado e explícito), nunca concede permissão total a um cliente/agente (isso é decisão do Passo 7, sempre com aprovação própria) e nunca recruta/reinicia/envia tarefa a terminal Maestri (isso é o Passo 6, sempre manual). Trate os três como autorizações independentes — nunca infira uma a partir da outra.

**Não pule este passo mesmo que pareça redundante com o Passo 1** — o Passo 1 confere a estrutura do repositório; este passo confere o que está instalado *nesta máquina*, que é informação nova a cada máquina diferente. **Não suponha que a versão instalada é compatível com os hooks copiados** — o script testa o subcomando real que o hook do Antigravity usa (`rtk hook antigravity --help`), não só `rtk --version`; uma falha aí é um achado real sobre esta instalação, não deve ser atribuída a "a versão X não funciona" sem confirmar (ex.: testando outra versão ou lendo o changelog da ferramenta).

## Passo 5 — Adaptar nome e caminhos ao novo projeto

**No Fluxo C (projeto existente):** este passo só se aplica aos arquivos que o Passo 1.3 decidiu adotar do template (não sobrescreva o que o projeto já tinha e o usuário optou por manter). Se o projeto já tem seu próprio `CLAUDE.md`/`DIARIO_DE_BORDO.md`, normalmente a decisão é mesclar a governança do template como seções adicionais, não substituir o arquivo do projeto.

1. Em `CLAUDE.md`, seção "Sobre este template": substitua pelo domínio de negócio real coletado no Passo 3 (deixe de ser um template genérico, vire a governança daquele projeto específico). No Fluxo A, pule este item — não há domínio ainda.
2. Recrie `.serena/project.yml` com `serena project create --name "<nome>" --language typescript .` — **não copie o arquivo antigo**, o caminho embutido nele pertence ao template de origem, não ao projeto novo.
3. Se a Serena já estava registrada no MCP do cliente (ex. `agy mcp list` mostra `serena`), o `--project` do comando continua apontando para o caminho antigo até você re-registrar com o caminho novo — isso é mudança de configuração GLOBAL, avise e peça confirmação antes (o Passo 4 já cobre isso se rodado depois da cópia).
4. **Se `MODELOS_CLIENTES.local.md` ainda não existir nesta máquina**, crie-o copiando `MODELOS_CLIENTES.example.md` (`cp MODELOS_CLIENTES.example.md MODELOS_CLIENTES.local.md`) e preencha com os fatos confirmados nesta máquina/projeto novo — nunca herde a tabela de outro projeto. **Se já existir, não o sobrescreva** — ele é ignorado pelo Git (contém dados pessoais) e pode já ter dados corretos; só atualize os campos que mudaram.
5. Se `.maestri/roles/*/CLAUDE.md`/`AGENTS.md` existirem e tiverem uma linha de `working_directory` apontando para o caminho antigo, isso só é corrigido de fato recriando/reatribuindo o terminal Maestri real (ver Passo 6) — editar o texto sem mover o terminal não resolve.

## Passo 6 — Apresentar o catálogo de papéis e preparar a equipe (recrutamento só com suporte Maestri e autorização)

**Recrutar ≠ acionar.** Recrutar é só deixar o papel disponível (terminal conectado, pronto para receber tarefa); acionar é de fato delegar uma tarefa a ele. Um papel recrutado não precisa trabalhar em toda automação — isso é decidido tarefa a tarefa, conforme o gatilho real (ver `CLAUDE.md`, "Equipe conforme a tarefa e o risco").

1. **Antes de qualquer recrutamento, rode `maestri list`** — isto é o que evita duplicar e evita interromper trabalho ativo: se um papel já está conectado a este workspace (nome do terminal aparece na lista), **não recrute de novo**, e **não interrompa/reinicie** um terminal que já tenha tarefa em andamento; só confirme que o caminho (`maestri check "<Nome>"`) é o projeto certo.
2. **Apresente ao usuário o catálogo completo para seleção**, sem assumir nenhum por padrão além do `cto` (que a própria sessão já exerce, Passo 2):

   | Papel | Camada |
   |---|---|
   | `cto` | Principal — já exercido por esta sessão, sem terminal dedicado necessário |
   | `backend-dev` | Principal |
   | `frontend-dev` | Principal |
   | `spec-lookup` | Principal |
   | `test-runner` | Principal |
   | `data-analyst` | Sob demanda |
   | `security-auditor` | Sob demanda |
   | `qa-e2e` | Sob demanda |
   | `devops-infra` | Sob demanda |
   | `tech-writer` | Sob demanda |
   | `calc-auditor` | Sob demanda, condicional — instrução genérica já existe (`.claude/agents/calc-auditor.md`); não acione numa automação real sem revisar o conteúdo com o usuário primeiro (ver `CLAUDE.md`) |
   | `migration-guardian` | Sob demanda, condicional — mesma ressalva de `calc-auditor` (`.claude/agents/migration-guardian.md`) |

   Pergunte quais papéis recrutar agora (os 4 principais além do `cto` costumam bastar para começar; os demais entram quando o gatilho existir).
3. Para cada papel a recrutar, siga o Passo 7 (cliente/modelo/permissão) **antes** de rodar `maestri recruit`.
4. Para um papel que ainda não tem terminal conectado e você tem autorização e suporte de Maestro Mode: `maestri recruit "<Nome>" --dir "<caminho do projeto>" --command "<comando do cliente>"`, já usando o comando decidido no Passo 7.
5. Se não houver Maestro Mode disponível nesta sessão (confira `maestri list` — campo "You:"), não dá para recrutar; registre como pendência e diga exatamente o que falta (precisa de uma sessão com `maestro: true`).
6. **Pré-requisito antes da primeira ativação de `calc-auditor` ou `migration-guardian` neste projeto novo/existente:** mesmo que recrutados, eles só podem ser **acionados** depois que o `cto` revisar com o usuário se a instrução genérica já existente (`.claude/agents/calc-auditor.md`/`migration-guardian.md`) cobre o caso real da automação (qual banco/ORM, qual regra de cálculo) — nunca copiando regras de outro projeto nem ativando só porque o arquivo existe.

## Passo 7 — Escolher cliente, modelo e permissões por papel (antes de recrutar)

1. **Detecte o que está disponível nesta máquina** (não recomende um cliente com base no que outro projeto usa): verifique executáveis/presets de Claude Code, Codex e Antigravity (`agy`) que estiverem instalados — ex. `claude --version`, `codex --version`, `agy --version`, cada um só se existir no PATH.
2. **Apresente, por papel, antes de recrutar:** cliente, modelo e modo de permissões propostos — em uma lista curta, não recrute silenciosamente com um padrão. Permita que o usuário escolha individualmente por papel ou um valor comum para vários papéis de uma vez.
3. **Papéis continuam independentes de fornecedor/modelo** — a escolha feita aqui é configuração desta máquina/projeto (registrar em `MODELOS_CLIENTES.local.md`), nunca uma regra do papel em si (`CLAUDE.md`/`.claude/agents/*.md` continuam genéricos).
4. **Permissão total exige aprovação explícita, separada da escolha de cliente/modelo.** Pergunte especificamente sobre isso antes de aplicar — "confiar na pasta" (trust do workspace) não é a mesma coisa que permissão total de ferramentas, não trate uma como se fosse a outra.
5. Depois de recrutar, **confirme o que de fato iniciou** — não assuma que o terminal abriu com a configuração pedida só porque o comando de recrutamento não deu erro; peça para o usuário (ou confira via `maestri check "<Nome>"`) validar cliente/modelo/permissão realmente ativos.
6. Registre a configuração confirmada em `MODELOS_CLIENTES.local.md`.

## Passo 8 — Orientar autenticações; pedir autorização antes de mudanças globais

Nenhuma autenticação de cliente de IA, `gh`, ou outra ferramenta é automatizável por este procedimento — são sempre ação manual do usuário. Seu papel aqui é **orientar**, não executar por ele:

- Login de cliente de IA (Antigravity/`agy`, Codex, etc.): oriente o usuário a fazer login manualmente no terminal real.
- `gh auth login`: oriente o fluxo de device code (ver `GUIAS.md`, Guia 1).
- Qualquer mudança de configuração GLOBAL desta máquina (registro de MCP, PATH do usuário): explique o efeito e peça confirmação explícita antes — nunca aplique silenciosamente (o script do Passo 4 já faz isso item a item, e só aplica com `-ConfirmGlobalChanges` fora do modo interativo).

## Passo 9 — Validar ferramentas por execução real (não só por instalação)

Instalado, configurado, conectado e **executado de verdade** são coisas diferentes — não confunda os três primeiros com o quarto, e não reaproveite um teste feito em outra máquina como prova de que funciona nesta:

- **Serena:** instalada (`uv tool list`) → configurada (`.serena/project.yml` existe e aponta pra esta pasta) → conectada (`agy mcp list` mostra `serena` como `enabled`) → **executada** (dentro do terminal real de `backend-dev`/`frontend-dev`, uma chamada real de `find_symbol`/`find_referencing_symbols`, e uma edição de exemplo descartável com `replace_symbol_body` que depois é revertida). Só os três primeiros não bastam para marcar como `validado`.
- **Graphify:** `python -m graphify update .` rodando sem erro não é suficiente — rode também uma consulta de uma relação conhecida (`python -m graphify query "<pergunta sobre um arquivo/relação que você já sabe a resposta>"`) e confira o resultado contra o arquivo real.
- **RTK:** valide o comando direto (`rtk --version`, `rtk hook antigravity --help`) e o hook automático **separadamente** — um não prova o outro. `scripts/setup-maquina.ps1` já testa o subcomando real do hook antes de contar com ele. Um relato de falha com uma versão específica (ex.: um teste real feito numa outra máquina mostrando RTK 0.46.0 sem o subcomando `hook antigravity`, exigido pelo hook copiado) é **evidência externa relatada, não reproduzida nesta execução** até você testar o mesmo binário aqui — registre-a como tal no diário, nunca como fato confirmado localmente. Enquanto o hook automático estiver `[FALHA]`/pendente, o uso direto do RTK (`rtk ls`, `rtk grep -r`, `rtk git status/diff/log`, `rtk test <cmd>`) continua disponível e é a alternativa — não deixe de usar RTK só porque o hook falhou.
- **UI UX Pro Max:** confirme leitura explícita do `SKILL.md` e rode uma consulta real (`python .claude/skills/ui-ux-pro-max/scripts/search.py --domain ux "<termo>"`) pelo papel que vai usar (tipicamente `frontend-dev`), dentro do terminal real dele. Não crie uma tela só para testar, e não assuma que o cliente descobre a skill automaticamente sem essa chamada explícita.

## Passo 10 — Registrar resultados, pendências e o estado final no diário

Classifique o resultado desta preparação num dos quatro estados abaixo (mesma escala usada no resumo do `setup-maquina.ps1`) e registre no diário qual é:

- **Bloqueado** — há pelo menos uma falha real (comando rodou e deu erro; ex. hook do RTK incompatível, Serena não conecta). Não segue para entrega até resolver.
- **Parcial** — sem falhas, mas há autorização pendente (`[PENDENTE]`) ou ação manual não feita (`[MANUAL]`), ou alguma ferramenta só está instalada/configurada/conectada, sem a execução real do Passo 9.
- **Preparado** — ferramentas instaladas/configuradas sem falha nem pendência, mas a validação por execução real (Passo 9) ainda não foi feita em todas elas.
- **Validado** — preparado, e a execução real do Passo 9 foi feita e confirmada para cada ferramenta relevante a este projeto.

Nunca declare "validado" (nem "preparado", se ainda houver `[FALHA]`/`[PENDENTE]` genuíno) só por ter editado instruções ou por confiar no relato de um agente sem conferir evidência pontual (`CLAUDE.md`, "Verificação antes de afirmar").

Atualize `DIARIO_DE_BORDO.md` (bloco "ESTADO ATUAL" + nova entrada) com: qual dos quatro estados acima, por ferramenta/cliente/terminal; qual fluxo (A/B/C) foi seguido; o que foi detectado automaticamente; o que foi perguntado ao usuário; o que o script de instalação confirmou (`[OK]`/`[FALHA]`/`[PENDENTE]`/`[MANUAL]`); quais terminais foram recrutados (cliente/modelo/permissão de cada um, confirmados de verdade) ou por que não; quais autenticações ficaram pendentes; e diferencie claramente **o que foi executado de verdade** (comando rodou, saída lida) do que só foi preparado/documentado (instrução escrita, ainda sem execução real). Se a automação tocar dado financeiro, sincronização crítica ou rodar sem supervisão humana, confirme que o teste automatizado do cenário principal existe e foi escrito por quem implementou (nunca pelo `test-runner`) antes de considerar a entrega "validada".

---

## Separação de instruções permanentes vs. configuração específica

- **Permanente (vale para qualquer cópia deste template):** este arquivo, `CLAUDE.md` (seções de governança/equipe/ferramentas), `.claude/agents/*.md`, `GUIAS.md`, `scripts/setup-maquina.ps1`.
- **Específico desta máquina/projeto (nunca herdar de outra cópia):** `MODELOS_CLIENTES.local.md`, `.serena/project.yml`, o caminho físico documentado em `CLAUDE.md`, qualquer config GLOBAL já registrada no cliente de IA desta máquina.

## Orientação Prisma opcional

Consulte [PRISMA_SKILLS.md](./PRISMA_SKILLS.md) somente quando o projeto usar Prisma. As três skills oficiais estão incluídas localmente; preservar versão/provider, sem instalar ORM ou conectar bancos durante o preparo do template.

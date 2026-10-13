# Procedimento de preparação (único — não duplique isto em outro arquivo)

Este é o **único** procedimento de preparação do MAESTRI_TEMPLATE. `README.md` só aponta para aqui; `GUIAS.md` (Guia 2) só aponta para aqui. Se algo aqui contradizer outro arquivo, este arquivo vale.

**Quando seguir isto:** sempre que alguém (usuário ou agente) clonar este repositório num caminho novo e pedir para preparar o workspace — tipicamente com uma instrução curta como "Clone \<URL\> e siga as instruções do repositório para preparar este workspace."

**Quem segue isto:** o agente que receber esse pedido assume o papel de `cto` a partir do passo 2 abaixo — leia `CLAUDE.md` e `.claude/agents/cto.md` antes de continuar.

---

## Passo 0 — Antes de tudo: isto é uma revisão de fluxo ou uma preparação real?

Se você está lendo este arquivo para **revisar se o procedimento faz sentido** (sem máquina limpa, sem clone novo de verdade), isso é uma **revisão documental** — deixe claro no seu relatório que não é um teste real em máquina limpa. Se você está preparando um workspace de verdade, siga os passos abaixo executando cada comando, não apenas lendo.

## Passo 1 — Identificar a raiz do projeto e conferir correspondência com o workspace Maestri

1. Confirme que o diretório atual (ou o caminho que recebeu) contém `CLAUDE.md`, `.claude/agents/`, `.gitignore` — se não contém, você não está na raiz certa, pare e avise.
2. Verifique se existe `.maestri/` nessa raiz:
   - Se existir: rode `maestri list` e `maestri workspace list`. Confirme se o caminho do workspace ativo no Maestri **é exatamente** esta raiz. Se não for (ex.: o workspace Maestri aponta para outro caminho), isso é uma divergência real — avise o usuário antes de continuar, não assuma qual está certo.
   - Se não existir `.maestri/`: este projeto não tem workspace Maestri associado ainda. Isso não bloqueia o resto da preparação (ferramentas/skills funcionam sem o Maestri), mas a parte de "recrutar agentes" (Passo 6) não pode ser feita — registre como pendência.

## Passo 2 — Assumir o papel de `cto`

Leia `CLAUDE.md` (raiz) e `.claude/agents/cto.md` por completo antes de prosseguir. A partir daqui você segue as regras de lá (modelo de delegação, relatórios verificáveis, etc.) — este procedimento só cobre a preparação inicial, não substitui aquelas regras.

## Passo 3 — Perguntar só o que não pode ser detectado

Não pergunte o que você consegue checar sozinho (ex.: se o Python está instalado — isso o script do Passo 4 detecta). Pergunte ao usuário **só**:

1. **Nome do projeto novo** (se for diferente do nome herdado da pasta/template) — não adivinhe.
2. **Domínio de negócio real** (o que o projeto faz de verdade) — necessário para substituir o texto genérico de "Sobre este template" em `CLAUDE.md`; sem isso, o `CLAUDE.md` fica genérico demais para orientar decisões de negócio.
3. **Se a stack ainda é Node.js/TypeScript/React/SaaS** — se não for, pare e avise que as premissas de stack do template (Serena configurada para TS, UI UX Pro Max, etc.) precisam de revisão antes de seguir.
4. **Se autoriza recrutar terminais Maestri reais agora** (Passo 6) — isso cria/reconfigura processos reais, nunca faça sem essa autorização explícita.
5. **Se autoriza mudanças de configuração GLOBAL desta máquina** (registro do MCP da Serena, PATH do usuário) — o script do Passo 4 já pede isso individualmente, mas avise que isso vai acontecer.

Tudo que não está nesta lista, você detecta sozinho nos passos seguintes.

## Passo 4 — Instalar e validar dependências/ferramentas/skills (script idempotente)

Rode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "<caminho da raiz deste projeto>"
```

O script é seguro para reexecução (detecta o que já está instalado, não duplica config, pede confirmação antes de qualquer mudança global). Leia o resumo final (`[OK]`/`[MANUAL]`/`[FALHA]` por item) e trate cada `[MANUAL]` — alguns exigem ação humana (login de IA, por exemplo) que nenhum script automatiza.

**Não pule este passo mesmo que pareça redundante com o Passo 1** — o Passo 1 confere a estrutura do repositório; este passo confere o que está instalado *nesta máquina*, que é informação nova a cada máquina diferente.

## Passo 5 — Adaptar nome e caminhos ao novo projeto

1. Em `CLAUDE.md`, seção "Sobre este template": substitua pelo domínio de negócio real coletado no Passo 3 (deixe de ser um template genérico, vire a governança daquele projeto específico).
2. Recrie `.serena/project.yml` com `serena project create --name "<nome>" --language typescript .` — **não copie o arquivo antigo**, o caminho embutido nele pertence ao template de origem, não ao projeto novo.
3. Se a Serena já estava registrada no MCP do cliente (ex. `agy mcp list` mostra `serena`), o `--project` do comando continua apontando para o caminho antigo até você re-registrar com o caminho novo — isso é mudança de configuração GLOBAL, avise e peça confirmação antes (o Passo 4 já cobre isso se rodado depois da cópia).
4. **Se `MODELOS_CLIENTES.local.md` ainda não existir nesta máquina**, crie-o copiando `MODELOS_CLIENTES.example.md` (`cp MODELOS_CLIENTES.example.md MODELOS_CLIENTES.local.md`) e preencha com os fatos confirmados nesta máquina/projeto novo — nunca herde a tabela de outro projeto. **Se já existir, não o sobrescreva** — ele é ignorado pelo Git (contém dados pessoais) e pode já ter dados corretos; só atualize os campos que mudaram.
5. Se `.maestri/roles/*/CLAUDE.md`/`AGENTS.md` existirem e tiverem uma linha de `working_directory` apontando para o caminho antigo, isso só é corrigido de fato recriando/reatribuindo o terminal Maestri real (ver Passo 6) — editar o texto sem mover o terminal não resolve.

## Passo 6 — Preparar a equipe / recrutar agentes (só com suporte Maestri e autorização)

**Pré-condição:** o Passo 1 confirmou que existe `.maestri/` com workspace correspondente, **e** o usuário autorizou isso explicitamente no Passo 3.

1. Rode `maestri list` — isto é o que evita duplicar: se um papel já está conectado a este workspace (nome do terminal aparece na lista), **não recrute de novo**, só confirme que o caminho (`maestri check "<Nome>"`) é o projeto certo.
2. Para um papel que ainda não tem terminal conectado e você tem autorização e suporte de Maestro Mode: `maestri recruit "<Nome>" --dir "<caminho do projeto>" --command "<comando do cliente>"`. O comando/cliente **não é fixo no papel** — ver `MODELOS_CLIENTES.local.md` para o que já está confirmado nesta máquina, ou pergunte ao usuário qual cliente/modelo usar se for a primeira vez.
3. Se não houver Maestro Mode disponível nesta sessão (confira `maestri list` — campo "You:"), não dá para recrutar; registre como pendência e diga exatamente o que falta (precisa de uma sessão com `maestro: true`).

## Passo 7 — Orientar autenticações; pedir autorização antes de mudanças globais

Nenhuma autenticação de cliente de IA, `gh`, ou outra ferramenta é automatizável por este procedimento — são sempre ação manual do usuário. Seu papel aqui é **orientar**, não executar por ele:

- Login de cliente de IA (Antigravity/`agy`, Codex, etc.): oriente o usuário a fazer login manualmente no terminal real.
- `gh auth login`: oriente o fluxo de device code (ver `GUIAS.md`, Guia 1).
- Qualquer mudança de configuração GLOBAL desta máquina (registro de MCP, PATH do usuário): explique o efeito e peça confirmação explícita antes — nunca aplique silenciosamente (o script do Passo 4 já faz isso item a item).

## Passo 8 — Registrar resultados e pendências no diário

Atualize `DIARIO_DE_BORDO.md` (bloco "ESTADO ATUAL" + nova entrada) com: o que foi detectado automaticamente, o que foi perguntado ao usuário, o que o script de instalação confirmou (`[OK]`/`[MANUAL]`/`[FALHA]`), quais terminais foram recrutados (ou por que não), quais autenticações ficaram pendentes, e diferencie claramente **o que foi executado de verdade** do que só foi preparado/documentado.

---

## Separação de instruções permanentes vs. configuração específica

- **Permanente (vale para qualquer cópia deste template):** este arquivo, `CLAUDE.md` (seções de governança/equipe/ferramentas), `.claude/agents/*.md`, `GUIAS.md`, `scripts/setup-maquina.ps1`.
- **Específico desta máquina/projeto (nunca herdar de outra cópia):** `MODELOS_CLIENTES.local.md`, `.serena/project.yml`, o caminho físico documentado em `CLAUDE.md`, qualquer config GLOBAL já registrada no cliente de IA desta máquina.

<#
.SYNOPSIS
  Instalador de preparacao do MAESTRI_TEMPLATE para uma maquina Windows.

.DESCRIPTION
  Confere pre-requisitos e instala/valida as ferramentas do TEMPLATE em si
  (RTK, Serena, Graphify, skill UI UX Pro Max). NAO instala dependencias de
  uma aplicacao Node/React futura - isso e trabalho do projeto que vier a
  usar o template, nao deste script (ver secao "Separacao de escopo" no
  final deste cabecalho).

  Idempotente: detecta o que ja esta instalado e nao duplica configuracao
  ao rodar de novo.

  NAO copia credenciais, sessoes ou logins de IA. Login de cliente de IA
  (Antigravity/agy, Codex, etc.) e import de canvas do Maestri sao sempre
  acao manual do usuario - o script avisa onde isso e necessario.

  Mudanca de configuracao GLOBAL (ex.: registrar a Serena no MCP global do
  Antigravity) nunca e feita sem perguntar: o script explica o efeito e
  pede confirmacao (Y/N) antes de aplicar.

.PARAMETER ProjectPath
  Caminho do projeto onde o template esta sendo instalado/validado (pasta
  que contem .claude/, CLAUDE.md, etc.). Default: pasta atual.

.PARAMETER NonInteractive
  Quando presente, o script nunca chama Read-Host. Toda decisao Y/N que
  normalmente seria perguntada usa o valor de -AutoYes (false por padrao,
  ou seja, "nao instalar/registrar nada automaticamente") e fica marcada
  como [PENDENTE] com instrucao exata do comando manual - nunca como
  [MANUAL] generico nem como "usuario recusou". Ausencia de entrada (EOF)
  numa sessao nao-interativa que esqueceu de passar -NonInteractive e
  tratada da mesma forma por seguranca (ver bloco de deteccao abaixo).

.PARAMETER AutoYes
  Só tem efeito junto com -NonInteractive. Alcance EXATO, nada alem disso:
  responde "sim" às instalacoes/registros que SO afetam este projeto, neste
  disco (RTK, Graphify, UI UX Pro Max, Serena install local via uv tool).
  -AutoYes NUNCA, em nenhuma circunstancia:
    - autoriza a mudanca de configuracao GLOBAL do registro MCP da Serena
      (isso sempre fica [PENDENTE] sem -ConfirmGlobalChanges, mesmo com
      -AutoYes - ver o parametro abaixo e o codigo de Confirm-Action, que
      passa -AllowAutoYes:$false nesse ponto especifico);
    - concede permissao total a nenhum cliente/agente (este script nao
      recruta, nao configura permissao de ferramenta de nenhum papel - isso
      e decidido no Passo 7 de PREPARACAO.md, sempre com aprovacao explicita
      separada, nunca por este parametro);
    - reinicia, recruta ou envia tarefa a nenhum terminal Maestri (este
      script so instala/valida ferramentas - recrutamento e Passo 6 de
      PREPARACAO.md, sempre manual e com autorizacao propria).
  -AutoYes serve só para não travar numa execução não-interativa deste
  script especifico; não é uma autorização geral do procedimento maior.

.PARAMETER ConfirmGlobalChanges
  Unica forma de autorizar a mudanca de configuracao GLOBAL (registro da
  Serena no MCP do cliente) fora de um prompt interativo. Tem que ser
  passado explicitamente pelo usuario nesta execucao - nunca inferido de
  -AutoYes, nunca persistido entre execucoes, e nunca usado para nenhuma
  outra mudanca global (PATH do usuario, outro MCP, etc.) alem desta.
  Mesmo com -ConfirmGlobalChanges, o script so registra a Serena - continua
  sem recrutar/reiniciar terminal nem conceder permissao de agente.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "C:\caminho\do\projeto"

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "C:\caminho\do\projeto" -NonInteractive -AutoYes

.NOTES
  Testado em: Windows 11 Home Single Language 10.0.26200, PowerShell 5.1,
  nesta maquina, em 2026-10-13, dentro do proprio MAESTRI_TEMPLATE, com
  TODAS as ferramentas ja instaladas (rodado 2x de verdade: confirmado que
  os ramos "ja instalado" funcionam e que rodar de novo nao duplica nada -
  saida idêntica na 2a execucao). Os ramos de instalacao do zero e as
  perguntas Y/N (RTK baixar, Serena instalar/registrar, UI UX Pro Max
  instalar) NAO foram exercitados nesta sessao porque tudo já estava
  instalado - revisar/testar antes de confiar neles numa maquina limpa de
  verdade. NAO rodado numa maquina Windows diferente desta. Nao declare
  compatibilidade com maquina limpa sem testar la primeiro.

  Arquivo salvo em ASCII puro (sem acento/travessao) deliberadamente: o
  parser do Windows PowerShell 5.1 pode nao detectar a codificacao de um
  .ps1 em UTF-8 sem BOM, e caracteres acentuados mal decodificados podem
  virar aspas curvas "inteligentes" que o tokenizer da linguagem aceita
  como delimitador de string de verdade - isso corrompeu a primeira versao
  deste script (erro de parser "chave de fechamento ausente", causado por
  um "-" virando aspas curvas em bytes mal lidos). Nao reintroduza acento
  nem travessao Unicode neste arquivo.
#>

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$NonInteractive,
    [switch]$AutoYes,
    [switch]$ConfirmGlobalChanges
)

$ErrorActionPreference = "Continue"
$results = @()

function Report {
    param([string]$Step, [string]$Status, [string]$Detail)
    # Status esperado: OK | FALHA | MANUAL | PENDENTE
    $line = "[$Status] $Step - $Detail"
    Write-Host $line
    $script:results += [PSCustomObject]@{ Step = $Step; Status = $Status; Detail = $Detail }
}

function Test-CommandExists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Confirm-Action {
    # Decide uma pergunta Y/N sem nunca tratar ausencia de resposta como
    # recusa. Em modo nao-interativo, usa -AutoYes (ou false se nao tiver
    # efeito aqui, ex. mudanca global). Em modo interativo, se o Read-Host
    # vier vazio/EOF (console nao-interativo de verdade, ex. hook/CI sem
    # -NonInteractive), tambem cai em "pendente", nunca em "recusou".
    param([string]$Prompt, [bool]$AllowAutoYes = $true)

    if ($NonInteractive) {
        if ($AllowAutoYes -and $AutoYes) { return "yes" }
        return "pending"
    }

    try {
        $resp = Read-Host $Prompt
    } catch {
        return "pending"
    }

    if ([string]::IsNullOrWhiteSpace($resp)) { return "pending" }
    if ($resp -match "^[Yy]") { return "yes" }
    return "no"
}

function Invoke-Checked {
    # Roda um comando externo e confere o exit code real - nunca declara
    # OK so porque o script chegou ao fim do bloco.
    param([string]$Step, [scriptblock]$Action, [string]$SuccessDetail, [string]$FailureDetail)

    $global:LASTEXITCODE = 0
    try {
        & $Action
    } catch {
        Report $Step "FALHA" "$FailureDetail - excecao: $($_.Exception.Message)"
        return $false
    }
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        Report $Step "FALHA" "$FailureDetail - exit code $LASTEXITCODE"
        return $false
    }
    Report $Step "OK" $SuccessDetail
    return $true
}

Write-Host "=== MAESTRI_TEMPLATE - setup desta maquina ==="
Write-Host "Projeto: $ProjectPath"
Write-Host ""

# ---------------------------------------------------------------------------
# 1. Pre-requisitos (apenas verificacao - nao instala runtime de linguagem
#    sem perguntar, pois isso afeta a maquina inteira, nao so o template)
# ---------------------------------------------------------------------------

if (Test-CommandExists "python") {
    $pv = (python --version) 2>&1
    Report "Pre-requisito: Python" "OK" "$pv encontrado"
} else {
    Report "Pre-requisito: Python" "MANUAL" "Python 3 nao encontrado no PATH. Instale manualmente (python.org) antes de continuar - este script nao instala runtime de linguagem sem autorizacao explicita."
}

if (Test-CommandExists "node") {
    $nv = (node --version) 2>&1
    Report "Pre-requisito: Node.js" "OK" "$nv encontrado"
} else {
    Report "Pre-requisito: Node.js" "MANUAL" "Node.js nao encontrado no PATH. Instale manualmente (nodejs.org) antes de continuar."
}

if (Test-CommandExists "npx") {
    Report "Pre-requisito: npx" "OK" "encontrado (via Node.js)"
} else {
    Report "Pre-requisito: npx" "MANUAL" "npx nao encontrado - normalmente vem com o Node.js. Reinstale o Node."
}

if (Test-CommandExists "git") {
    $gv = (git --version) 2>&1
    Report "Pre-requisito: Git" "OK" "$gv encontrado"
} else {
    Report "Pre-requisito: Git" "MANUAL" "Git nao encontrado no PATH. Instale manualmente (git-scm.com)."
}

if (Test-CommandExists "uv") {
    $uvv = (uv --version) 2>&1
    Report "Pre-requisito: uv" "OK" "$uvv encontrado"
} else {
    Report "Pre-requisito: uv" "MANUAL" "uv nao encontrado. Instale manualmente: https://docs.astral.sh/uv/ (necessario para instalar a Serena)."
}

Write-Host ""

# ---------------------------------------------------------------------------
# 2. RTK (binario oficial rtk-ai/rtk)
#
# Evidencia externa relatada (NAO reproduzida nesta maquina): um teste real
# numa maquina de destino mostrou RTK 0.46.0 sem o subcomando 'hook
# antigravity', que o hook copiado (.agents/plugins/rtk/hooks.json) exige.
# Nesta maquina o unico binario disponivel e 0.52.0, onde o subcomando FOI
# confirmado (ver bloco abaixo) - isso corrobora que o subcomando e novo
# o suficiente para faltar numa versao antiga, mas nao prova sozinho que
# 0.46.0 especificamente carece dele; trate o relato da maquina de destino
# como o dado primario desse achado, este bloco so documenta o que valida
# aqui. O preparo tem que CONFERIR a capacidade antes de contar com o hook -
# nunca assumir compativel so por 'rtk --version' funcionar - e o uso direto
# (rtk ls / rtk grep -r / rtk git status / rtk test <cmd>) continua
# disponivel e documentado como alternativa sempre que o hook automatico
# estiver [FALHA]/pendente, nao so quando o binario inteiro falta.
# ---------------------------------------------------------------------------

$rtkBin = "$env:USERPROFILE\bin\rtk.exe"
if (Test-CommandExists "rtk") {
    $rtkVer = (rtk --version) 2>&1
    Report "RTK (binario)" "OK" "ja instalado e no PATH ($rtkVer) - uso direto (rtk ls/grep/git/test) disponivel independente do resultado do hook abaixo"

    # O hook do Antigravity (.agents/plugins/rtk/hooks.json) chama
    # 'rtk hook antigravity'. Esse subcomando pode nao existir em versoes
    # mais antigas do binario (relatado externamente para 0.46.0 - nao
    # reproduzido nesta maquina) mesmo com 'rtk --version' OK - testar o
    # subcomando de verdade antes de contar com o hook automatico, nao so a
    # presenca do binario.
    $rtkHookCheck = (rtk hook antigravity --help) 2>&1
    if ($LASTEXITCODE -eq 0) {
        Report "RTK (subcomando 'hook antigravity')" "OK" "disponivel - compativel com .agents/plugins/rtk/hooks.json; hook automatico pode ficar habilitado"
    } else {
        Report "RTK (subcomando 'hook antigravity')" "FALHA" "binario instalado ($rtkVer) mas 'rtk hook antigravity --help' retornou exit $LASTEXITCODE - hook automatico do Antigravity vai falhar em todo tool call com este binario. NAO habilite/confie no hook até atualizar para a release mais recente (https://github.com/rtk-ai/rtk/releases). Uso DIRETO do rtk (rtk ls / rtk grep -r / rtk git status / rtk test <cmd>) continua funcionando e é a alternativa enquanto o hook ficar pendente - nao deixe de usar RTK so por causa do hook. NAO atribua a causa a esta versao especifica sem conferir o changelog/testar binarios diferentes - isto so confirma que o subcomando falha NESTE binario instalado, agora."
    }
} elseif (Test-Path $rtkBin) {
    Report "RTK" "MANUAL" "binario existe em $rtkBin mas nao esta no PATH - adicione essa pasta ao PATH do usuario e reabra o terminal"
} else {
    Report "RTK" "MANUAL" "nao instalado. Baixe manualmente o zip da release 'rtk-x86_64-pc-windows-msvc.zip' em https://github.com/rtk-ai/rtk/releases (versao registrada no template: 0.52.0), extraia rtk.exe para $env:USERPROFILE\bin\ e adicione essa pasta ao PATH. Este script nao baixa/extrai executaveis de rede sem confirmacao explicita por item - rode de novo depois de instalar para validar."
}

Write-Host ""

# ---------------------------------------------------------------------------
# 3. Serena (oraios/serena) - versao registrada: serena-agent 2.0.0
# ---------------------------------------------------------------------------

$serenaInstalled = $false
if (Test-CommandExists "uv") {
    $uvList = (uv tool list) 2>&1
    if ($uvList -match "serena-agent") {
        $serenaInstalled = $true
        Report "Serena (instalacao)" "OK" "serena-agent ja instalado via uv - nenhuma acao necessaria"
    } else {
        $decision = Confirm-Action "Serena nao esta instalada. Instalar agora via 'uv tool install -p 3.13 serena-agent'? (Y/N)"
        if ($decision -eq "yes") {
            if (Invoke-Checked "Serena (instalacao)" { uv tool install -p 3.13 serena-agent } "instalada via uv tool install" "falha ao instalar serena-agent via uv") {
                $serenaInstalled = $true
            }
        } elseif ($decision -eq "pending") {
            Report "Serena (instalacao)" "PENDENTE" "autorizacao nao coletada (modo nao-interativo sem -AutoYes, ou entrada vazia/EOF) - rode novamente com -NonInteractive -AutoYes, ou interativamente e responda Y, ou instale manualmente: uv tool install -p 3.13 serena-agent"
        } else {
            Report "Serena (instalacao)" "MANUAL" "usuario optou por nao instalar agora"
        }
    }
} else {
    Report "Serena (instalacao)" "MANUAL" "depende de 'uv', que nao esta disponivel (ver passo 1)"
}

if ($serenaInstalled) {
    $serenaProjectYml = Join-Path $ProjectPath ".serena\project.yml"
    if (Test-Path $serenaProjectYml) {
        Report "Serena (config do projeto)" "OK" "$serenaProjectYml ja existe - confira se o caminho embutido bate com $ProjectPath; se este projeto foi copiado de outro lugar, recrie com 'serena project create' em vez de reaproveitar o arquivo copiado"
    } else {
        Report "Serena (config do projeto)" "MANUAL" "rode 'serena project create --name <nome> --language typescript .' dentro de $ProjectPath"
    }

    Write-Host ""
    Write-Host "ATENCAO - proxima etapa altera configuracao GLOBAL deste usuario Windows:"
    Write-Host "Registrar a Serena no MCP do cliente Antigravity ('agy mcp add') grava a entrada em"
    Write-Host "~/.gemini/config/mcp_config.json, visivel para QUALQUER terminal 'agy' desta conta,"
    Write-Host "nao so para este projeto (o 'agy' nao tem escopo de MCP por projeto). O isolamento real"
    Write-Host "vem do '--project' fixado no comando do servidor, nao da entrada em si."
    $globalDecision = "no"
    if ($ConfirmGlobalChanges) {
        $globalDecision = "yes"
    } elseif (-not $NonInteractive) {
        $globalDecision = Confirm-Action "Registrar agora, com --project fixo em '$ProjectPath'? (Y/N)" -AllowAutoYes $false
    } else {
        $globalDecision = "pending-global"
    }

    if ($globalDecision -eq "yes") {
        if (Test-CommandExists "agy") {
            $serenaExe = "$env:USERPROFILE\.local\bin\serena.exe"
            $cmd = "$serenaExe start-mcp-server --context antigravity --agent-interface tools --project `"$ProjectPath`" --transport stdio --enable-web-dashboard False --open-web-dashboard False"
            $null = Invoke-Checked "Serena (registro MCP global)" { agy mcp add serena --command $cmd } "registrado via 'agy mcp add' com --project em $ProjectPath" "'agy mcp add' retornou erro ao registrar a Serena"
        } else {
            Report "Serena (registro MCP global)" "MANUAL" "'agy' nao encontrado no PATH desta sessao - registre manualmente dentro do terminal Antigravity real"
        }
    } elseif ($globalDecision -eq "pending-global" -or $globalDecision -eq "pending") {
        Report "Serena (registro MCP global)" "PENDENTE" "mudanca de configuracao GLOBAL exige autorizacao explicita - rode novamente com -ConfirmGlobalChanges (nunca -AutoYes, que so cobre mudancas locais ao projeto), ou registre manualmente: agy mcp add serena --command `"...start-mcp-server ... --project $ProjectPath...`""
    } else {
        Report "Serena (registro MCP global)" "MANUAL" "usuario optou por nao registrar agora - pendente, nao bloqueante"
    }
}

Write-Host ""

# ---------------------------------------------------------------------------
# 4. Graphify - versao registrada: 0.9.8
# ---------------------------------------------------------------------------

$graphifyFound = $false
$graphifyVia = ""

if (Test-CommandExists "python") {
    $graphifyCheck = (python -m graphify --version) 2>&1
    if ($LASTEXITCODE -eq 0) {
        $graphifyFound = $true
        $graphifyVia = "modulo Python ($graphifyCheck)"
    }
}

if (-not $graphifyFound -and (Test-CommandExists "uv")) {
    # Graphify tambem pode estar instalado como ferramenta isolada via
    # 'uv tool install', sem estar no ambiente Python ativo do PATH - o
    # comando acima ('python -m graphify') nao detecta esse caso.
    $uvListGraphify = (uv tool list) 2>&1
    if ($uvListGraphify -match "graphify") {
        $graphifyFound = $true
        $graphifyVia = "instalado via 'uv tool install' (fora do ambiente Python do PATH)"
    }
}

if (Test-CommandExists "graphify") {
    $graphifyFound = $true
    $graphifyVia = "executavel 'graphify' direto no PATH"
}

if ($graphifyFound) {
    Report "Graphify" "OK" "ja instalado - $graphifyVia"
    Push-Location $ProjectPath
    $null = Invoke-Checked "Graphify (grafo atualizado)" { python -m graphify update . | Out-Null } "python -m graphify update . executado em $ProjectPath" "'python -m graphify update .' falhou - se Graphify foi detectado via uv tool/executavel isolado, o comando 'python -m graphify' pode nao ser o correto nesta maquina; confira manualmente qual comando o roda"
    Pop-Location
} else {
    $decision = Confirm-Action "Graphify nao encontrado. Instalar agora ('python -m pip install graphify' + 'python -m graphify install --platform claude')? (Y/N)"
    if ($decision -eq "yes") {
        if (Invoke-Checked "Graphify (instalacao)" { python -m pip install graphify } "pacote instalado via pip" "'python -m pip install graphify' falhou") {
            Push-Location $ProjectPath
            $null = Invoke-Checked "Graphify (setup no projeto)" { python -m graphify install --platform claude; python -m graphify update . } "install + update executados em $ProjectPath" "'graphify install'/'graphify update' falhou"
            Pop-Location
        }
    } elseif ($decision -eq "pending") {
        Report "Graphify" "PENDENTE" "autorizacao nao coletada - rode com -NonInteractive -AutoYes, ou interativamente respondendo Y, ou instale manualmente"
    } else {
        Report "Graphify" "MANUAL" "usuario optou por nao instalar agora"
    }
}

Write-Host ""

# ---------------------------------------------------------------------------
# 5. Skills locais (UI UX Pro Max e demais skills do template)
# ---------------------------------------------------------------------------

$uiUxPath = Join-Path $ProjectPath ".claude\skills\ui-ux-pro-max"
if (Test-Path $uiUxPath) {
    Report "Skill UI UX Pro Max" "OK" "ja presente em $uiUxPath - nenhuma acao necessaria"
} else {
    if (Test-CommandExists "npx") {
        $decision = Confirm-Action "Skill UI UX Pro Max ausente. Instalar agora ('npx ui-ux-pro-max-cli init --ai claude', escopo local)? (Y/N)"
        if ($decision -eq "yes") {
            Push-Location $ProjectPath
            $null = Invoke-Checked "Skill UI UX Pro Max" { npx --yes ui-ux-pro-max-cli init --ai claude } "instalada via npx, escopo local" "'npx ui-ux-pro-max-cli init' falhou"
            Pop-Location
        } elseif ($decision -eq "pending") {
            Report "Skill UI UX Pro Max" "PENDENTE" "autorizacao nao coletada - rode com -NonInteractive -AutoYes, ou interativamente respondendo Y, ou instale manualmente"
        } else {
            Report "Skill UI UX Pro Max" "MANUAL" "usuario optou por nao instalar agora"
        }
    } else {
        Report "Skill UI UX Pro Max" "MANUAL" "depende de npx/Node.js (ver passo 1)"
    }
}

$skillsDir = Join-Path $ProjectPath ".claude\skills"
if (Test-Path $skillsDir) {
    $skillCount = (Get-ChildItem $skillsDir -Directory).Count
    Report "Skills locais (inventario)" "OK" "$skillCount pasta(s) de skill encontradas em $skillsDir - nenhuma acao automatica alem da UI UX Pro Max acima; demais skills sao copiadas junto com a pasta do projeto, nao reinstaladas por este script"
} else {
    Report "Skills locais (inventario)" "FALHA" "$skillsDir nao existe - a copia da pasta do template esta incompleta"
}

Write-Host ""
Write-Host "=== Resumo ==="
$results | Format-Table -AutoSize

$falhas = $results | Where-Object { $_.Status -eq "FALHA" }
$pendentes = $results | Where-Object { $_.Status -eq "PENDENTE" }
$manuais = $results | Where-Object { $_.Status -eq "MANUAL" }

if ($falhas) {
    Write-Host ""
    Write-Host "Falhas reais (comando rodou e retornou erro - investigar antes de repetir):"
    $falhas | ForEach-Object { Write-Host " - $($_.Step): $($_.Detail)" }
}
if ($pendentes) {
    Write-Host ""
    Write-Host "Autorizacao pendente (nao foi recusa - so nao foi coletada nesta execucao):"
    $pendentes | ForEach-Object { Write-Host " - $($_.Step): $($_.Detail)" }
}
if ($manuais) {
    Write-Host ""
    Write-Host "Acoes manuais pendentes (usuario optou por nao fazer agora, ou dependem de acao humana fora deste script):"
    $manuais | ForEach-Object { Write-Host " - $($_.Step): $($_.Detail)" }
}

# Estado geral desta execucao - ver PREPARACAO.md para a definicao completa
# de preparado / validado / parcial / bloqueado.
if ($falhas) {
    Write-Host ""
    Write-Host "ESTADO: BLOQUEADO - ha pelo menos uma falha real (comando rodou e deu erro). Resolva antes de seguir."
} elseif ($pendentes -or $manuais) {
    Write-Host ""
    Write-Host "ESTADO: PARCIAL - sem falhas, mas ha autorizacao pendente ou acao manual nao feita. Nao e 'preparado'."
} else {
    Write-Host ""
    Write-Host "ESTADO: PREPARADO - todas as ferramentas detectadas/instaladas sem falha ou pendencia. 'Validado' exige ainda a execucao real de uma ferramenta (ex.: chamada de find_symbol da Serena, query real do Graphify) - este script so confere instalacao/registro, nao substitui essa validacao."
}

<#
.SEPARACAO_DE_ESCOPO
  Este script prepara so as FERRAMENTAS do template (RTK, Serena, Graphify,
  UI UX Pro Max). Ele NUNCA roda `npm install` dentro de uma pasta de app
  Node/React do projeto que for construido a partir do template - essa
  pasta normalmente nao existe ainda no momento em que este script roda
  (o template e a base, a aplicacao vem depois). Instalar dependencias de
  uma aplicacao concreta e responsabilidade do fluxo normal de
  desenvolvimento daquela aplicacao (`npm install` dentro da pasta dela),
  nao deste instalador.

.REGISTRO_DE_TESTES (ver tambem DIARIO_DE_BORDO.md)
  Testado em 2026-10-13, nesta maquina (Windows 11 Home Single Language
  10.0.26200, PowerShell 5.1), dentro do proprio MAESTRI_TEMPLATE, com as
  ferramentas ja instaladas (entao os ramos de "ja instalado" foram
  exercitados de verdade; os ramos de instalacao do zero / pergunta Y/N
  NAO foram testados nesta sessao - revisar antes de confiar neles numa
  maquina limpa).
#>

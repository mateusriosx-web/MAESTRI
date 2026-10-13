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

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-maquina.ps1 -ProjectPath "C:\caminho\do\projeto"

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
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Continue"
$results = @()

function Report {
    param([string]$Step, [string]$Status, [string]$Detail)
    # Status esperado: OK | FALHA | MANUAL
    $line = "[$Status] $Step - $Detail"
    Write-Host $line
    $script:results += [PSCustomObject]@{ Step = $Step; Status = $Status; Detail = $Detail }
}

function Test-CommandExists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
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
# 2. RTK (binario oficial rtk-ai/rtk) - versao registrada: 0.52.0
# ---------------------------------------------------------------------------

$rtkBin = "$env:USERPROFILE\bin\rtk.exe"
if (Test-CommandExists "rtk") {
    $rtkVer = (rtk --version) 2>&1
    Report "RTK" "OK" "ja instalado e no PATH ($rtkVer) - nenhuma acao necessaria"
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
        $resp = Read-Host "Serena nao esta instalada. Instalar agora via 'uv tool install -p 3.13 serena-agent'? (Y/N)"
        if ($resp -match "^[Yy]") {
            uv tool install -p 3.13 serena-agent
            $serenaInstalled = $true
            Report "Serena (instalacao)" "OK" "instalada via uv tool install"
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
    $resp2 = Read-Host "Registrar agora, com --project fixo em '$ProjectPath'? (Y/N)"
    if ($resp2 -match "^[Yy]") {
        if (Test-CommandExists "agy") {
            $serenaExe = "$env:USERPROFILE\.local\bin\serena.exe"
            $cmd = "$serenaExe start-mcp-server --context antigravity --agent-interface tools --project `"$ProjectPath`" --transport stdio --enable-web-dashboard False --open-web-dashboard False"
            agy mcp add serena --command $cmd
            Report "Serena (registro MCP global)" "OK" "registrado via 'agy mcp add' com --project em $ProjectPath"
        } else {
            Report "Serena (registro MCP global)" "MANUAL" "'agy' nao encontrado no PATH desta sessao - registre manualmente dentro do terminal Antigravity real"
        }
    } else {
        Report "Serena (registro MCP global)" "MANUAL" "usuario optou por nao registrar agora - pendente, nao bloqueante"
    }
}

Write-Host ""

# ---------------------------------------------------------------------------
# 4. Graphify - versao registrada: 0.9.8
# ---------------------------------------------------------------------------

if (Test-CommandExists "python") {
    $graphifyCheck = (python -m graphify --version) 2>&1
    if ($LASTEXITCODE -eq 0) {
        Report "Graphify" "OK" "ja instalado ($graphifyCheck) - rodando 'graphify update' para manter o grafo atual"
        Push-Location $ProjectPath
        python -m graphify update . | Out-Null
        Pop-Location
        Report "Graphify (grafo atualizado)" "OK" "python -m graphify update . executado em $ProjectPath"
    } else {
        $resp3 = Read-Host "Graphify nao encontrado. Instalar agora ('python -m pip install graphify' + 'python -m graphify install --platform claude')? (Y/N)"
        if ($resp3 -match "^[Yy]") {
            python -m pip install graphify
            Push-Location $ProjectPath
            python -m graphify install --platform claude
            python -m graphify update .
            Pop-Location
            Report "Graphify" "OK" "instalado e grafo gerado"
        } else {
            Report "Graphify" "MANUAL" "usuario optou por nao instalar agora"
        }
    }
} else {
    Report "Graphify" "MANUAL" "depende de Python (ver passo 1)"
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
        $resp4 = Read-Host "Skill UI UX Pro Max ausente. Instalar agora ('npx ui-ux-pro-max-cli init --ai claude', escopo local)? (Y/N)"
        if ($resp4 -match "^[Yy]") {
            Push-Location $ProjectPath
            npx --yes ui-ux-pro-max-cli init --ai claude
            Pop-Location
            Report "Skill UI UX Pro Max" "OK" "instalada via npx, escopo local"
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

$manuais = $results | Where-Object { $_.Status -eq "MANUAL" }
if ($manuais) {
    Write-Host ""
    Write-Host "Acoes manuais pendentes:"
    $manuais | ForEach-Object { Write-Host " - $($_.Step): $($_.Detail)" }
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

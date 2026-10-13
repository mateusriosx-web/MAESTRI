---
name: rtk
description: Reduz consumo de token comprimindo output de comandos usando o binário oficial `rtk` (Rust Token Killer, rtk-ai/rtk) e evitando varredura de diretório inteiro. Use SEMPRE que for rodar um comando com output potencialmente grande (build, teste, grep amplo) ou quando precisar localizar código no projeto.
---

# RTK — Rust Token Killer (binário oficial)

Instalado neste ambiente: `rtk 0.52.0` (`rtk-ai/rtk`, https://github.com/rtk-ai/rtk), binário em `C:\Users\mateu\bin\rtk.exe` (no PATH). Validado em 2026-10-13 — ver `DIARIO_DE_BORDO.md`.

Skill de disciplina de uso de ferramentas para reduzir consumo de contexto/token em qualquer agente deste projeto (`cto`, `backend-dev`, `frontend-dev`, `data-analyst`, `devops-infra`, `security-auditor`, `qa-e2e`, `tech-writer`, `test-runner`, `spec-lookup`).

## Estado real da integração (verificado, não suposto)

- **Instalação é LOCAL a este projeto** (`rtk init` sem `-g`, dentro de `AUTOMACAO_HD`) — por decisão do usuário, para não afetar outros projetos (ex. Analise de Custos) nem o `~/.claude/CLAUDE.md` global.
- **Claude Code (sessão `cto`/principal):** instruções injetadas em `CLAUDE.md` (bloco `<!-- rtk-instructions v2 -->`). **Sem hook automático** — o `rtk` instala o hook `PreToolUse` (que reescreveria `git status` → `rtk git status` sozinho) apenas em modo global (`rtk init -g`), que foi deliberadamente evitado aqui. **Limitação real, não contornada:** todo comando potencialmente grande precisa ser chamado explicitamente com `rtk <subcomando>` (ver lista abaixo) em vez de confiar em reescrita automática.
- **Antigravity (`agy`, agente real dos 11 terminais Maestri conectados a este projeto):** plugin instalado localmente em `.agents/plugins/rtk/` (`rtk init --agent antigravity`), com hook `PreToolUse -> rtk hook antigravity` — **este sim é automático** para comandos de shell desses terminais, desde que o `agy` tenha sido reiniciado depois da instalação (feito em 2026-10-13 para os 11 terminais ativos). Terminais novos/recriados depois disso já carregam o plugin ao iniciar, sem passo manual.
- **Ferramentas internas do Claude Code (`Read`, `Grep`, `Glob`) nunca passam pelo hook** — isso é limitação documentada do próprio `rtk`, não deste projeto. Para elas não há substituto; a Regra 1 abaixo (preferir Graphify) é o que resolve.

## Regra 1 — Nunca varra o diretório inteiro para localizar código

Antes de usar `Grep`/`Glob` de forma exploratória no repositório inteiro (ou em qualquer `automacoes/<nome>/`), primeiro tente:

```
python -m graphify query "<pergunta em linguagem natural sobre o código/projeto>"
python -m graphify path "<A>" "<B>"
python -m graphify explain "<conceito>"
```

Só caia para `Grep`/`Glob`/`Read` de arquivo inteiro se o Graphify não tiver a resposta — sinalize que o grafo pode estar desatualizado (`python -m graphify update .`) em vez de compensar com varredura grande.

## Regra 2 — Chame o `rtk` explicitamente (Claude Code não tem hook aqui)

Ao rodar via `Bash` um comando que pode gerar saída grande, use o subcomando `rtk` equivalente em vez do comando puro:

| Em vez de... | Use |
|---|---|
| `ls`, `find` | `rtk ls`, `rtk find` |
| `cat`/leitura de arquivo grande | `rtk read <arquivo>` |
| `grep -r` | `rtk grep -r "<padrão>" <caminho>` |
| `git status`/`git diff`/`git log` | `rtk git status` / `rtk git diff` / `rtk git log` |
| rodar suíte de teste | `rtk test <cmd>` (mostra só falhas) |
| `docker ps`/`kubectl ...` | `rtk docker ps` / `rtk kubectl pods` (se aplicável a alguma automação) |

Se o resultado do `rtk <cmd>` parecer incompleto/estranho, rode `rtk proxy <cmd>` para ver a saída crua antes de desistir.

Para os terminais Antigravity (Maestri), o hook já reescreve automaticamente — não precisa chamar `rtk` manualmente lá, mas se um comando não for reescrito (plugin desatualizado/terminal recriado sem reiniciar), caia para a chamada explícita acima.

## Regra 3 — Verificação pontual, não varredura, mas sempre verificação

A regra "Verificação antes de afirmar" do `CLAUDE.md` continua valendo sem exceção: nenhuma afirmação de status sem ter rodado o comando/checagem que prova isso. O que o RTK economiza é o ESCOPO/VOLUME da saída, não a verificação em si — e **nunca filtra/esconde erro**: todo teste de validação feito nesta instalação confirmou que mensagens de erro (`No such file or directory`, `Is a directory`, etc.) passam intactas pelo `rtk`.

Ao terminar uma tarefa, registre um relatório curto e estruturado: o que foi feito, em qual arquivo:linha, e como foi verificado. Quem coordena (`cto`) confere de forma barata — arquivo:linha citado, checagem pontual — em vez de reler tudo.

## Regra 4 — Grafo desatualizado é sinal, não desculpa

Se `python -m graphify query`/`path` não achar algo que deveria existir, rode `python -m graphify update .` — não é permissão para `Grep -r` cego no repositório inteiro.

## Como validar que o `rtk` está funcionando

```
rtk --version          # confirma binário instalado
rtk gain                # painel de economia acumulada (vazio até ter uso real registrado)
rtk init --show          # mostra o que está configurado localmente neste projeto
```

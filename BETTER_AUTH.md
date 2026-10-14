# Better Auth — uso sob demanda

Orientação central para adotar autenticação/autorização com [Better Auth](https://better-auth.com) (TypeScript, Node.js, funciona com React) num projeto que usa este template. Carregamento sob demanda — só entra em jogo quando o projeto precisar de login/sessão/controle de acesso.

## Origem e licença

- Framework: https://github.com/better-auth/better-auth — licença MIT.
- Orientação oficial para agentes: https://better-auth.com/docs/ai-resources (llms.txt, MCP de documentação, skills para assistentes de código) e skills em https://github.com/better-auth/skills (commit `20c9e88a5c007461a703f1c213572b073196113e`, mantido pela própria better-auth, `marketplace.json` versão `1.0.0`).
- **Esse repositório de skills não declara licença** (API do GitHub retorna `license: null`; nenhum arquivo `LICENSE` em nenhuma pasta) — diferente do caso Prisma (MIT explícito). Por isso **nenhum arquivo dele foi copiado para este template**. O agente consulta esse repositório/documentação sob demanda (`WebFetch`, `gh api`, ou o MCP oficial `mcp.better-auth.com/mcp` quando o usuário autorizar configurá-lo) em vez de manter cópia local.
- Skills oficiais disponíveis lá (para consulta direta, não cópia): `better-auth/best-practices` (setup geral, sessão, plugins, versão da doc por versão instalada), `better-auth/create-auth` (fluxo de planejamento antes de implementar), `better-auth/emailAndPassword` (verificação de e-mail, reset de senha), `better-auth/organization` (multi-tenant, papéis, RBAC), `better-auth/twoFactor` (2FA/TOTP/backup codes), `security` (rate limit, segredo, CSRF, origens confiáveis, cookies, criptografia de token OAuth, auditoria).

## Antes de qualquer implementação

1. **Projeto existente:** identifique a autenticação atual (sessão própria, outra lib, provedor externo) antes de propor qualquer coisa. Nunca substitua ou migre automaticamente — adoção de Better Auth é plano próprio, aprovado pelo usuário, considerando usuários/senhas/sessões existentes, schema atual e compatibilidade da stack (framework, ORM, banco).
2. **Versão da documentação:** resolva a versão do Better Auth instalada no projeto (lockfile/manifesto) antes de seguir qualquer exemplo — API e nomes de plugin variam entre versões mantidas.
3. Nada aqui autoriza instalar `better-auth` como dependência do próprio template, configurar MCP, criar banco/tela de demonstração, ou acessar produção.

## O que orientar (consultar a documentação oficial/skills para o "como")

- Login/logout, sessão (criação, expiração, revogação) e recuperação de senha.
- Verificação de e-mail e segundo fator (2FA) quando a automação exigir.
- Organizações, papéis e permissões (RBAC multi-tenant).
- **Autorização sempre no backend** — nunca confiar em esconder botão/rota no frontend como controle de acesso.
- **Isolamento entre empresas/tenants**: toda consulta que lê dado de organização precisa filtrar pela organização do usuário autenticado, nunca confiar em ID vindo do cliente sem validar contra a sessão.
- Proteção de cookies (`secure`/`httpOnly`/`sameSite`), segredo (`BETTER_AUTH_SECRET` via variável de ambiente, nunca hardcoded — ver premissa de segredo em `CLAUDE.md`) e configuração de origens confiáveis (CORS/`trustedOrigins`).

## Responsabilidades

- **BACK (`backend-dev`):** implementa a integração e escreve os testes do cenário principal (ver premissa "Teste automatizado para automação crítica" em `CLAUDE.md` — login/sessão/controle de acesso é crítico).
- **Segurança (`security-auditor`):** revisa a implementação (cookies, CORS, isolamento entre tenants, segredo) antes de qualquer rota ir para produção.
- **Migration (`migration-guardian`):** revisa qualquer alteração de schema que a adoção do Better Auth exigir (tabelas de usuário/sessão/organização).
- **TESTER (`test-runner`):** executa os testes escritos pelo BACK e reporta o veredito — nunca escreve teste.
- **FRONT (`frontend-dev`):** integra a interface (telas de login, 2FA, convite de organização), mas **nunca assume que esconder um botão ou rota de navegação protege dado ou ação** — proteção real é sempre backend.

## Testes de aceite esperados (antes de declarar "pronto")

Com conta e dados locais de teste (nunca produção):

- Acesso permitido para o papel correto e **negado** para papel sem permissão.
- Acesso entre organizações/empresas diferentes **bloqueado** (usuário da empresa A não lê/edita dado da empresa B).
- Sessão expira conforme configurado; revogação de sessão realmente invalida acesso subsequente.
- Logout invalida a sessão (não só limpa cookie no cliente).
- Recuperação de senha funciona de ponta a ponta (solicitar → receber/simular e-mail → redefinir → logar com a nova senha).

**Não declarar autenticação "funcionando" sem essas verificações rodadas de fato numa implementação real** — documentar a orientação aqui não é a mesma coisa que ter testado.

## Registro no diário

Instalação (nenhuma, só referência — ver acima), configuração e validação de qualquer adoção real de Better Auth num projeto se registram como entradas separadas em `DIARIO_DE_BORDO.md` daquele projeto — nunca misturadas como se fossem a mesma etapa.

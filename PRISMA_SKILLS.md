# Prisma Skills — uso sob demanda

Origem: https://github.com/prisma/skills
Licença: MIT; revisão fixada: be16a8740d01363d13552b317042431ee8dfc581.
Instalação local: .claude/skills/. Sem plugin, MCP, ORM ou banco instalado por esta integração.

## Seleção e compatibilidade
- Antes de carregar, identificar versão efetiva no package.json/lockfile, provider, schema/config e imports; não executar comandos que imprimam credenciais.
- Setup/conexão: prisma-orm-setup/SKILL.md (metadata 1.0.0; contempla 6/7/8).
- Prisma 7: prisma-cli/SKILL.md e prisma-client-api/SKILL.md (metadata 7.9.1), abrindo apenas as referências necessárias.
- Prisma 6: documentação oficial da versão 6; não aplicar exemplos de configuração/client da versão 7.
- Prisma 8: orientação versionada do pacote, quando já disponível no projeto; sua ausência é pendência, não autorização para instalar outra skill.
- Para projeto novo, CTO define versão/provider com requisitos reais. O padrão Prisma 8 do upstream não autoriza inicialização, upgrade, provisionamento ou adoção de release candidata.
- Não instalar/atualizar Prisma, registrar MCP, acessar produção ou executar migrations apenas para testar skills. Alterações destrutivas exigem aprovação específica, backup e revisão Migration.

## Papéis e ativação
BACK: queries, relações, transações e implementação. Migration: schema, migrations, integridade e recuperação. SPEC: correspondência entre modelo e regras reais. TESTER: executa os testes escritos pelo implementador.
Clientes sem descoberta automática: ler explicitamente este guia e o SKILL.md selecionado, com caminhos relativos à raiz detectada. Não carregar o catálogo inteiro nem fixar cliente/modelo no papel.

## Preparação e validação
O clone já contém skills e referências: não reinstalar a cada preparo. Conferir presença, links locais e revisão acima. Instalação documental não prova queries/migrations em banco: verificar no projeto de destino com dados locais de teste e versão compatível.

Referencias opcionais upstream para prisma-mongodb-upgrade e prisma-postgres-setup nao estao instaladas. Se a tarefa exigir esses fluxos, registrar a dependencia e avaliar separadamente; nao instalar automaticamente.

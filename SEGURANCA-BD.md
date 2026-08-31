# Acesso ao banco de dados — SGV

Antes, tudo se conectava ao PostgreSQL como `postgres` (superusuário, senha no
`compose.yaml`, no GitHub). Agora cada parte do sistema tem seu próprio usuário,
com o mínimo de permissão que precisa.

Scripts em [`db/`](db/README.md).

## Usuários

| Usuário | Serve pra quê | Pode |
| --- | --- | --- |
| `sgv_api` | Runtime da sgv-api | Ler e gravar dados |
| `sgv_migrator` | Criar e alterar tabelas (deploy, mudança de `@Entity`) | Tudo no schema |
| `sgv_dev` | Time, via psql/DBeaver | Só ler |
| `postgres` | Criar o banco no start do container | Superusuário |

Nenhum dos três primeiros é superusuário nem pode criar usuários.

Na prática isso significa que a API — a parte exposta na rede — não consegue
dropar uma tabela, e um `UPDATE` sem `WHERE` no DBeaver é recusado pelo banco.

## Grupos

Permissão fica no grupo, não no usuário: para dar ou tirar acesso, muda-se o
grupo da pessoa. A matriz inteira cabe em `db/04-permissoes.sql`.

| Grupo | Privilégios | Quem está nele |
| --- | --- | --- |
| `sgv_ddl` | Dono do schema: `CREATE`, `ALTER`, `DROP` | `sgv_migrator` |
| `sgv_app` | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | `sgv_api` |
| `sgv_leitura` | `SELECT` | `sgv_dev` |

O `PUBLIC` foi esvaziado — sem isso, qualquer role criada no servidor entraria
no banco por padrão.

O `ALTER DEFAULT PRIVILEGES` faz uma tabela criada amanhã já nascer com essas
permissões, sem precisar repetir os GRANTs.

## Onde ficam as senhas

| Onde | Arquivo | Versionado? |
| --- | --- | --- |
| Docker | `ES2/.env` (modelo: `.env.example`) | ❌ `.gitignore` |
| Dev, a API | `sgv-api/application-local.properties` | ❌ `.gitignore` |
| Dev, pessoal | Gerenciador de senhas ou `~/.pgpass` (chmod 600) | ❌ |
| Produção | Secret do orquestrador ou cofre, como variável de ambiente | ❌ |

Não há senha em `compose.yaml`, `application.properties` nem nos `.sql`. O
compose usa `${SGV_SENHA_API:?...}`: sem `.env` ele falha com mensagem clara,
em vez de subir com uma senha padrão.

Para trocar uma senha basta `ALTER ROLE sgv_api WITH PASSWORD 'nova'` e
atualizar o `.env` — as permissões estão no grupo, não mudam. Se uma senha
vazar em um commit, trocar é obrigatório: apagar o commit não desfaz os clones.

## O que isso mudou no projeto

A API roda com `ddl-auto=validate`, porque `sgv_api` não faz DDL: o schema é o
`db/03-schema.sql`. Mudou uma `@Entity`? Atualize o script — em troca, some o
problema do `ddl-auto=update` travando ao adicionar coluna obrigatória.

## Limitações

- As senhas do `.env` ficam em texto na máquina. Em produção o `.env` daria
  lugar a um cofre; grupos e usuários continuariam iguais.
- Isto controla **quem fala com o PostgreSQL**. Os perfis "colaborador" e
  "gestor" do SGV são outra camada, ainda sem login de verdade.
- Sem TLS entre API e banco (mesma rede do compose). Em produção,
  `sslmode=require`.

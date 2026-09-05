# Scripts de banco — SGV

Rodam nesta ordem, e cada um pode ser executado de novo sem quebrar:

| Arquivo | O que faz |
| --- | --- |
| `01-grupos.sql` | Cria os grupos `sgv_ddl`, `sgv_app`, `sgv_leitura` |
| `02-usuarios.sql` | Cria os usuários e coloca cada um no seu grupo |
| `03-schema.sql` | Tabelas `destino`, `area`, `colaborador`, `viagem` |
| `04-permissoes.sql` | GRANTs dos grupos |
| `init/00-bootstrap.sh` | Roda os quatro na criação do container Postgres |

Quem pode o quê: [`../SEGURANCA-BD.md`](../SEGURANCA-BD.md).

## Docker

```bash
cp .env.example .env    # e trocar as senhas
docker compose up -d --build
```

Os scripts rodam sozinhos — mas **só com o volume do banco vazio**. Se você já
subiu o projeto antes desta mudança, a API vai falhar ao conectar como
`sgv_api`. Nesse caso, `docker compose down -v` (apaga os dados de preview) e
suba de novo.

## Dev (Postgres na máquina)

Uma vez, com o banco `sgv_db` criado:

```bash
cd db

# Escolha as senhas primeiro — você vai precisar delas depois.
export SENHA_MIGRATOR="$(openssl rand -base64 24)"
export SENHA_API="$(openssl rand -base64 24)"
export SENHA_DEV="$(openssl rand -base64 24)"

psql -U postgres -d sgv_db -v db=sgv_db -f 01-grupos.sql
psql -U postgres -d sgv_db \
  -v senha_migrator="$SENHA_MIGRATOR" \
  -v senha_api="$SENHA_API" \
  -v senha_dev="$SENHA_DEV" \
  -f 02-usuarios.sql
psql -U postgres -d sgv_db -f 03-schema.sql
psql -U postgres -d sgv_db -f 04-permissoes.sql

# Anote as três num gerenciador de senhas — o terminal fecha e elas somem.
printf 'migrator=%s\napi=%s\ndev=%s\n' \
  "$SENHA_MIGRATOR" "$SENHA_API" "$SENHA_DEV"
```

A senha da API vai para `sgv-api/application-local.properties` (já no
`.gitignore`), e o Spring lê sozinho:

```properties
spring.datasource.password=<SENHA_API>
```

Esqueceu alguma? Não dá para consultar — o Postgres só guarda o hash. Defina
outra como superusuário:

```sql
ALTER ROLE sgv_dev WITH PASSWORD 'nova-senha';
```

## Conectar no DBeaver

Use `sgv_dev`. Repare que dev e Docker são bancos diferentes, em portas
diferentes:

| Campo | Dev (Postgres da máquina) | Docker |
| --- | --- | --- |
| Host | `localhost` | `localhost` |
| Port | `5432` | `5433` |
| Database | `sgv_db` | `sgv_api` |
| Username | `sgv_dev` | `sgv_dev` |
| Password | a que você gerou acima | o `SGV_SENHA_DEV` do seu `.env` |

O DBeaver guarda a senha no próprio cofre dele (marque "Save password") — não
precisa anotar em arquivo do projeto.

## Situações do dia a dia

**Criei/alterei uma `@Entity`.** Atualize `03-schema.sql` e aplique:

```bash
psql -U sgv_migrator -d sgv_db -f 03-schema.sql
```

**Preciso corrigir um dado na mão em dev.** O `sgv_dev` só lê. Use o
`sgv_migrator`, ou libere escrita temporariamente:

```sql
GRANT sgv_app TO sgv_dev;    -- REVOKE quando terminar
```

## Conferir se está certo

```sql
-- quem está em qual grupo
SELECT r.rolname AS usuario, g.rolname AS grupo
  FROM pg_auth_members m
  JOIN pg_roles r ON r.oid = m.member
  JOIN pg_roles g ON g.oid = m.roleid
 WHERE g.rolname LIKE 'sgv\_%';

-- ninguém da aplicação é superusuário
SELECT rolname, rolsuper FROM pg_roles WHERE rolname LIKE 'sgv\_%';
```

Os bloqueios devem dar erro de permissão:

```bash
psql "postgresql://sgv_api:SENHA@localhost:5433/sgv_api" -c "DROP TABLE viagem;"
# ERROR: must be owner of table viagem

psql "postgresql://sgv_dev:SENHA@localhost:5433/sgv_api" \
  -c "INSERT INTO destino (nome,cidade,pais) VALUES ('x','y','z');"
# ERROR: permission denied for table destino
```

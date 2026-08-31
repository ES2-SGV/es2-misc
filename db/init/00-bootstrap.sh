#!/bin/bash
# Roda uma vez, quando o container do Postgres é criado com o volume vazio.
# As senhas vêm do ambiente, que o compose lê do .env.
set -euo pipefail

: "${SGV_SENHA_MIGRATOR:?defina SGV_SENHA_MIGRATOR no .env}"
: "${SGV_SENHA_API:?defina SGV_SENHA_API no .env}"
: "${SGV_SENHA_DEV:?defina SGV_SENHA_DEV no .env}"

executar() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
    -v db="$POSTGRES_DB" \
    -v senha_migrator="$SGV_SENHA_MIGRATOR" \
    -v senha_api="$SGV_SENHA_API" \
    -v senha_dev="$SGV_SENHA_DEV" \
    -f "$1"
}

echo "[sgv] aplicando grupos, usuários, schema e permissões..."
executar /sgv-db/01-grupos.sql
executar /sgv-db/02-usuarios.sql
executar /sgv-db/03-schema.sql
executar /sgv-db/04-permissoes.sql
echo "[sgv] banco pronto."

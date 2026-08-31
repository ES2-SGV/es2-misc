-- Usuários de login do SGV: um por finalidade, nenhum superusuário.
-- As senhas vêm de variáveis do psql — não há senha escrita neste arquivo.
--
--   psql -U postgres -d sgv_db -v senha_migrator=... -v senha_api=... \
--        -v senha_dev=... -f 02-usuarios.sql

\set ON_ERROR_STOP on

-- Migrações e deploy. Não fica em nenhuma aplicação em execução.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_migrator') THEN
    CREATE ROLE sgv_migrator LOGIN;
  END IF;
END $$;
ALTER ROLE sgv_migrator WITH PASSWORD :'senha_migrator' CONNECTION LIMIT 5;
GRANT sgv_ddl TO sgv_migrator;

-- Runtime da sgv-api.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_api') THEN
    CREATE ROLE sgv_api LOGIN;
  END IF;
END $$;
ALTER ROLE sgv_api WITH PASSWORD :'senha_api' CONNECTION LIMIT 20;
GRANT sgv_app TO sgv_api;

-- Acesso humano do time (psql, DBeaver). Só leitura.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_dev') THEN
    CREATE ROLE sgv_dev LOGIN;
  END IF;
END $$;
ALTER ROLE sgv_dev WITH PASSWORD :'senha_dev' CONNECTION LIMIT 5;
GRANT sgv_leitura TO sgv_dev;

-- Evita que uma consulta pesada segure locks e atrapalhe a API.
ALTER ROLE sgv_dev SET statement_timeout = '60s';
ALTER ROLE sgv_api SET statement_timeout = '15s';

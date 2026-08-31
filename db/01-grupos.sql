-- Grupos de acesso do SGV. Privilégio fica sempre no grupo, nunca no usuário.
-- Executar como superusuário: psql -U postgres -d sgv_db -v db=sgv_db -f 01-grupos.sql

\set ON_ERROR_STOP on

DO $$
BEGIN
  -- Dono do schema: DDL e migrações.
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_ddl') THEN
    CREATE ROLE sgv_ddl NOLOGIN;
  END IF;
  -- Aplicação: mexe nos dados, não na estrutura.
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_app') THEN
    CREATE ROLE sgv_app NOLOGIN;
  END IF;
  -- Consulta: somente SELECT.
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgv_leitura') THEN
    CREATE ROLE sgv_leitura NOLOGIN;
  END IF;
END
$$;

-- Sem isso, qualquer role nova entraria no banco por padrão.
REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE :"db" TO sgv_ddl, sgv_app, sgv_leitura;

-- Acesso ao schema. Precisa vir antes de 03-schema.sql, que cria as tabelas
-- já como sgv_ddl. Privilégios sobre as tabelas ficam em 04.
GRANT USAGE, CREATE ON SCHEMA public TO sgv_ddl;
GRANT USAGE         ON SCHEMA public TO sgv_app, sgv_leitura;

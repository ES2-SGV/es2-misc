-- Permissões dos grupos. Roda depois do schema; executar como superusuário.
-- O acesso ao schema (USAGE/CREATE) fica em 01-grupos.sql.

\set ON_ERROR_STOP on

-- Aplicação: dados sim, estrutura não. Sem TRUNCATE de propósito.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA public TO sgv_app;
GRANT USAGE, SELECT                 ON ALL SEQUENCES IN SCHEMA public TO sgv_app;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO sgv_leitura;

-- Vale para as tabelas que sgv_ddl criar daqui pra frente: uma migração futura
-- não precisa lembrar de repetir os GRANTs acima.
ALTER DEFAULT PRIVILEGES FOR ROLE sgv_ddl IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sgv_app;
ALTER DEFAULT PRIVILEGES FOR ROLE sgv_ddl IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO sgv_app;
ALTER DEFAULT PRIVILEGES FOR ROLE sgv_ddl IN SCHEMA public
  GRANT SELECT ON TABLES TO sgv_leitura;

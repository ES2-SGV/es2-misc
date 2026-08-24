# Portas — dev e preview

Convenção do projeto: **preview = porta de dev + 1**.

Dev roda direto na máquina (`./mvnw spring-boot:run`, `npm run dev`) e fica nas
portas padrão. O preview é a stack do `compose.yaml` e fica sempre uma porta
acima. Assim dá pra rodar os dois ao mesmo tempo sem conflito.

| Serviço  | Dev (local)              | Preview (compose)          |
| -------- | ------------------------ | -------------------------- |
| Frontend | 5173                     | 5174                       |
| API      | 8080                     | 8081                       |
| Postgres | 5432                     | 5433                       |

Dentro da rede do compose os containers continuam usando as portas internas
normais (api `8080`, db `5432`, nginx `80`) — o `+1` é só no lado do host.

## Onde cada porta está definida

| Porta      | Arquivo                                            |
| ---------- | -------------------------------------------------- |
| Dev 5173   | `sgv-web/vite.config.ts` → `server.port`            |
| Dev 8080   | `sgv-api/src/main/resources/application.properties` → `server.port` |
| Dev 5432   | Postgres do sistema (fora do compose)              |
| Preview    | `compose.yaml` → `ports:` de cada serviço          |

A porta da API aceita override por env var: `SERVER_PORT=9000 ./mvnw spring-boot:run`.

## Bancos são separados

Dev e preview **não compartilham dados**:

| Ambiente | Host           | Database  | Usuário / senha     |
| -------- | -------------- | --------- | ------------------- |
| Dev      | localhost:5432 | `sgv_db`  | `postgres` / `root` |
| Preview  | localhost:5433 | `sgv_api` | `postgres` / `postgres` |

O preview usa o volume `sgv_pgdata`. `docker compose down -v` apaga esses dados.

## Comandos

```bash
# dev
cd sgv-api && ./mvnw spring-boot:run      # :8080
cd sgv-web && npm run dev                 # :5173

# preview (sempre com --build, senão sobe imagem velha)
docker compose up -d --build              # :5174 / :8081 / :5433
docker compose down                       # -v também apaga o banco
```

## Como o front acha a API

O front chama a API direto (sem proxy no nginx), então duas coisas precisam
bater:

| O quê                  | Dev                     | Preview (compose)         |
| ---------------------- | ----------------------- | ------------------------- |
| `VITE_API_BASEURL`     | `sgv-web/.env` → `:8080` | build arg no `compose.yaml` → `:8081` |
| `CORS_ALLOWED_ORIGINS` | default do `application.properties` → `:5173` | env do serviço `api` → `:5174` |

`VITE_API_BASEURL` é embutido no bundle **em tempo de build** (Vite), e o `.env`
está no `.dockerignore` — por isso o valor do preview vai como `args:` no
`compose.yaml` e não como `environment:`. Mudou a URL da API? Precisa
`--build`, não basta `up`.

Do lado da API, `CorsConfig` (em `sgv-api/.../shared/`) lê
`CORS_ALLOWED_ORIGINS` (lista separada por vírgula). Sem auth ainda, então não
tem `allowCredentials`; quando entrar login com cookie/token, ativar isso e aí
a lista de origens não pode mais ser genérica.

## Pendências

- `compose.yaml` e este arquivo estão na pasta `ES2/`, que não é um repo git.
  Enquanto não forem versionados, cada dev precisa criá-los na mão.

# SGV — Sistema de Gestão de Viagens

Repositório de apoio do projeto: documentos, especificação e o `compose.yaml`
que sobe o sistema inteiro. **O código-fonte não está aqui** — fica em dois
repositórios separados (veja o passo 1).

O sistema tem três partes, cada uma em seu container:

```
frontend (React + nginx)  ->  api (Spring Boot)  ->  db (PostgreSQL)
     :5174                      :8081                   :5433
```

---

## Passo 1 — Clonar os três repositórios

Este é o ponto que mais confunde quem chega: o `compose.yaml` faz build a partir
das pastas `./sgv-api/` e `./sgv-web/`, mas essas pastas **não vêm neste
repositório** (estão no `.gitignore`). Sem elas o compose falha.

Clone os três lado a lado, com o `es2-misc` como pasta raiz:

```bash
git clone https://github.com/ES2-SGV/es2-misc.git ES2
cd ES2
git clone https://github.com/ES2-SGV/sgv-api.git
git clone https://github.com/ES2-SGV/sgv-web.git
```

O resultado tem que ser exatamente esta estrutura:

```
ES2/
├── compose.yaml
├── README.md
├── especificacao-requisitos-sgv.md
├── .env.example
├── db/
├── sgv-api/     <- clonado
└── sgv-web/     <- clonado
```

## Passo 2 — Subir tudo

Precisa apenas de **Docker** com o plugin Compose. Nada de Java, Node ou
Postgres instalados na máquina.

Antes da primeira subida, crie o arquivo de credenciais a partir do modelo e
troque as senhas — não existe senha padrão no projeto:

```bash
cp .env.example .env
${EDITOR:-nano} .env
```

```bash
docker compose up -d --build
```

Na criação do banco, os scripts de `db/` rodam sozinhos e criam os grupos,
usuários e o schema. Detalhes em `SEGURANCA-BD.md` e `db/README.md`.

A primeira execução demora alguns minutos (baixa dependências Maven e npm). As
seguintes são rápidas por causa do cache.

O build usa o código que está nas suas pastas locais `sgv-api/` e `sgv-web/` —
ou seja, a branch em que cada repositório estiver *neste momento*, não
necessariamente a `main` do GitHub. Confira com `git -C sgv-api status` se algo
parecer diferente do esperado.

O compose respeita a ordem sozinho: o banco sobe primeiro, a API só inicia
quando o Postgres responde ao `pg_isready`, e o frontend só quando o
`/actuator/health` da API responde. Se o comando terminou sem erro, está tudo no ar.

## Passo 3 — Acessar

| O quê | URL |
| --- | --- |
| Aplicação (frontend) | http://localhost:5174 |
| API | http://localhost:8081 |
| Documentação da API (Swagger) | http://localhost:8081/swagger-ui.html |
| Health check da API | http://localhost:8081/actuator/health |
| Banco (via psql/DBeaver) | `localhost:5433`, db `sgv_api`, user `sgv_dev` (senha no seu `.env`) |

Comece pelo Swagger: ele lista todos os endpoints e permite testá-los pelo navegador.

---

## Comandos do dia a dia

```bash
docker compose ps                    # o que está no ar
docker compose logs -f api           # acompanhar os logs da API
docker compose down                  # derrubar (os dados do banco ficam)
docker compose down -v               # derrubar E apagar o banco
docker compose up -d --build api     # rebuildar só a API
```

## Portas

Convenção do projeto: **preview (Docker) = porta de dev + 1**. Isso permite
rodar o Docker e o ambiente de desenvolvimento ao mesmo tempo, sem conflito.

| Serviço | Dev (na máquina) | Docker |
| --- | --- | --- |
| Frontend | 5173 | 5174 |
| API | 8080 | 8081 |
| Postgres | 5432 | 5433 |

Os bancos de dev e do Docker são **separados** e não compartilham dados.
Detalhes em `PORTS.md`.

---

## Problemas comuns

**`port is already allocated`** — alguma das portas 5174, 8081 ou 5433 já está
ocupada. Descubra por quem com `ss -ltnp | grep 8081` e encerre, ou mude a porta
do lado esquerdo em `ports:` no `compose.yaml`.

**Mudei o código e nada mudou** — `docker compose up -d` sozinho reaproveita a
imagem antiga. Sempre use `--build` depois de alterar código.

**O frontend não conversa com a API** — a URL da API é embutida no bundle em
tempo de *build* (`VITE_PROD_API_BASEURL`, definido como `args:` no `compose.yaml`).
Mudou a URL? Precisa de `--build`, não basta reiniciar.

**A API não sobe depois de mudar uma entidade** — o schema agora vem de
`db/03-schema.sql` e a API roda com `ddl-auto=validate`. Se você mudou uma
`@Entity` sem mexer no script, o Hibernate reclama que o mapeamento não bate.
Atualize o script e recrie o banco com `docker compose down -v`.

**`FATAL: password authentication failed for user "sgv_api"`** — o volume do
banco é anterior aos scripts de `db/`, então os usuários nunca foram criados.
`docker compose down -v` e suba de novo (apaga os dados de preview).

**Build da API muito lento na primeira vez** — normal, é o Maven baixando as
dependências dentro do container.

---

## Rodar sem Docker (desenvolvimento)

Para desenvolver com hot reload, rode cada parte direto na máquina. Aí é
preciso ter Java 21, Node e um Postgres local com o banco `sgv_db`:

```bash
cd sgv-api && ./mvnw spring-boot:run    # :8080
cd sgv-web && npm install && npm run dev # :5173
```

Cada repositório tem seu próprio README com os detalhes.

---

## Documentos do projeto

| Arquivo | Conteúdo |
| --- | --- |
| `especificacao-requisitos-sgv.md` | Requisitos, regras de negócio e entregáveis |
| `Doc de visao (ES2).doc` | Documento de visão |
| `Diagrama caso de uso.pdf` | Diagrama de casos de uso |
| `infos.md` | Planejamento das sprints |
| `PORTS.md` | Detalhamento de portas e configuração de rede |
| `SEGURANCA-BD.md` | Grupos, usuários, permissões e guarda de credenciais do banco |
| `db/README.md` | Como rodar os scripts de banco em dev e em Docker |

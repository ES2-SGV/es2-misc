Especificação de Requisitos 

Sistema de Gestão de Viagens (SGV) 

1. Apresentação do Problema 

A empresa XYZ realiza frequentemente viagens para participação em reuniões com clientes, treinamentos, eventos, congressos e visitas técnicas. 

Atualmente, o controle dessas viagens é realizado por meio de planilhas eletrônicas e troca de e-mails, o que dificulta o acompanhamento das solicitações, o controle dos gastos e a obtenção de informações gerenciais. 

Com o crescimento da organização, surgiu a necessidade de centralizar essas informações em um sistema único que permita registrar, acompanhar e analisar as viagens realizadas pelos colaboradores. 

Dessa forma, a empresa deseja contratar o desenvolvimento de um sistema web denominado Sistema de Gestão de Viagens (SGV). 

 

2. Objetivo 

O sistema deverá permitir o gerenciamento das viagens realizadas pelos colaboradores da empresa, desde o planejamento da viagem até o acompanhamento dos custos envolvidos. 

Além disso, o sistema deverá disponibilizar informações gerenciais que auxiliem os gestores na tomada de decisão e no controle dos gastos relacionados às viagens. 

 

3. Escopo da Solução 

O sistema deverá permitir que os usuários registrem viagens informando o destino, período da viagem, motivo e meio de transporte utilizado. 

Após o cadastro, o usuário deverá conseguir consultar, alterar e excluir viagens enquanto estas ainda não tiverem sido aprovadas. 

Toda viagem deverá possuir um responsável, que será o usuário que realizou seu cadastro. 

 

4. Controle de Aprovação 

A empresa deseja controlar o fluxo de aprovação das viagens. 

Inicialmente uma viagem deverá ser criada em situação de rascunho. 

Quando o colaborador concluir o planejamento da viagem, ele poderá submetê-la para análise. 

Uma viagem submetida poderá ser aprovada ou rejeitada por um gestor. 

Em caso de rejeição, o gestor deverá registrar uma justificativa. 

O sistema deverá manter um histórico de todas as alterações de situação ocorridas ao longo do ciclo de vida da viagem. 

As seguintes situações deverão ser suportadas: 

Rascunho; 

Solicitada; 

Aprovada; 

Rejeitada. 

O sistema deverá permitir a consulta do histórico completo das mudanças de situação de cada viagem. 

 

5. Controle Financeiro 

Uma vez aprovada a viagem, o colaborador deverá poder registrar os gastos realizados durante o deslocamento. 

O sistema deverá permitir o registro de despesas relacionadas à viagem, tais como: 

Hospedagem; 

Alimentação; 

Transporte; 

Combustível; 

Pedágios; 

Outras despesas necessárias. 

Para cada despesa deverão ser informados: 

Data da despesa; 

Tipo da despesa; 

Descrição; 

Valor gasto. 

O sistema deverá calcular automaticamente o valor total gasto na viagem. 

O usuário deverá poder consultar todas as despesas lançadas e visualizar um resumo financeiro consolidado da viagem. 

Despesas com valor igual ou inferior a zero não deverão ser aceitas. 

Também não deverão ser aceitos lançamentos com datas futuras. 

Viagens rejeitadas não poderão possuir despesas registradas. 

 

6. Consultas e Pesquisas 

O sistema deverá disponibilizar mecanismos para pesquisa de viagens. 

Os usuários deverão conseguir localizar viagens utilizando filtros como: 

Destino; 

Período; 

Situação da viagem. 

As pesquisas deverão retornar informações suficientes para que o usuário identifique rapidamente as viagens registradas e seus respectivos gastos. 

 

7. Informações Gerenciais 

A empresa deseja que o sistema apresente informações consolidadas para apoio à gestão. 

Deverão ser disponibilizados indicadores que permitam acompanhar: 

Quantidade total de viagens cadastradas; 

Quantidade de viagens aprovadas; 

Quantidade de viagens rejeitadas; 

Valor total gasto com viagens; 

Destino mais visitado; 

Custo médio por viagem. 

Essas informações deverão ser apresentadas por meio de painéis gráficos e indicadores numéricos de fácil compreensão. 

O objetivo é permitir que os gestores obtenham uma visão geral da utilização dos recursos destinados às viagens corporativas. 

 

8. Regras de Negócio 

A data de retorno da viagem deverá ser igual ou posterior à data de saída. 

O destino da viagem deverá ser informado obrigatoriamente. 

O motivo da viagem deverá ser informado obrigatoriamente. 

Somente viagens aprovadas poderão receber lançamentos de despesas. 

Toda alteração de situação deverá ser registrada em histórico. 

O valor total de uma viagem deverá ser calculado a partir da soma de todas as despesas associadas a ela. 

 

9. Requisitos Técnicos 

A solução deverá ser desenvolvida como uma aplicação web. 

A arquitetura deverá conter separação entre: 

Interface do usuário (Frontend); 

Serviços de negócio (Backend); 

Banco de Dados. 

O sistema deverá disponibilizar APIs REST para comunicação entre frontend (Rest) e backend (SpringBoot). 

O banco de dados utilizado deverá ser relacional (Postgres). 

A solução deverá ser executada em ambiente conteinerizado utilizando Docker para cada parte da arquitetura. 

Os dados cadastrados deverão permanecer armazenados mesmo após a reinicialização dos containers. 

 

10. Entregáveis Esperados 

Ao final do projeto, a empresa espera receber: 

-[] Documento de Visão 

-[] Documento de requisitos; 

-[] User Stories 

-[] Modelo de dados; 

-[] Diagramas UML (Digrama de Classes e Sequência); 

-[] Protótipos de telas 

-[] Código-fonte da solução; 

-[] Scripts de banco de dados; 

-[] Configurações Docker; 

-[] Sistema funcional executando localmente; 

 

 

11.Instruções 

Execução do projeto seguindo o modelo do SCRUM: 

Cerimônias 

Reuniões diárias 

Sprint Planning 

Sprint Review 

Spring Retrospective 

Artefatos 

Product Backlog 

Backlog da Sprint 

Incremento 

Usar o GitHub como repositório, com as branches: 

Main 

feature/planejar-viagem 

feature/registrar-despesas 

feature/aprovar-viagem 

feature/dashboard 

Develop 

Release 

release/1.0.0 

release/2.0.0 

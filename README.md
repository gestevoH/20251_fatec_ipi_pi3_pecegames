# Identificação dos Integrantes

| Nome Completo | RA |
|---------------|----|
|Gustavo Henrique Sousa Santos|2041382411034|
|Pedro Álvaro Brandão Pereira|2041382321022|
|Wagner das Chagas|2041382311049|

# Pece Games - Projeto Integrador III

Este projeto é parte do **Projeto Integrador III** do curso de Big Data para Negócios da Fatec Ipiragna, e simula a construção de um sistema analítico para a **Pece Games**, uma loja varejista de jogos e assistência técnica de consoles. O projeto integra conceitos de bancos de dados relacionais, Data Warehousing, programação em Python, estatística e visualização com Power BI.

---

## Objetivo

Construir um **Data Warehouse (DW)** relacional no PostgreSQL, desenvolver análises estatísticas com **Python**, aplicar automações com **Stored Procedures** e **Triggers**, e criar um **dashboard interativo** no Power BI. Tudo isso para responder perguntas de negócio e auxiliar na tomada de decisões com base em dados.

---

## Estrutura do Projeto

### 1. Modelagem do Data Warehouse

O **Data Warehouse** projetado neste projeto tem como objetivo centralizar, estruturar e organizar dados oriundos de múltiplas fontes, em especial os relacionados às vendas de jogos e serviços de assistência técnica de consoles, de forma que a análise de dados possa ser feita de maneira eficiente, confiável e escalável.

O modelo segue uma arquitetura composta por:

#### Tabelas Fato
- `fato_vendas_jogos`: Vendas globais de jogos, por região e por cliente.
- `fato_consertos`: Serviços de conserto realizados na assistência técnica.

#### Tabelas Dimensão
- `dim_jogo`, `dim_genero`, `dim_publicadora`, `dim_plataforma`, `dim_cliente`, `dim_tempo`
- `dim_servico`, `dim_console` (para consertos)

Essa modelagem permite analisar as vendas e consertos por diferentes cortes, como tempo, gênero, plataforma, cliente ou tipo de serviço.

---

### 2. Scripts SQL

Os scripts foram fundamentais para a implementação do projeto e estão divididos em:

## 1. Criação de Tabelas
Scripts para criação de todas as tabelas do DW, com suas respectivas chaves primárias e estrangeiras, garantindo integridade relacional.

Exemplos:

CREATE TABLE dim_jogo (
  id_jogo SERIAL PRIMARY KEY,
  nome_jogo VARCHAR(100),
  ...
);

## 2. Script de ETL
Extração dos dados da base PECEGAMES.

Transformações como normalização, conversão de tipos e eliminação de duplicidades.

Carga nas tabelas fato e dimensão com consistência referencial.

## 3. Atualizações e Ajustes
Multiplicação dos valores de vendas por 1.000.000, adequando à escala real.

UPDATE fato_vendas_jogos
SET vendas_globais = vendas_globais * 1000000;

## 4. Procedures e Triggers
Procedure com cursor dinâmico para calcular média e moda de vendas por plataforma, gerando estatísticas úteis diretamente no banco.

Trigger que registra inserções automáticas em uma tabela de log sempre que um novo conserto é registrado.

---

### 3. Stored Procedure: calcular_media_vendas_por_plataforma

## Função
Essa procedure tem como objetivo calcular, para cada plataforma de videogame registrada no banco de dados:
A média de vendas globais de jogos.
A moda dos gêneros mais vendidos — ou seja, qual gênero é mais frequente em termos de maior volume de vendas dentro de cada plataforma.

## Como ela funciona
**Cursor Dinâmico** (REFCURSOR): Um cursor é aberto a partir de uma query dinâmica, que realiza o JOIN entre as tabelas de fato e dimensões (fato_vendas_jogos, dim_jogo, dim_plataforma, dim_genero) e agrupa os dados por plataforma.

A procedure percorre cada linha retornada pela query usando um loop, e a cada iteração exibe com RAISE NOTICE:
**O nome da plataforma**
**A média de vendas** (formatada como número inteiro com separação por milhar)
**O gênero mais vendido** (moda)

## Importância para o projeto
O Procedure desenvolvido ajuda a entender o desempenho médio das plataformas.
Mostra qual tipo de jogo tem mais aderência para cada plataforma.
E auxilia a empresa a definir estoques ou focar campanhas promocionais em gêneros de maior sucesso por plataforma.

### 4. Trigger: registrar_log_conserto

## Função
Essa trigger serve para registrar automaticamente qualquer inserção na tabela de fato fato_consertos, que armazena os serviços de conserto prestados pela assistência técnica da Pece Games.

## Como ela funciona
Toda vez que um novo registro é inserido em **fato_consertos**, a trigger é disparada automaticamente **(AFTER INSERT)**.
A função associada **(registrar_log_conserto)** insere uma cópia dos dados inseridos (data, cliente, console, tipo de serviço e valor) na tabela auxiliar **log_consertos**.

## Importância para o projeto

**Garante rastreabilidade:** sabemos exatamente quem fez, o quê e quando.
Melhora a **segurança** e **governança de dados**.
Facilita **auditorias** e **análises futuras** sobre histórico de consertos.

---

### 5. Análise Estatística com Python

No início do desenvolvimento do projeto foram propostas algumas perguntas que deveriamos responder no decorrer do projeto. As perguntas buscavam entender tendências de vendas, preferências dos jogadores e comportamento de mercado. Para isso, criamos as seguintes funções:

A análise foi realizada com dados extraídos diretamente do Data Warehouse no PostgreSQL, usando pandas e **sqlalchemy** para conexão, análise e cruzamento de dados entre tabelas fato e dimensões.

## Q1. Gêneros de jogos mais vendidos globalmente
def generos_mais_vendidos(fato_vendas_jogos, dim_jogo, dim_genero):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_genero, on="id_genero")
    return df.groupby("nome_genero")["vendas_globais"].sum().sort_values(ascending=False)

## Importância:
Essa função identifica quais gêneros são mais populares entre os jogadores com base nas vendas acumuladas globalmente.

## Resposta à pergunta:
Mostra quais tipos de jogos (ex: Action, Shooter, Sports) lideram o mercado, auxiliando a Pece Games a priorizar o estoque e promoções desses gêneros.

## Q2. Plataformas com maior volume de vendas acumulado

def plataformas_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_plataforma):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_plataforma, on="id_plataforma")
    return df.groupby("nome_plataforma")["vendas_globais"].sum().sort_values(ascending=False)

## Importância:
Ajuda a entender quais consoles (ex: PS2, Xbox 360, PS3) geraram mais receita no mercado.

## Resposta à pergunta:
Orienta decisões sobre quais consoles manter em destaque na loja e quais têm maior potencial de venda.

## Q3. Editora com maior volume de vendas globais

def editoras_mais_vendidas(fato_vendas_jogos, dim_jogo, dim_publicadora):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_publicadora, on="id_publicadora")
    return df.groupby("nome_publicadora")["vendas_globais"].sum().sort_values(ascending=False)

## Importância:
Revela as editoras mais fortes no mercado, como Nintendo, EA, Activision.

## Resposta à pergunta:
Ajuda a empresa a firmar parcerias, licenciar produtos ou focar campanhas em marcas consolidadas.

## Q4. Comportamento de vendas ao longo dos anos

def vendas_por_ano(fato_vendas_jogos, dim_tempo):
    df = fato_vendas_jogos.merge(dim_tempo, on="id_tempo")
    return df.groupby("ano")["vendas_globais"].sum().sort_index()

## Importância:
Identifica a sazonalidade e tendências do setor ao longo do tempo.

## Resposta à pergunta:
Mostra se o mercado está em crescimento, estabilidade ou queda (ex: pico por volta de 2010).

## Q5. Top 5 jogos mais vendidos de todos os tempos

def jogos_mais_vendidos(fato_vendas_jogos, dim_jogo, top_n=5):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    return df.groupby("nome_jogo")["vendas_globais"].sum().sort_values(ascending=False).head(top_n)

## Importância:
Mostra quais jogos são verdadeiros blockbusters.

## Resposta à pergunta:
Informa quais jogos vale a pena manter no catálogo, mesmo antigos, por sua popularidade histórica.

## Q6. Distribuição de vendas por região geográfica

def distribuicao_geografica(fato_vendas_jogos):
    return {
        "América do Norte": fato_vendas_jogos["vendas_na"].sum(),
        "Europa": fato_vendas_jogos["vendas_eu"].sum(),
        "Japão": fato_vendas_jogos["vendas_jp"].sum(),
        "Outros": fato_vendas_jogos["vendas_outros"].sum(),
    }

## Importância:
Compreende o peso de cada região nas vendas globais, podendo apoiar estratégias de expansão.

## Resposta à pergunta:
Exibe que regiões como América do Norte lideram o mercado, o que pode orientar decisões de marketing e compras regionais.

## Q7. Preferências por gênero em cada região

def preferencias_genero_por_regiao(fato_vendas_jogos, dim_jogo, dim_genero):
    df = fato_vendas_jogos.merge(dim_jogo, on="id_jogo")
    df = df.merge(dim_genero, on="id_genero")
    return df.groupby("nome_genero")[["vendas_na", "vendas_eu", "vendas_jp", "vendas_outros"]].sum()

## Importância:
Permite entender como os gostos variam por região (por exemplo: Japão prefere RPGs; América do Norte prefere Action/Sports).

## Resposta à pergunta:
Dá base para decisões de compra localizada (foco por tipo de jogo dependendo do público-alvo regional).


## Complementos com Visualizações
Cada função foi acompanhada de gráficos de barras, linhas e pizza para reforçar a interpretação dos resultados e facilitar a tomada de decisão visual no Power BI e relatórios.

---

### 6. Dashboard no Power BI

O dashboard desenvolvido no **Power BI** tem como principal objetivo visualizar e analisar dados de vendas de jogos e serviços de assistência técnica de consoles, com base no Data Warehouse construído em PostgreSQL.

## Visão Geral
O painel oferece uma interface visual para stakeholders acompanharem:

O desempenho de vendas de jogos por gênero, plataforma e região.
A evolução do mercado de games ao longo dos anos.
Os consoles mais enviados para manutenção e o volume de consertos por serviço.
Informações úteis para decisões estratégicas de estoque, marketing e suporte técnico.

## Funcionalidades do Dashboard

## 1. Análise de Vendas de Jogos
Gêneros mais vendidos: gráfico de barras que destaca os gêneros mais populares.

Plataformas de destaque: visual com as plataformas com maior volume de vendas acumuladas.

Editoras líderes: gráfico de pizza mostrando a participação das principais publicadoras.

Vendas por Ano: linha do tempo mostrando o crescimento ou queda nas vendas globais.

Distribuição Geográfica: gráfico de colunas que compara vendas por região (NA, EU, JP, Outros).

## 2. Análise de Consertos de Consoles
Quantidade de consertos por console: destaca os modelos mais consertados (ex: Xbox 360, PS4).

Tipos de serviço mais realizados: identifica quais serviços são mais comuns (ex: reparos na placa mãe, limpeza interna).

Receita total dos serviços: monitora os valores arrecadados em reparos, úteis para controle de receita e logística.

## Estrutura Técnica
**Fonte de dados**: PostgreSQL com estrutura de Data Warehouse.

Atualização: conexão direta via Power BI Desktop.

Modelagem no Power BI: todas as tabelas **fato** e **dimensões** possuem relacionamentos adequados (chave primária/estrangeira).

Filtros dinâmicos: permite selecionar plataformas específicas, anos ou gêneros para análises segmentadas.

## Benefícios do Dashboard
Apoia decisões de negócio e operação, como reposição de jogos, campanhas promocionais e gestão de serviços.

Oferece transparência de dados com acesso visual simples e direto.

Reduz tempo de análise manual e facilita o monitoramento contínuo.

---

### Melhorias Futuras

- Agendamento automático de ETL via Airflow
- Criação de APIs para consulta dos dados
- Interface Web para relatórios
- Log de alterações em outras tabelas críticas

---


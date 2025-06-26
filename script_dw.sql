
-- Tabela usada como base temporária para carregar os dados---------------------------------------

-- CREATE TABLE staging_pecegames (
-- 	id_cliente INT,
--     nome_cliente VARCHAR(100),
--     sobrenome_cliente VARCHAR(100),
--     email_cliente VARCHAR(200),
--     sexo_cliente VARCHAR(100),
--     telefone_cliente VARCHAR(30),
-- 	rank_game INT,
--     nome_jogo VARCHAR(200),
--     plataforma VARCHAR(100),
--     publicadora VARCHAR(200),
-- 	ano_lancamento INT,
-- 	genero VARCHAR(50),
--     vendas_na NUMERIC(6,2),
--     vendas_eu NUMERIC(6,2),
--     vendas_jp NUMERIC(6,2),
--     vendas_outros NUMERIC(6,2),
--     vendas_globais NUMERIC(6,2)
-- );    

-- SELECT * FROM staging_pecegames;
----------------------------------------------------------------------------------------

-- Criando as tabelas dimensão----------------------------------------------------------

-- CREATE TABLE dim_cliente (
--     id_cliente INT PRIMARY KEY,
--     nome VARCHAR(100),
--     sobrenome VARCHAR(200),
--     email VARCHAR(100),
--     sexo VARCHAR(10),
--     telefone VARCHAR(20)
-- );

-- CREATE TABLE dim_genero (
--     id_genero SERIAL PRIMARY KEY,
--     nome_genero VARCHAR(50)
-- );

-- CREATE TABLE dim_publicadora (
--     id_publicadora SERIAL PRIMARY KEY,
--     nome_publicadora VARCHAR(100)
-- );

-- CREATE TABLE dim_plataforma (
--     id_plataforma SERIAL PRIMARY KEY,
--     nome_plataforma VARCHAR(50)
-- );

-- CREATE TABLE dim_jogo (
--     id_jogo SERIAL PRIMARY KEY,
--     nome_jogo VARCHAR(100),
--     id_genero INT REFERENCES dim_genero(id_genero),
--     id_plataforma INT REFERENCES dim_plataforma(id_plataforma),
--     id_publicadora INT REFERENCES dim_publicadora(id_publicadora),
--     ano_lancamento INT
-- );

-- CREATE TABLE dim_tempo (
--     id_tempo SERIAL PRIMARY KEY,
--     ano INT,
--     trimestre INT
-- );

-- Criando a tabela Fato ----------------------------------------------

-- CREATE TABLE fato_vendas_jogos (
--     id_venda SERIAL PRIMARY KEY,
    
--     vendas_na NUMERIC(6,2),
--     vendas_eu NUMERIC(6,2),
--     vendas_jp NUMERIC(6,2),
--     vendas_outros NUMERIC(6,2),
--     vendas_globais NUMERIC(6,2),
    
--     rank_game INT,
    
--     id_jogo INT REFERENCES dim_jogo(id_jogo),
--     id_cliente INT REFERENCES dim_cliente(id_cliente),
--     id_tempo INT REFERENCES dim_tempo(id_tempo)
-- );

-- ALTER TABLE dim_cliente ALTER COLUMN sexo TYPE VARCHAR(100);

-- ALTER TABLE dim_publicadora ALTER COLUMN nome_publicadora TYPE VARCHAR(200);

-- ALTER TABLE dim_jogo ALTER COLUMN nome_jogo TYPE VARCHAR(200);

-- 1. Carregamento das Tabelas de Dimensão----------------------------------------------

-- INSERT INTO dim_cliente (id_cliente, nome, sobrenome, email, sexo, telefone)
-- SELECT DISTINCT
--     id_cliente,
--     nome_cliente,
--     sobrenome_cliente,
--     email_cliente,
--     sexo_cliente,
--     telefone_cliente
-- FROM staging_pecegames
-- WHERE id_cliente IS NOT NULL
--   AND id_cliente NOT IN (SELECT id_cliente FROM dim_cliente);

-- INSERT INTO dim_genero (nome_genero)
-- SELECT DISTINCT genero
-- FROM staging_pecegames
-- WHERE genero IS NOT NULL
--   AND genero NOT IN (SELECT nome_genero FROM dim_genero);

-- INSERT INTO dim_plataforma (nome_plataforma)
-- SELECT DISTINCT plataforma
-- FROM staging_pecegames
-- WHERE plataforma IS NOT NULL
--   AND plataforma NOT IN (SELECT nome_plataforma FROM dim_plataforma);

-- INSERT INTO dim_publicadora (nome_publicadora)
-- SELECT DISTINCT publicadora
-- FROM staging_pecegames
-- WHERE publicadora IS NOT NULL
--   AND publicadora NOT IN (SELECT nome_publicadora FROM dim_publicadora);

-- INSERT INTO dim_jogo (nome_jogo, id_genero, id_plataforma, id_publicadora, ano_lancamento)
-- SELECT DISTINCT
--     s.nome_jogo,
--     g.id_genero,
--     p.id_plataforma,
--     pub.id_publicadora,
--     s.ano_lancamento
-- FROM staging_pecegames s
-- JOIN dim_genero g ON s.genero = g.nome_genero
-- JOIN dim_plataforma p ON s.plataforma = p.nome_plataforma
-- JOIN dim_publicadora pub ON s.publicadora = pub.nome_publicadora
-- WHERE s.nome_jogo IS NOT NULL
--   AND s.nome_jogo NOT IN (SELECT nome_jogo FROM dim_jogo);

-- INSERT INTO dim_tempo (ano, trimestre)
-- SELECT DISTINCT
--     ano_lancamento,
--     CASE
--         WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 1 AND 3 THEN 1
--         WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 4 AND 6 THEN 2
--         WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 7 AND 9 THEN 3
--         ELSE 4
--     END AS trimestre
-- FROM staging_pecegames
-- WHERE ano_lancamento IS NOT NULL
--   AND ano_lancamento NOT IN (SELECT ano FROM dim_tempo);

-- 2. Carregamento da Tabela Fato------------------------------------------------

-- INSERT INTO fato_vendas_jogos (
--     vendas_na,
--     vendas_eu,
--     vendas_jp,
--     vendas_outros,
--     vendas_globais,
--     rank_game,
--     id_jogo,
--     id_cliente,
--     id_tempo
-- )
-- SELECT
--     s.vendas_na,
--     s.vendas_eu,
--     s.vendas_jp,
--     s.vendas_outros,
--     s.vendas_globais,
--     s.rank_game,
--     j.id_jogo,
--     c.id_cliente,
--     t.id_tempo
-- FROM staging_pecegames s
-- JOIN dim_cliente c ON s.id_cliente = c.id_cliente
-- JOIN dim_genero g ON s.genero = g.nome_genero
-- JOIN dim_plataforma p ON s.plataforma = p.nome_plataforma
-- JOIN dim_publicadora pub ON s.publicadora = pub.nome_publicadora
-- JOIN dim_jogo j ON s.nome_jogo = j.nome_jogo
-- JOIN dim_tempo t ON s.ano_lancamento = t.ano;

-- Criação das tabelas para Conserto ----------------------------------------------------
-- CREATE TABLE dim_servico (
--     id_servico SERIAL PRIMARY KEY,
--     tipo_servico VARCHAR(100),      -- Ex: Substituição de peça, Revisão geral, Atualização de firmware
--     descricao_servico TEXT
-- );

-- CREATE TABLE dim_console (
--     id_console SERIAL PRIMARY KEY,
--     nome_console VARCHAR(100) UNIQUE,
--     fabricante VARCHAR(100),
--     ano_lancamento INT
-- );

-- CREATE TABLE fato_consertos (
--     id_conserto SERIAL PRIMARY KEY,
--     id_cliente INT REFERENCES dim_cliente(id_cliente),
--     id_console INT REFERENCES dim_console(id_console),
--     id_tempo INT REFERENCES dim_tempo(id_tempo),
--     id_servico INT REFERENCES dim_servico(id_servico),
--     valor_conserto NUMERIC(8,2),
--     tempo_execucao_dias INT,
--     garantia_meses INT
-- );

-- SELECT * FROM dim_console;

-- INSERT INTO dim_console (nome_console, fabricante, ano_lancamento)
-- VALUES 
-- ('PS2', 'Sony', 2000),
-- ('Xbox 360', 'Microsoft', 2005),
-- ('Nintendo Wii', 'Nintendo', 2006);

-- SELECT * FROM dim_servico;

-- INSERT INTO dim_servico (tipo_servico, descricao_servico)
-- VALUES 
-- ('Troca de Peças', 'Substituição de peças danificadas do console'),
-- ('Atualização de Software', 'Atualização do sistema operacional do console'),
-- ('Limpeza Interna', 'Serviço de limpeza interna e remoção de poeira'),
-- ('Reparo na Placa', 'Correção de defeitos na placa mãe do console');



-- -- Exemplo de inserção na fato_consertos
-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (1, 2, 1, 1, 300.00, 5, 6);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (1, 1, 1, 1, 250.00, 3, 6);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (2, 2, 2, 2, 180.00, 2, 3);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (3, 1, 3, 3, 120.00, 1, 1);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (4, 3, 4, 4, 450.00, 5, 12);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (2, 2, 2, 1, 300.00, 4, 6);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (3, 3, 3, 2, 200.00, 2, 3);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (5, 2, 1, 1, 300.00, 2, 6);

-- INSERT INTO fato_consertos (id_cliente, id_console, id_tempo, id_servico, valor_conserto, tempo_execucao_dias, garantia_meses)
-- VALUES (6, 1, 3, 4, 200.00, 2, 3);


-- SELECT * FROM fato_consertos;

-- Convertendo o numero de vendas para valores em milhoes

-- ALTER TABLE fato_vendas_jogos
-- ALTER COLUMN vendas_na TYPE NUMERIC(15,2),
-- ALTER COLUMN vendas_eu TYPE NUMERIC(15,2),
-- ALTER COLUMN vendas_jp TYPE NUMERIC(15,2),
-- ALTER COLUMN vendas_outros TYPE NUMERIC(15,2),
-- ALTER COLUMN vendas_globais TYPE NUMERIC(15,2);


-- UPDATE fato_vendas_jogos
-- SET 
--     vendas_na = vendas_na * 1000000,
--     vendas_eu = vendas_eu * 1000000,
--     vendas_jp = vendas_jp * 1000000,
--     vendas_outros = vendas_outros * 1000000,
--     vendas_globais = vendas_globais * 1000000;

-- SELECT * FROM fato_vendas_jogos;




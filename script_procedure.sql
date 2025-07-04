------------------------Criação e teste do Procedure --------------------------------------
-- CREATE OR REPLACE PROCEDURE calcular_media_vendas_por_plataforma()
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     plataforma_nome TEXT;
--     media_vendas NUMERIC(10,2);
--     cur_plataforma REFCURSOR;
--     genero_moda TEXT;
--     query TEXT;
-- BEGIN
--     query := '
--         SELECT p.nome_plataforma, ROUND(AVG(f.vendas_globais), 0)
--         FROM fato_vendas_jogos f
--         JOIN dim_jogo j ON f.id_jogo = j.id_jogo
--         JOIN dim_plataforma p ON j.id_plataforma = p.id_plataforma
--         GROUP BY p.nome_plataforma
--     ';
--     OPEN cur_plataforma FOR EXECUTE query;
--     RAISE NOTICE 'Média de vendas e genero mais vendido por plataforma:';
--     LOOP
--         FETCH cur_plataforma INTO plataforma_nome, media_vendas;
--         EXIT WHEN NOT FOUND;
--         -- Calcula a moda dos gêneros para a plataforma atual
--         SELECT g.nome_genero INTO genero_moda
--         FROM fato_vendas_jogos f2
--         JOIN dim_jogo j2 ON f2.id_jogo = j2.id_jogo
--         JOIN dim_plataforma p2 ON j2.id_plataforma = p2.id_plataforma
--         JOIN dim_genero g ON j2.id_genero = g.id_genero
--         WHERE p2.nome_plataforma = plataforma_nome
--         GROUP BY g.nome_genero
--         ORDER BY COUNT(*) DESC
--         LIMIT 1;
--         RAISE NOTICE 'Plataforma: % | Média de Vendas: % | Gênero mais popular: %', plataforma_nome, TO_CHAR(media_vendas, 'FM9G999G999'), genero_moda;   --TO_CHAR para mostrar o separador de milhar
--     END LOOP;
--     CLOSE cur_plataforma;
-- END;
-- $$

-- Testando
CALL calcular_media_vendas_por_plataforma();


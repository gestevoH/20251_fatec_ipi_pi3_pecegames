CREATE OR REPLACE PROCEDURE calcular_media_vendas_por_plataforma()
LANGUAGE plpgsql
AS $$
DECLARE
    plataforma_nome TEXT;
    media_vendas NUMERIC(10,2);
    cur_plataforma REFCURSOR;
    query TEXT;
BEGIN
    query := '
        SELECT p.nome_plataforma, AVG(f.vendas_globais)
        FROM fato_vendas_jogos f
        JOIN dim_jogo j ON f.id_jogo = j.id_jogo
        JOIN dim_plataforma p ON j.id_plataforma = p.id_plataforma
        GROUP BY p.nome_plataforma
    ';
    OPEN cur_plataforma FOR EXECUTE query;
    RAISE NOTICE 'Média de vendas por plataforma:';
    LOOP
        FETCH cur_plataforma INTO plataforma_nome, media_vendas;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Plataforma: %, Média de Vendas: %', plataforma_nome, media_vendas;
    END LOOP;
    CLOSE cur_plataforma;
END;
$$

CALL calcular_media_vendas_por_plataforma();

-- ----------------------------Criação e teste do Trigger---------------------------------------------
-- CREATE TABLE log_consertos(
--     id_log SERIAL PRIMARY KEY,
--     id_conserto INT,
--     data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     descricao TEXT
-- );

-- CREATE OR REPLACE FUNCTION registrar_log_conserto()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO log_consertos (id_conserto, descricao)
--     VALUES (NEW.id_conserto, 'Novo conserto registrado para o cliente ID ' || NEW.id_cliente);
--     RETURN NEW;
-- END;
-- $$

-- CREATE TRIGGER tg_log_consertos
-- AFTER INSERT ON fato_consertos
-- FOR EACH ROW
-- EXECUTE FUNCTION registrar_log_conserto();

-- Testando 
SELECT * FROM log_consertos;
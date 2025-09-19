-- #############################################
-- ETAPA 1: APAGAR VIEWS, TABELAS E PROCEDURES EXISTENTES
-- #############################################

-- Apagar views
DROP VIEW IF EXISTS dw_performance_futebol.avaliacao_geral_das_equipes CASCADE;
DROP VIEW IF EXISTS dw_performance_futebol.avaliacao_condicionamento_jogadores CASCADE;
DROP VIEW IF EXISTS dw_performance_futebol.desempenho_dos_jogadores CASCADE;
DROP VIEW IF EXISTS dw_performance_futebol.jogadores_mais_faltosos_da_liga CASCADE;

-- Apagar tabelas de fatos
DROP TABLE IF EXISTS dw_performance_futebol.Fato_Desempenho_Individual CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Fato_Evento_Partida CASCADE;

-- Apagar tabelas de dimensão
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Partida CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Arbitragem CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Tempo CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Jogador CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Tipo_Evento CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Estadio CASCADE;
DROP TABLE IF EXISTS dw_performance_futebol.Dim_Equipe CASCADE;

-- Apagar stored procedures
DROP PROCEDURE IF EXISTS dw_performance_futebol.popular_dim_equipe;
DROP PROCEDURE IF EXISTS dw_performance_futebol.popular_dim_estadio;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_dados_arbitragem;
DROP PROCEDURE IF EXISTS dw_performance_futebol.gerar_dim_tempo;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_num_eventos;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_dados_jogadores;
DROP PROCEDURE IF EXISTS dw_performance_futebol.popular_posicao_jogador;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_dados_dim_partida;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_dados_fato_eventos_partida;
DROP PROCEDURE IF EXISTS dw_performance_futebol.inserir_dados_fato_desempenho_individual;


-- #############################################
-- ETAPA 2: CRIAÇÃO DAS TABELAS DE DIMENSÃO
-- #############################################
create schema dw_performance_futebol authorization dsa; 
-- Tabela Dim_Equipe
CREATE TABLE dw_performance_futebol.Dim_Equipe (
    ID_Equipe INT PRIMARY KEY,
    Nome_Equipe VARCHAR(100),
    Cidade VARCHAR(100),
    Estado VARCHAR(100)
);

-- Tabela Dim_Estadio
CREATE TABLE dw_performance_futebol.Dim_Estadio (
    ID_Estadio INT PRIMARY KEY,
    Nome_Estadio VARCHAR(100),
    Tipo_Campo VARCHAR(50),
    Dimensao VARCHAR(50),
    Cidade VARCHAR(100),
    Estado VARCHAR(100)
);

-- Tabela Dim_Tipo_Evento
CREATE TABLE dw_performance_futebol.Dim_Tipo_Evento (
    ID_Tipo_Evento INT PRIMARY KEY,
    Descricao_Evento VARCHAR(100)
);

-- Tabela Dim_Jogador
CREATE TABLE dw_performance_futebol.Dim_Jogador (
    ID_Jogador INT PRIMARY KEY,
    Nome_Jogador VARCHAR(100),
    Idade INT,
    Peso DECIMAL(5, 2),
    Altura DECIMAL(5, 2),
    Porc_Gordura DECIMAL(5, 2),
    Porcent_Musculo DECIMAL(5, 2),
    ID_Equipe INT,
    Posicao VARCHAR(50),
    FOREIGN KEY (ID_Equipe) REFERENCES dw_performance_futebol.Dim_Equipe(ID_Equipe)
);

-- Tabela Dim_Tempo
CREATE TABLE dw_performance_futebol.Dim_Tempo (
    ID_Tempo BIGINT PRIMARY KEY,
    Data_Completa TIMESTAMP,
    Dia INT,
    Mes INT,
    Ano INT,
    Dia_Semana VARCHAR(20),
    Hora INT,
    Minuto INT,
    Trimestre INT,
    Semestre INT
);

-- Tabela Dim_Arbitragem
CREATE TABLE dw_performance_futebol.Dim_Arbitragem (
    ID_Arbitragem INT PRIMARY KEY,
    Nome_Juiz VARCHAR(100),
    Nome_Bandeira1 VARCHAR(100),
    Nome_Bandeira2 VARCHAR(100)
);

-- Tabela Dim_Partida
CREATE TABLE dw_performance_futebol.Dim_Partida (
    ID_Partida INT PRIMARY KEY,
    ID_Data BIGINT,
    ID_Estadio INT,
    ID_Equipe_Local INT,
    ID_Equipe_Visitante INT,
    ID_Arbitragem INT,
    Clima VARCHAR(50),
    CONSTRAINT fk_partida_data FOREIGN KEY (ID_Data) REFERENCES dw_performance_futebol.Dim_Tempo(ID_Tempo),
    CONSTRAINT fk_partida_estadio FOREIGN KEY (ID_Estadio) REFERENCES dw_performance_futebol.Dim_Estadio(ID_Estadio),
    CONSTRAINT fk_partida_equipe_local FOREIGN KEY (ID_Equipe_Local) REFERENCES dw_performance_futebol.Dim_Equipe(ID_Equipe),
    CONSTRAINT fk_partida_equipe_visitante FOREIGN KEY (ID_Equipe_Visitante) REFERENCES dw_performance_futebol.Dim_Equipe(ID_Equipe),
    CONSTRAINT fk_partida_arbitragem FOREIGN KEY (ID_Arbitragem) REFERENCES dw_performance_futebol.Dim_Arbitragem(ID_Arbitragem)
);


-- #############################################
-- ETAPA 3: CRIAÇÃO DAS TABELAS DE FATO
-- #############################################

-- Tabela Fato_Evento_Partida
CREATE TABLE dw_performance_futebol.Fato_Evento_Partida (
    ID_Evento_Partida BIGSERIAL PRIMARY KEY,
    ID_Partida INT,
    ID_Jogador INT,
    ID_Time INT,
    ID_Tipo_Evento INT,
    ID_Data_Hora_Evento BIGINT,
    Minuto_Evento INT,
    Resultado_Evento VARCHAR(50),
    CONSTRAINT fk_eventos_partida FOREIGN KEY (ID_Partida) REFERENCES dw_performance_futebol.Dim_Partida(ID_Partida),
    CONSTRAINT fk_eventos_jogador FOREIGN KEY (ID_Jogador) REFERENCES dw_performance_futebol.Dim_Jogador(ID_Jogador),
    CONSTRAINT fk_eventos_time FOREIGN KEY (ID_Time) REFERENCES dw_performance_futebol.Dim_Equipe(ID_Equipe),
    CONSTRAINT fk_eventos_tipo FOREIGN KEY (ID_Tipo_Evento) REFERENCES dw_performance_futebol.Dim_Tipo_Evento(ID_Tipo_Evento),
    CONSTRAINT fk_eventos_data_hora FOREIGN KEY (ID_Data_Hora_Evento) REFERENCES dw_performance_futebol.Dim_Tempo(ID_Tempo)
);

-- Tabela Fato_Desempenho_Individual
CREATE TABLE dw_performance_futebol.Fato_Desempenho_Individual (
    ID_Desempenho BIGSERIAL PRIMARY KEY,
    ID_Partida INT,
    ID_Jogador INT,
    ID_Time INT,
    Dist_Percorrida_Defesa DECIMAL(10, 2),
    Dist_Percorrida_Ataque DECIMAL(10, 2),
    Roubadas_Bola INT,
    Perda_Posse INT,
    Numero_Chutes_Meta INT,
    Numero_Chutes INT,
    Numero_Gols_Feitos INT,
    Numero_Faltas_Cometidas INT,
    Numero_Faltas_Sofridas INT,
    Tempo_Jogado_Minutos INT,
    CONSTRAINT fk_desempenho_partida FOREIGN KEY (ID_Partida) REFERENCES dw_performance_futebol.Dim_Partida(ID_Partida),
    CONSTRAINT fk_desempenho_jogador FOREIGN KEY (ID_Jogador) REFERENCES dw_performance_futebol.Dim_Jogador(ID_Jogador),
    CONSTRAINT fk_desempenho_time FOREIGN KEY (ID_Time) REFERENCES dw_performance_futebol.Dim_Equipe(ID_Equipe)
);


-- #############################################
-- ETAPA 4: CRIAÇÃO DAS STORED PROCEDURES
-- #############################################

-- Stored Procedure para Dim_Equipe
create or replace procedure dw_performance_futebol.popular_dim_equipe()
language plpgsql
as $$
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Equipe RESTART IDENTITY CASCADE;

    INSERT INTO dw_performance_futebol.Dim_Equipe(id_equipe, nome_equipe, cidade, estado) VALUES
    (1,'Corinthians','São Paulo', 'SP'),
    (2,'São Paulo','São Paulo', 'SP'),
    (3,'Santos','São Paulo', 'SP'),
    (4,'Palmeiras','São Paulo', 'SP'),
    (5,'Botafogo','Rio de Janeiro', 'RJ'),
    (6,'Vasco','Rio de Janeiro', 'RJ'),
    (7,'Fluminense','Rio de Janeiro', 'RJ'),
    (8,'Flamengo','Rio de Janeiro', 'RJ'),
    (9,'Atlético','Belo Horizonte', 'MG'),
    (10,'Cruzeiro','Belo Horizonte', 'MG'),
    (11,'Internacional','Porto Alegre', 'RS'),
    (12,'Grêmio','Porto Alegre', 'RS');
END;
$$;

-- Stored Procedure para Dim_Estadio
create or replace procedure dw_performance_futebol.popular_dim_estadio()
language plpgsql
as $$
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Estadio RESTART IDENTITY CASCADE;

    INSERT INTO dw_performance_futebol.Dim_Estadio(id_estadio, nome_estadio, tipo_campo, dimensao, cidade, estado) VALUES
    (1, 'Neo Quimica Arena', 'grama', 'oficial','São Paulo', 'SP'),
    (2, 'Morumbi', 'grama', 'oficial', 'São Paulo', 'SP'),
    (3, 'Vila Belmiro', 'grama', 'oficial', 'Santos', 'SP'),
    (4, 'Alianz Arena', 'sintético', 'oficial', 'São Paulo', 'SP'),
    (5, 'Engenhão', 'sintético', 'oficial', 'Rio de Janeiro', 'RJ'),
    (6, 'São Januário', 'grama', 'oficial', 'Rio de Janeiro', 'RJ'),
    (7, 'Laranjeiras', 'grama', 'oficial', 'Rio de Janeiro', 'RJ'),
    (8, 'Gávea', 'grama', 'não-oficial', 'Rio de Janeiro', 'RJ'),
    (9, 'Arena MRV', 'grama', 'oficial', 'Belo Horizonte', 'MG'),
    (10,'Mineirão', 'grama', 'oficial', 'Belo Horizonte', 'MG'),
    (11,'Beira Rio', 'grama', 'oficial', 'Porto Alegre', 'RS'),
    (12,'Arena do Grêmio', 'grama', 'oficial', 'Porto Alegre', 'RS');
END;
$$;

-- Stored Procedure para Dim_Arbitragem
create or replace procedure dw_performance_futebol.inserir_dados_arbitragem()
language plpgsql
as $$
DECLARE
    nomes_possiveis VARCHAR[]:=ARRAY[
        'Ricardo','Alex', 'Rodrigo', 'Jean', 'Eduardo', 'Cláudio', 'Daniel', 'Marcos',
        'Rafael', 'Felipe', 'Bruno', 'Gustavo', 'Lucas', 'Thiago', 'Matheus', 'Vinicius',
        'Leonardo', 'André', 'Pedro', 'Paulo', 'Marcelo', 'Carlos', 'Fernando', 'Guilherme',
        'Hugo', 'Ian', 'Jonas', 'Kleber', 'Luiz', 'Miguel', 'Natan', 'Otavio', 'Samuel',
        'Tadeu', 'Victor', 'Wiliam', 'Xavier', 'Yuri', 'Zeca', 'Caio', 'Fabiano', 'José', 'João', 'Zé'
    ];
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Arbitragem RESTART IDENTITY CASCADE;
    
    INSERT INTO dw_performance_futebol.dim_arbitragem(
        id_arbitragem,
        nome_juiz,
        nome_bandeira1,
        nome_bandeira2
    )
    SELECT
        (ROW_NUMBER() OVER ()) AS id_arbitragem,
        juiz.nome AS nome_juiz,
        bandeira1.nome AS nome_bandeira1,
        bandeira2.nome AS nome_bandeira2
    FROM (
        SELECT unnest(nomes_possiveis) AS nome
    ) AS juiz
    CROSS JOIN (
        SELECT unnest(nomes_possiveis) AS nome
    ) AS bandeira1
    CROSS JOIN (
        SELECT unnest(nomes_possiveis) AS nome
    ) AS bandeira2
    WHERE
        juiz.nome != bandeira1.nome AND juiz.nome != bandeira2.nome AND bandeira1.nome != bandeira2.nome
    ORDER BY RANDOM()
    LIMIT 20;

END;
$$;

-- Stored Procedure para Dim_Tempo
create or replace procedure dw_performance_futebol.gerar_dim_tempo()
language plpgsql
as $$
DECLARE
    data_inicio TIMESTAMP := '2025-01-01 00:00:00';
    data_fim TIMESTAMP := '2025-12-31 23:59:59';
    v_current_time TIMESTAMP;
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Tempo RESTART IDENTITY CASCADE;
    
    v_current_time := data_inicio;
    
    WHILE v_current_time <= data_fim LOOP
        INSERT INTO dw_performance_futebol.Dim_Tempo (
            ID_Tempo,
            Data_Completa,
            Ano,
            Mes,
            Dia,
            Dia_Semana,
            Hora,
            Minuto,
            Trimestre,
            Semestre
        ) VALUES (
            CAST(TO_CHAR(v_current_time, 'YYYYMMDDHH24MISS') AS BIGINT),
            v_current_time,
            EXTRACT(YEAR FROM v_current_time),
            EXTRACT(MONTH FROM v_current_time),
            EXTRACT(DAY FROM v_current_time),
            TO_CHAR(v_current_time, 'Day'),
            EXTRACT(HOUR FROM v_current_time),
            EXTRACT(MINUTE FROM v_current_time),
            EXTRACT(QUARTER FROM v_current_time),
            CASE 
                WHEN EXTRACT(MONTH FROM v_current_time) <= 6 THEN 1
                ELSE 2
            END
        );
        v_current_time := v_current_time + interval '1 minute'; -- Corrigido para minutos
    END LOOP;
END;
$$;

-- Script para inserir tipo de eventos
create or replace procedure dw_performance_futebol.inserir_num_eventos()
language plpgsql
as $$
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Tipo_Evento RESTART IDENTITY CASCADE;

    INSERT INTO dw_performance_futebol.Dim_Tipo_Evento (
        ID_Tipo_Evento,
        Descricao_Evento
    ) VALUES
        (1, 'Gol'),
        (2, 'Falta'),
        (3, 'Cartão Amarelo'),
        (4, 'Cartão Vermelho'),
        (5, 'Substituição'),
        (6, 'Chute'),
        (7, 'Passe'),
        (8, 'Perda de Posse'),
        (9, 'Ganho de Posse'),
        (10, 'Defesa do Goleiro'),
        (11, 'Penalti');
END;
$$;

-- Stored Procedure para Dim_Jogador
create or replace procedure dw_performance_futebol.inserir_dados_jogadores()
language plpgsql
as $$
DECLARE
    nomes_possiveis VARCHAR[]:=ARRAY['José','João', 'Zé', 'Jão', 'Manoel', 'Mané', 'Joãonesson', 'Josenesson', 'Manuelsson', 'Frederico', 'Josias', 'Davi', 'Horácio', 'Caio','Fabiano', 'Ricardo', 'Alex', 'Rodrigo', 'Jean', 'Eduardo', 'Cláudio'];
    sobrenomes_possiveis VARCHAR[]:=ARRAY['Silva', 'Souza', 'Sousa', 'Santos', 'da Silva', 'dos Santos', 'de Sousa', 'de Souza'];
    equipe_id INT;
    jogador_id INT := 1;
    nome_selecionado VARCHAR(100);
    sobrenome_selecionado VARCHAR(100);
    nome_index INT;
    sobrenome_index INT;
    idade INT;
    peso DECIMAL (5,2);
    altura DECIMAL (5,2);
    gordura DECIMAL (5,2);
    musculo DECIMAL (5,2);
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Jogador RESTART IDENTITY CASCADE;

    FOR equipe_id IN SELECT ID_Equipe FROM dw_performance_futebol.Dim_Equipe LOOP
        FOR i IN 1..22 LOOP
            nome_index := FLOOR(RANDOM() * array_length(nomes_possiveis, 1)) + 1;
            sobrenome_index := FLOOR(RANDOM() * array_length(sobrenomes_possiveis, 1)) + 1;
            nome_selecionado := nomes_possiveis[nome_index];
            sobrenome_selecionado := sobrenomes_possiveis[sobrenome_index];
            idade = FLOOR(RANDOM()*(45 - 16 + 1) + 16);
            peso = ROUND(CAST(RANDOM() * (110 - 65) + 65 AS NUMERIC), 1);
            altura = ROUND(CAST(RANDOM() * (200 - 155) + 155 AS NUMERIC), 1);
            gordura = ROUND(CAST(RANDOM() * (22 - 6) + 6 AS NUMERIC), 1);
            musculo = ROUND(CAST(RANDOM() * (59 - 44) + 44 AS NUMERIC), 1);
            
            INSERT INTO dw_performance_futebol.Dim_Jogador(
                id_jogador,
                nome_jogador,
                idade,
                peso,
                altura,
                porc_gordura,
                porcent_musculo,
                id_equipe
            ) VALUES (
                jogador_id,
                nome_selecionado || ' ' || sobrenome_selecionado,
                idade,
                peso,
                altura,
                gordura,
                musculo,
                equipe_id -- Adicionado ID_Equipe
            );
            jogador_id := jogador_id + 1; 
        END LOOP;
    END LOOP;
END;
$$;

-- Stored Procedure para popular Posicao do jogador
create or replace procedure dw_performance_futebol.popular_posicao_jogador()
language plpgsql
as $$
DECLARE
    v_jogador RECORD;
    v_posicao VARCHAR(50);
BEGIN
    FOR v_jogador IN SELECT ID_Jogador FROM dw_performance_futebol.Dim_Jogador ORDER BY ID_Jogador LOOP
        IF (v_jogador.ID_Jogador % 264) < 12 THEN
            v_posicao := 'Goleiro';
        ELSIF (v_jogador.ID_Jogador % 264) < 60 THEN
            v_posicao := 'Zagueiro';
        ELSIF (v_jogador.ID_Jogador % 264) < 108 THEN
            v_posicao := 'Lateral';
        ELSIF (v_jogador.ID_Jogador % 264) < 168 THEN
            v_posicao := 'Volante';
        ELSIF (v_jogador.ID_Jogador % 264) < 228 THEN
            v_posicao := 'Meia';
        ELSE
            v_posicao := 'Atacante';
        END IF;

        UPDATE dw_performance_futebol.Dim_Jogador
        SET Posicao = v_posicao
        WHERE ID_Jogador = v_jogador.ID_Jogador;
    END LOOP;
END;
$$;

-- Stored Procedure para Dim_Partida
create or replace procedure dw_performance_futebol.inserir_dados_dim_partida()
language plpgsql
as $$
DECLARE
    climas VARCHAR[]:= ARRAY['Ensolarado', 'Nublado', 'Chuvoso', 'Nevando', 'Granizo'];
    partida_id INT := 1;
    clima_sorteado VARCHAR(50);
    clima_index INT;
    r RECORD;
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Dim_Partida RESTART IDENTITY CASCADE;
    
    FOR r IN (
        SELECT
            a.id_equipe AS id_equipe_local,
            b.id_equipe AS id_equipe_visitante
        FROM
            dw_performance_futebol.dim_equipe a
        CROSS JOIN
            dw_performance_futebol.dim_equipe b
        WHERE
            a.id_equipe < b.id_equipe
    ) LOOP
        clima_index := FLOOR(RANDOM() * array_length(climas, 1)) + 1;
        clima_sorteado := climas[clima_index];

        INSERT INTO dw_performance_futebol.Dim_Partida(
            id_partida,
            id_equipe_local,
            id_equipe_visitante,
            id_estadio,
            id_arbitragem,
            id_data,
            clima
        )
        SELECT
            partida_id,
            r.id_equipe_local,
            r.id_equipe_visitante,
            r.id_equipe_local AS id_estadio,
            (SELECT id_arbitragem FROM dw_performance_futebol.dim_arbitragem ORDER BY RANDOM() LIMIT 1)::INT AS id_arbitragem,
            (SELECT id_tempo FROM dw_performance_futebol.dim_tempo ORDER BY RANDOM() LIMIT 1)::BIGINT AS id_data,
            clima_sorteado;

        partida_id := partida_id + 1;
    END LOOP;
END;
$$;


-- Stored Procedure para Fato_Evento_Partida
CREATE OR REPLACE PROCEDURE dw_performance_futebol.inserir_dados_fato_evento_partida()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    num_eventos INT;
    v_minuto_evento INT;
    v_id_equipe_evento INT;
    v_id_jogador_evento INT;
    v_id_tipo_evento INT;
    v_id_data_hora_evento BIGINT;
    v_id_data_partida BIGINT;
    resultados_chute VARCHAR[] := ARRAY['no gol', 'para fora', 'bloqueado'];
    resultados_passe VARCHAR[] := ARRAY['certo', 'errado'];
    resultados_penalti VARCHAR[] := ARRAY['convertido', 'perdido'];
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Fato_Evento_Partida CASCADE;

    FOR r IN SELECT * FROM dw_performance_futebol.Dim_Partida ORDER BY id_partida LOOP
        v_id_data_partida := r.id_data;

        num_eventos := FLOOR(RANDOM() * 51) + 50;

        FOR i IN 1..num_eventos LOOP
            v_minuto_evento := FLOOR(RANDOM() * 90) + 1;

            IF RANDOM() > 0.5 THEN
                v_id_equipe_evento := r.id_equipe_local;
            ELSE
                v_id_equipe_evento := r.id_equipe_visitante;
            END IF;

            v_id_jogador_evento := (SELECT id_jogador FROM dw_performance_futebol.Dim_Jogador WHERE id_equipe = v_id_equipe_evento ORDER BY RANDOM() LIMIT 1);
            v_id_tipo_evento := (SELECT id_tipo_evento FROM dw_performance_futebol.Dim_Tipo_Evento ORDER BY RANDOM() LIMIT 1);
            
            -- Corrigido: Seleciona um momento dentro do jogo
            v_id_data_hora_evento := (
                SELECT id_tempo FROM dw_performance_futebol.Dim_Tempo
                WHERE data_completa >= (SELECT data_completa FROM dw_performance_futebol.Dim_Tempo WHERE id_tempo = v_id_data_partida)
                AND data_completa < (SELECT data_completa FROM dw_performance_futebol.Dim_Tempo WHERE id_tempo = v_id_data_partida) + INTERVAL '90 minutes'
                ORDER BY RANDOM() LIMIT 1
            );
            
            DECLARE
                resultado_evento VARCHAR(50);
            BEGIN
                CASE v_id_tipo_evento
                    WHEN 1 THEN resultado_evento := 'certo';
                    WHEN 6 THEN resultado_evento := (SELECT unnest(resultados_chute) ORDER BY RANDOM() LIMIT 1);
                    WHEN 7 THEN resultado_evento := (SELECT unnest(resultados_passe) ORDER BY RANDOM() LIMIT 1);
                    WHEN 11 THEN resultado_evento := (SELECT unnest(resultados_penalti) ORDER BY RANDOM() LIMIT 1);
                    ELSE resultado_evento := NULL;
                END CASE;
            
                INSERT INTO dw_performance_futebol.Fato_Evento_Partida (
                    ID_Partida,
                    ID_Jogador,
                    ID_Time,
                    ID_Tipo_Evento,
                    ID_Data_Hora_Evento,
                    Minuto_Evento,
                    Resultado_Evento
                ) VALUES (
                    r.id_partida,
                    v_id_jogador_evento,
                    v_id_equipe_evento,
                    v_id_tipo_evento,
                    v_id_data_hora_evento,
                    v_minuto_evento,
                    resultado_evento
                );
            END;
        END LOOP;
    END LOOP;
END;
$$;

-- Stored Procedure para Fato_Desempenho_Individual
create or replace procedure dw_performance_futebol.inserir_dados_fato_desempenho_individual()
language plpgsql
as $$
BEGIN
    TRUNCATE TABLE dw_performance_futebol.Fato_Desempenho_Individual CASCADE;
    
    INSERT INTO dw_performance_futebol.Fato_Desempenho_Individual (
        ID_Partida,
        ID_Jogador,
        ID_Time,
        Dist_Percorrida_Defesa,
        Dist_Percorrida_Ataque,
        Roubadas_Bola,
        Perda_Posse,
        Numero_Chutes_Meta,
        Numero_Chutes,
        Numero_Gols_Feitos,
        Numero_Faltas_Cometidas,
        Numero_Faltas_Sofridas,
        Tempo_Jogado_Minutos
    )
    SELECT
        fep.ID_Partida,
        fep.ID_Jogador,
        fep.ID_Time,
        TRUNC(CAST(RANDOM() * 3000 AS DECIMAL), 2) AS Dist_Percorrida_Defesa,
        TRUNC(CAST(RANDOM() * 3000 AS DECIMAL), 2) AS Dist_Percorrida_Ataque,
        FLOOR(RANDOM() * 5) AS Roubadas_Bola,
        FLOOR(RANDOM() * 5) AS Perda_Posse,
        SUM(CASE WHEN fep.ID_Tipo_Evento = 6 AND fep.Resultado_Evento = 'no gol' THEN 1 ELSE 0 END) AS Numero_Chutes_Meta,
        COUNT(CASE WHEN fep.ID_Tipo_Evento IN (1, 6) THEN 1 ELSE NULL END) AS Numero_Chutes,
        COUNT(CASE WHEN fep.ID_Tipo_Evento = 1 THEN 1 ELSE NULL END) AS Numero_Gols_Feitos,
        COUNT(CASE WHEN fep.ID_Tipo_Evento = 2 THEN 1 ELSE NULL END) AS Numero_Faltas_Cometidas,
        COUNT(CASE WHEN fep.ID_Tipo_Evento = 2 AND fep.ID_Time != dp.id_equipe_local AND fep.ID_Time != dp.id_equipe_visitante THEN 1 ELSE NULL END) AS Numero_Faltas_Sofridas,
        90 AS Tempo_Jogado_Minutos
    FROM
        dw_performance_futebol.Fato_Evento_Partida fep
    JOIN
        dw_performance_futebol.Dim_Partida dp ON fep.ID_Partida = dp.ID_Partida
    WHERE
        fep.ID_Jogador IS NOT NULL
    GROUP BY
        fep.ID_Partida,
        fep.ID_Jogador,
        fep.ID_Time;
END;
$$;

-- #############################################
-- ETAPA 5: EXECUÇÃO DAS PROCEDURES PARA POPULAR O DW
-- #############################################

DO $$
BEGIN
    RAISE NOTICE 'Iniciando a populacao das dimensoes...';
    CALL dw_performance_futebol.popular_dim_equipe();
    CALL dw_performance_futebol.popular_dim_estadio();
    CALL dw_performance_futebol.inserir_dados_arbitragem();
    CALL dw_performance_futebol.gerar_dim_tempo();
    CALL dw_performance_futebol.inserir_dados_jogadores();
    CALL dw_performance_futebol.inserir_num_eventos();
    CALL dw_performance_futebol.popular_posicao_jogador();
    CALL dw_performance_futebol.inserir_dados_dim_partida();
    
    RAISE NOTICE 'Dimensoes populadas. Iniciando populacao das tabelas de fato...';
    CALL dw_performance_futebol.inserir_dados_fato_evento_partida();
    CALL dw_performance_futebol.inserir_dados_fato_desempenho_individual();
    
    RAISE NOTICE 'Populacao completa. Todas as tabelas estao prontas para analise.';
END $$;


-- #############################################
-- ETAPA 6: CRIAÇÃO DAS VIEWS PARA ANÁLISE E BI
-- #############################################

CREATE OR REPLACE VIEW dw_performance_futebol.avaliacao_geral_das_equipes AS
SELECT
    de.ID_Equipe,
    de.Nome_Equipe,
    COUNT(DISTINCT fdi.ID_Partida) AS Total_Partidas,
    SUM(fdi.Numero_Gols_Feitos) AS Total_Gols_Feitos,
    round(cast(SUM(fdi.Numero_Gols_Feitos)as decimal)/COUNT(DISTINCT fdi.ID_Partida),2) as Media_Gols_Partida,
    SUM(gols_sofridos.Gols_Sofridos) AS Total_Gols_Sofridos,
    round(cast(SUM(gols_Sofridos.Gols_Sofridos)as decimal)/COUNT(DISTINCT fdi.ID_Partida),2) as Media_Gols_Sofridos_Partida,
    SUM(fdi.Numero_Faltas_Cometidas) AS Total_Faltas_Cometidas,
    SUM(fdi.Numero_Chutes) AS Total_Chutes,
    SUM(fdi.Numero_Chutes_Meta) AS Total_Chutes_na_Meta,
    SUM(fdi.Perda_Posse) AS Total_Perdas_Posse,
    SUM(fdi.Roubadas_Bola) AS Total_Roubadas_Bola
FROM
    dw_performance_futebol.Fato_Desempenho_Individual fdi
JOIN
    dw_performance_futebol.Dim_Equipe de ON fdi.ID_Time = de.ID_Equipe
LEFT JOIN LATERAL (
    SELECT
        fep.ID_Partida,
        fep.ID_Time,
        COUNT(CASE WHEN fep.ID_Tipo_Evento = 1 THEN 1 ELSE NULL END) AS Gols_Sofridos
    FROM
        dw_performance_futebol.Fato_Evento_Partida fep
    WHERE
        fep.ID_Time != fdi.ID_Time
        AND fep.ID_Partida = fdi.ID_Partida
    GROUP BY
        fep.ID_Partida,
        fep.ID_Time
) AS gols_sofridos ON fdi.ID_Partida = gols_sofridos.ID_Partida
GROUP BY
    de.ID_Equipe,
    de.Nome_Equipe;

CREATE OR REPLACE VIEW dw_performance_futebol.desempenho_dos_jogadores AS
SELECT
    dj.Nome_Jogador,
    de.Nome_Equipe,
    SUM(fdi.Numero_Gols_Feitos) AS Gols_Totais
FROM
    dw_performance_futebol.Fato_Desempenho_Individual fdi
JOIN
    dw_performance_futebol.Dim_Jogador dj ON fdi.ID_Jogador = dj.ID_Jogador
JOIN
    dw_performance_futebol.Dim_Equipe de ON fdi.ID_Time = de.ID_Equipe
GROUP BY
    dj.Nome_Jogador,
    de.Nome_Equipe
ORDER BY
    Gols_Totais DESC;

CREATE OR REPLACE VIEW dw_performance_futebol.jogadores_mais_faltosos_da_liga AS
SELECT
    dj.Nome_Jogador,
    de.Nome_Equipe,
    SUM(fdi.Numero_Faltas_Cometidas) AS Faltas_Totais
FROM
    dw_performance_futebol.Fato_Desempenho_Individual fdi
JOIN
    dw_performance_futebol.Dim_Jogador dj ON fdi.ID_Jogador = dj.ID_Jogador
JOIN
    dw_performance_futebol.Dim_Equipe de ON fdi.ID_Time = de.ID_Equipe
GROUP BY
    dj.Nome_Jogador,
    de.Nome_Equipe
ORDER BY
    Faltas_Totais DESC;

CREATE OR REPLACE VIEW dw_performance_futebol.avaliacao_condicionamento_jogadores AS
SELECT
    fdi.id_jogador,
    dj.nome_jogador,
    dj.idade,
    dj.peso,
    dj.altura,
    dj.porc_gordura,
    dj.porcent_musculo,
    dj.posicao,
    de.nome_equipe,
    TO_CHAR(d.data_completa, 'DD-MM-YYYY') AS data_jogo,
    fdi.dist_percorrida_defesa,
    fdi.dist_percorrida_ataque,
    ROUND(CAST(fdi.dist_percorrida_defesa + fdi.dist_percorrida_ataque AS DECIMAL), 2) AS total_dist_percorrida
FROM
    dw_performance_futebol.fato_desempenho_individual fdi
JOIN
    dw_performance_futebol.dim_jogador dj ON fdi.id_jogador = dj.id_jogador
JOIN
    dw_performance_futebol.dim_equipe de ON fdi.id_time = de.id_equipe
JOIN
    dw_performance_futebol.dim_partida p ON fdi.id_partida = p.id_partida
JOIN
    dw_performance_futebol.dim_tempo d ON p.id_data = d.id_tempo;

-- #############################################
-- ETAPA 7: ENJOY!!! :D
-- #############################################

select *from dw_performance_futebol.avaliacao_geral_das_equipes;
select *from dw_performance_futebol.desempenho_dos_jogadores;
select *from dw_performance_futebol.jogadores_mais_faltosos_da_liga;
select *from dw_performance_futebol.avaliacao_condicionamento_jogadores;

-- Criar schema gold
CREATE SCHEMA IF NOT EXISTS gold;

-- Dropar tabelas se existirem (para reexecução)
DROP TABLE IF EXISTS gold.FAT_LANCAMENTO CASCADE;
DROP TABLE IF EXISTS gold.DIM_DISTRIBUIDORA CASCADE;
DROP TABLE IF EXISTS gold.DIM_FILME CASCADE;
DROP TABLE IF EXISTS gold.DIM_DATA_LANCAMENTO CASCADE;

CREATE TABLE gold.DIM_DISTRIBUIDORA (
    srk_dist_pk SERIAL PRIMARY KEY,
    registro_distribuidora VARCHAR(8),
    distribuidora VARCHAR(255),
    cnpj_distribuidora VARCHAR(18)
);

CREATE TABLE gold.DIM_FILME (
    srk_filme_pk SERIAL PRIMARY KEY,
    titulo_original VARCHAR(255),
    tipo_obra VARCHAR(100),
    pais_obra VARCHAR(100),
    cpb_roe VARCHAR(20)
);

CREATE TABLE gold.DIM_DATA_LANCAMENTO (
    srk_dlan_pk SERIAL PRIMARY KEY,
    dia SMALLINT, 
    mes SMALLINT,
    ano INTEGER
);

CREATE TABLE gold.FAT_LANCAMENTO (
    srk_lan_pk SERIAL PRIMARY KEY,
    srk_filme_fk INT,
    srk_dlan_fk INT,
    srk_dist_fk INT, 
    publico_total INT,
    renda_total NUMERIC(15, 2), 
    
    CONSTRAINT fk_filme
        FOREIGN KEY (srk_filme_fk) 
        REFERENCES gold.DIM_FILME (srk_filme_pk)
        ON DELETE RESTRICT,

    CONSTRAINT fk_data_lancamento
        FOREIGN KEY (srk_dlan_fk)
        REFERENCES gold.DIM_DATA_LANCAMENTO (srk_dlan_pk)
        ON DELETE RESTRICT,

    CONSTRAINT fk_distribuidora
        FOREIGN KEY (srk_dist_fk)
        REFERENCES gold.DIM_DISTRIBUIDORA (srk_dist_pk)
        ON DELETE RESTRICT
);

-- Índices para otimização de consultas
CREATE INDEX idx_dim_filme_titulo ON gold.DIM_FILME(titulo_original);
CREATE INDEX idx_dim_data_ano ON gold.DIM_DATA_LANCAMENTO(ano);
CREATE INDEX idx_dim_dist_cnpj ON gold.DIM_DISTRIBUIDORA(cnpj_distribuidora);
CREATE INDEX idx_fat_filme ON gold.FAT_LANCAMENTO(srk_filme_fk);
CREATE INDEX idx_fat_data ON gold.FAT_LANCAMENTO(srk_dlan_fk);
CREATE INDEX idx_fat_dist ON gold.FAT_LANCAMENTO(srk_dist_fk);
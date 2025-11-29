-- Criar schema gold
CREATE SCHEMA IF NOT EXISTS gold;

-- Dropar tabelas se existirem (para reexecução)
DROP TABLE IF EXISTS gold.FAT_LANCAMENTO CASCADE;
DROP TABLE IF EXISTS gold.DIM_DISTRIBUIDORA CASCADE;
DROP TABLE IF EXISTS gold.DIM_FILME CASCADE;
DROP TABLE IF EXISTS gold.DIM_DATA_LANCAMENTO CASCADE;

CREATE TABLE gold.DIM_DISTRIBUIDORA (
    srk_dis SERIAL PRIMARY KEY,
    registro_distribuidora VARCHAR(8),
    distribuidora VARCHAR(255),
    cnpj_distribuidora VARCHAR(18)
);

CREATE TABLE gold.DIM_FILME (
    srk_filme SERIAL PRIMARY KEY,
    titulo_original VARCHAR(255),
    tipo_obra VARCHAR(100),
    pais_obra VARCHAR(100),
    cpb_roe VARCHAR(20)
);

CREATE TABLE gold.DIM_DATA_LANCAMENTO (
    srk_dla SERIAL PRIMARY KEY,
    dia SMALLINT, 
    mes SMALLINT,
    ano INTEGER
);

CREATE TABLE gold.FAT_LANCAMENTO (
    srk_lan SERIAL PRIMARY KEY,
    srk_filme INT,
    srk_dla INT,
    srk_dis INT, 
    publico_total INT,
    renda_total NUMERIC(15, 2), 
    
    CONSTRAINT fk_filme
        FOREIGN KEY (srk_filme) 
        REFERENCES gold.DIM_FILME (srk_filme)
        ON DELETE RESTRICT,

    CONSTRAINT fk_data_lancamento
        FOREIGN KEY (srk_dla)
        REFERENCES gold.DIM_DATA_LANCAMENTO (srk_dla)
        ON DELETE RESTRICT,

    CONSTRAINT fk_distribuidora
        FOREIGN KEY (srk_dis)
        REFERENCES gold.DIM_DISTRIBUIDORA (srk_dis)
        ON DELETE RESTRICT
);

-- Índices para otimização de consultas
CREATE INDEX idx_dim_filme_titulo ON gold.DIM_FILME(titulo_original);
CREATE INDEX idx_dim_data_ano ON gold.DIM_DATA_LANCAMENTO(ano);
CREATE INDEX idx_dim_dis_cnpj ON gold.DIM_DISTRIBUIDORA(cnpj_distribuidora);
CREATE INDEX idx_fat_filme ON gold.FAT_LANCAMENTO(srk_filme);
CREATE INDEX idx_fat_data ON gold.FAT_LANCAMENTO(srk_dla);
CREATE INDEX idx_fat_dis ON gold.FAT_LANCAMENTO(srk_dis);
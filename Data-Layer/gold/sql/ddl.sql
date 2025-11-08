
CREATE TABLE DIM_DISTRIBUIDORA (
    srk_dist_pk SERIAL PRIMARY KEY,
    registro_distribuidora VARCHAR(8),
    distribuidora VARCHAR(255),
    cnpj_distribuidora VARCHAR(18)
);

CREATE TABLE DIM_FILME (
    srk_filme_pk SERIAL PRIMARY KEY,
    titulo_original VARCHAR(255),
    tipo_obra VARCHAR(100),
    pais_obra VARCHAR(100),
    cbp_roe VARCHAR(14)
);

CREATE TABLE DIM_DATA_LANCAMENTO (
    srk_dlan_pk SERIAL PRIMARY KEY,
    dia SMALLINT, 
    mes SMALLINT, 
);

CREATE TABLE FAT_LANCAMENTO (
    srk_lan_pk SERIAL PRIMARY KEY,
    srk_filme_fk INT,
    srk_dlan_fk INT,
    srk_dist_fk INT, 
    publico_total INT,
    renda NUMERIC(15, 2), 
    
    CONSTRAINT fk_filme
        FOREIGN KEY (srk_filme_fk) 
        REFERENCES DIM_FILME (srk_filme_pk)
        ON DELETE RESTRICT,

    CONSTRAINT fk_data_lancamento
        FOREIGN KEY (srk_dlan_fk)
        REFERENCES DIM_DATA_LANCAMENTO (srk_dlan_pk)
        ON DELETE RESTRICT,

    CONSTRAINT fk_distribuidora
        FOREIGN KEY (srk_dist_fk)
        REFERENCES DIM_DISTRIBUIDORA (srk_dist_pk)
        ON DELETE RESTRICT
);
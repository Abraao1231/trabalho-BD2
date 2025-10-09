
CREATE TABLE IF NOT EXISTS lancamentos (
    id SERIAL PRIMARY KEY,
    data_lancamento DATE,
    titulo_original TEXT,
    cpb_roe VARCHAR(20),
    tipo_obra VARCHAR(50),
    pais_obra VARCHAR(50),
    publico_total INTEGER,
    renda_total NUMERIC(15, 2),
    distribuidora TEXT,
    registro_distribuidora VARCHAR(20),
    cnpj_distribuidora VARCHAR(20),
    ano_lancamento INTEGER,
    mes_lancamento INTEGER,
    dia_lancamento INTEGER,
    is_outlier BOOLEAN
);

-- Criação de um índice na coluna 'titulo_original' para otimizar buscas
CREATE INDEX IF NOT EXISTS idx_titulo_original ON lancamentos(titulo_original);

-- Criação de um índice na coluna 'ano_lancamento' para otimizar filtros por ano
CREATE INDEX IF NOT EXISTS idx_ano_lancamento ON lancamentos(ano_lancamento);

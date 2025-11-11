-- ========================================
-- CONSULTAS ANALÍTICAS - CAMADA GOLD
-- Data Lakehouse - Análise de Lançamentos Cinematográficos
-- ========================================

-- ========================================
-- 1. TOP 10 DISTRIBUIDORAS POR FATURAMENTO TOTAL
-- ========================================
SELECT 
    d.distribuidora AS distribuidora,
    d.cnpj_distribuidora AS cnpj,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    COUNT(DISTINCT f.srk_filme_fk) AS qtd_filmes_lancados
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DISTRIBUIDORA d ON f.srk_dist_fk = d.srk_dist_pk
GROUP BY d.distribuidora, d.cnpj_distribuidora
ORDER BY faturamento_total DESC
LIMIT 10;


-- ========================================
-- 2. TOP 10 FILMES DE MAIOR BILHETERIA
-- ========================================
SELECT 
    filme.titulo_original,
    filme.tipo_obra,
    filme.pais_obra,
    dist.distribuidora,
    dt.ano,
    SUM(f.renda_total) AS bilheteria_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON f.srk_dist_fk = dist.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora, dt.ano
ORDER BY bilheteria_total DESC
LIMIT 10;


-- ========================================
-- 3. FATURAMENTO POR PAÍS DE ORIGEM (EXCLUINDO EUA E CANADÁ)
-- ========================================
SELECT 
    filme.pais_obra,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio_por_lancamento
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
WHERE filme.pais_obra NOT IN ('ESTADOS UNIDOS', 'CANADÁ', 'CANADA')
GROUP BY filme.pais_obra
ORDER BY faturamento_total DESC
LIMIT 10;


-- ========================================
-- 4. DESEMPENHO POR TIPO DE OBRA
-- ========================================
SELECT 
    filme.tipo_obra,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
GROUP BY filme.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 5. FATURAMENTO POR TIPO DE OBRA (EXCLUINDO FICÇÃO E ANIMAÇÃO)
-- ========================================
SELECT 
    filme.tipo_obra,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
WHERE filme.tipo_obra NOT IN ('FICÇÃO', 'ANIMAÇÃO', 'FICCAO', 'ANIMACAO')
GROUP BY filme.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 6. ANÁLISE TEMPORAL - FATURAMENTO POR ANO
-- ========================================
SELECT 
    dt.ano,
    COUNT(DISTINCT f.srk_filme_fk) AS qtd_lancamentos,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
GROUP BY dt.ano
ORDER BY dt.ano DESC;


-- ========================================
-- 7. SAZONALIDADE - FATURAMENTO POR MÊS DO ANO
-- ========================================
SELECT 
    dt.mes,
    CASE dt.mes
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS nome_mes,
    COUNT(*) AS qtd_lancamentos,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
GROUP BY dt.mes
ORDER BY dt.mes;


-- ========================================
-- 8. TOP 10 FILMES COM MAIOR TICKET MÉDIO
-- ========================================
WITH ticket_medio_calc AS (
    SELECT 
        filme.titulo_original,
        filme.tipo_obra,
        filme.pais_obra,
        dist.distribuidora,
        SUM(f.renda_total) AS renda_total,
        SUM(f.publico_total) AS publico_total,
        ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO f
    INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
    INNER JOIN gold.DIM_DISTRIBUIDORA dist ON f.srk_dist_fk = dist.srk_dist_pk
    WHERE f.publico_total > 0
    GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora
)
SELECT *
FROM ticket_medio_calc
ORDER BY ticket_medio DESC
LIMIT 10;


-- ========================================
-- 9. TOP 10 FILMES COM MENOR TICKET MÉDIO
-- ========================================
WITH ticket_medio_calc AS (
    SELECT 
        filme.titulo_original,
        filme.tipo_obra,
        filme.pais_obra,
        dist.distribuidora,
        SUM(f.renda_total) AS renda_total,
        SUM(f.publico_total) AS publico_total,
        ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO f
    INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
    INNER JOIN gold.DIM_DISTRIBUIDORA dist ON f.srk_dist_fk = dist.srk_dist_pk
    WHERE f.publico_total > 0
    GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora
)
SELECT *
FROM ticket_medio_calc
WHERE ticket_medio > 0
ORDER BY ticket_medio ASC
LIMIT 10;


-- ========================================
-- 10. ANÁLISE DE CONCENTRAÇÃO DE MERCADO - MARKET SHARE
-- ========================================
WITH faturamento_total AS (
    SELECT SUM(renda_total) AS total_mercado
    FROM gold.FAT_LANCAMENTO
),
faturamento_por_dist AS (
    SELECT 
        d.distribuidora,
        SUM(f.renda_total) AS faturamento_distribuidora
    FROM gold.FAT_LANCAMENTO f
    INNER JOIN gold.DIM_DISTRIBUIDORA d ON f.srk_dist_fk = d.srk_dist_pk
    GROUP BY d.distribuidora
)
SELECT 
    fpd.distribuidora,
    fpd.faturamento_distribuidora,
    ft.total_mercado,
    ROUND((fpd.faturamento_distribuidora / NULLIF(ft.total_mercado, 0)) * 100, 2) AS market_share_percentual,
    SUM(ROUND((fpd.faturamento_distribuidora / NULLIF(ft.total_mercado, 0)) * 100, 2)) 
        OVER (ORDER BY fpd.faturamento_distribuidora DESC) AS market_share_acumulado
FROM faturamento_por_dist fpd
CROSS JOIN faturamento_total ft
ORDER BY fpd.faturamento_distribuidora DESC
LIMIT 15;


-- ========================================
-- 11. RANKING DE DESEMPENHO - DISTRIBUIDORAS POR ANO
-- ========================================
SELECT 
    dt.ano,
    d.distribuidora,
    COUNT(DISTINCT f.srk_filme_fk) AS qtd_filmes_lancados,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    RANK() OVER (PARTITION BY dt.ano ORDER BY SUM(f.renda_total) DESC) AS ranking_ano
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DISTRIBUIDORA d ON f.srk_dist_fk = d.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
GROUP BY dt.ano, d.distribuidora
ORDER BY dt.ano DESC, ranking_ano ASC;


-- ========================================
-- 12. FILMES MAIS ASSISTIDOS (MAIOR PÚBLICO)
-- ========================================
SELECT 
    filme.titulo_original,
    filme.tipo_obra,
    filme.pais_obra,
    dist.distribuidora,
    dt.ano,
    SUM(f.publico_total) AS total_publico,
    SUM(f.renda_total) AS faturamento_total,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON f.srk_dist_fk = dist.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora, dt.ano
ORDER BY total_publico DESC
LIMIT 10;


-- ========================================
-- 13. ANÁLISE COMPARATIVA - BRASIL VS OUTROS PAÍSES
-- ========================================
SELECT 
    CASE 
        WHEN filme.pais_obra = 'BRASIL' THEN 'BRASIL'
        ELSE 'OUTROS PAÍSES'
    END AS origem,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
GROUP BY 
    CASE 
        WHEN filme.pais_obra = 'BRASIL' THEN 'BRASIL'
        ELSE 'OUTROS PAÍSES'
    END
ORDER BY faturamento_total DESC;


-- ========================================
-- 14. EVOLUÇÃO DO TICKET MÉDIO POR ANO
-- ========================================
SELECT 
    dt.ano,
    COUNT(*) AS qtd_lancamentos,
    ROUND(AVG(f.renda_total / NULLIF(f.publico_total, 0)), 2) AS ticket_medio,
    ROUND(MIN(f.renda_total / NULLIF(f.publico_total, 0)), 2) AS ticket_minimo,
    ROUND(MAX(f.renda_total / NULLIF(f.publico_total, 0)), 2) AS ticket_maximo,
    ROUND(STDDEV(f.renda_total / NULLIF(f.publico_total, 0)), 2) AS desvio_padrao_ticket
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk
WHERE f.publico_total > 0
GROUP BY dt.ano
ORDER BY dt.ano;


-- ========================================
-- 15. PERFORMANCE DE FILMES POR CÓDIGO CPB/ROE
-- ========================================
SELECT 
    filme.cpb_roe,
    filme.titulo_original,
    filme.tipo_obra,
    SUM(f.renda_total) AS faturamento_total,
    SUM(f.publico_total) AS publico_total,
    COUNT(*) AS qtd_lancamentos_registrados
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_FILME filme ON f.srk_filme_fk = filme.srk_filme_pk
WHERE filme.cpb_roe IS NOT NULL
GROUP BY filme.cpb_roe, filme.titulo_original, filme.tipo_obra
ORDER BY faturamento_total DESC
LIMIT 20;


-- ========================================
-- 16. DASHBOARD RESUMO EXECUTIVO
-- ========================================
SELECT 
    COUNT(DISTINCT f.srk_filme_fk) AS total_filmes_unicos,
    COUNT(DISTINCT f.srk_dist_fk) AS total_distribuidoras,
    SUM(f.renda_total) AS faturamento_total_geral,
    SUM(f.publico_total) AS publico_total_geral,
    ROUND(AVG(f.renda_total), 2) AS faturamento_medio_lancamento,
    ROUND(SUM(f.renda_total) / NULLIF(SUM(f.publico_total), 0), 2) AS ticket_medio_geral,
    MIN(dt.ano) AS ano_inicial,
    MAX(dt.ano) AS ano_final
FROM gold.FAT_LANCAMENTO f
INNER JOIN gold.DIM_DATA_LANCAMENTO dt ON f.srk_dlan_fk = dt.srk_dlan_pk;

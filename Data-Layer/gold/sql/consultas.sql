-- ========================================
-- CONSULTAS ANALÍTICAS - CAMADA GOLD
-- Data Lakehouse - Análise de Lançamentos Cinematográficos
-- ========================================

-- ========================================
-- 1. TOP 10 DISTRIBUIDORAS POR FATURAMENTO TOTAL
-- ========================================
SELECT 
    dist.distribuidora AS distribuidora,
    dist.cnpj_distribuidora AS cnpj,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    COUNT(DISTINCT lan.srk_filme_fk) AS qtd_filmes_lancados
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
GROUP BY dist.distribuidora, dist.cnpj_distribuidora
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
    dlan.ano,
    SUM(lan.renda_total) AS bilheteria_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora, dlan.ano
ORDER BY bilheteria_total DESC
LIMIT 10;


-- ========================================
-- 3. FATURAMENTO POR PAÍS DE ORIGEM (EXCLUINDO EUA E CANADÁ)
-- ========================================
SELECT 
    filme.pais_obra,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio_por_lancamento
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
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
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
GROUP BY filme.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 5. FATURAMENTO POR TIPO DE OBRA (EXCLUINDO FICÇÃO E ANIMAÇÃO)
-- ========================================
SELECT 
    filme.tipo_obra,
    COUNT(DISTINCT filme.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
WHERE filme.tipo_obra NOT IN ('FICÇÃO', 'ANIMAÇÃO', 'FICCAO', 'ANIMACAO')
GROUP BY filme.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 6. ANÁLISE TEMPORAL - FATURAMENTO POR ANO
-- ========================================
SELECT 
    dlan.ano,
    COUNT(DISTINCT lan.srk_filme_fk) AS qtd_lancamentos,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
GROUP BY dlan.ano
ORDER BY dlan.ano DESC;


-- ========================================
-- 7. SAZONALIDADE - FATURAMENTO POR MÊS DO ANO
-- ========================================
SELECT 
    dlan.mes,
    CASE dlan.mes
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
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
GROUP BY dlan.mes
ORDER BY dlan.mes;


-- ========================================
-- 8. TOP 10 FILMES COM MAIOR TICKET MÉDIO
-- ========================================
WITH ticket_medio_calc AS (
    SELECT 
        filme.titulo_original,
        filme.tipo_obra,
        filme.pais_obra,
        dist.distribuidora,
        SUM(lan.renda_total) AS renda_total,
        SUM(lan.publico_total) AS publico_total,
        ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
    INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
    WHERE lan.publico_total > 0
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
        SUM(lan.renda_total) AS renda_total,
        SUM(lan.publico_total) AS publico_total,
        ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
    INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
    WHERE lan.publico_total > 0
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
        SUM(lan.renda_total) AS faturamento_distribuidora
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_DISTRIBUIDORA d ON lan.srk_dist_fk = d.srk_dist_pk
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
    dlan.ano,
    dist.distribuidora,
    COUNT(DISTINCT lan.srk_filme_fk) AS qtd_filmes_lancados,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    RANK() OVER (PARTITION BY dlan.ano ORDER BY SUM(lan.renda_total) DESC) AS ranking_ano
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
GROUP BY dlan.ano, dist.distribuidora
ORDER BY dlan.ano DESC, ranking_ano ASC;


-- ========================================
-- 12. FILMES MAIS ASSISTIDOS (MAIOR PÚBLICO)
-- ========================================
SELECT 
    filme.titulo_original,
    filme.tipo_obra,
    filme.pais_obra,
    dist.distribuidora,
    dlan.ano,
    SUM(lan.publico_total) AS total_publico,
    SUM(lan.renda_total) AS faturamento_total,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
INNER JOIN gold.DIM_DISTRIBUIDORA dist ON lan.srk_dist_fk = dist.srk_dist_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
GROUP BY filme.titulo_original, filme.tipo_obra, filme.pais_obra, dist.distribuidora, dlan.ano
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
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
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
    dlan.ano,
    COUNT(*) AS qtd_lancamentos,
    ROUND(AVG(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_medio,
    ROUND(MIN(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_minimo,
    ROUND(MAX(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_maximo,
    ROUND(STDDEV(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS desvio_padrao_ticket
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk
WHERE lan.publico_total > 0
GROUP BY dlan.ano
ORDER BY dlan.ano;


-- ========================================
-- 15. PERFORMANCE DE FILMES POR CÓDIGO CPB/ROE
-- ========================================
SELECT 
    filme.cpb_roe,
    filme.titulo_original,
    filme.tipo_obra,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    COUNT(*) AS qtd_lancamentos_registrados
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = filme.srk_filme_pk
WHERE filme.cpb_roe IS NOT NULL
GROUP BY filme.cpb_roe, filme.titulo_original, filme.tipo_obra
ORDER BY faturamento_total DESC
LIMIT 20;


-- ========================================
-- 16. DASHBOARD RESUMO EXECUTIVO
-- ========================================
SELECT 
    COUNT(DISTINCT lan.srk_filme_fk) AS total_filmes_unicos,
    COUNT(DISTINCT lan.srk_dist_fk) AS total_distribuidoras,
    SUM(lan.renda_total) AS faturamento_total_geral,
    SUM(lan.publico_total) AS publico_total_geral,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio_lancamento,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio_geral,
    MIN(dlan.ano) AS ano_inicial,
    MAX(dlan.ano) AS ano_final
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dlan.srk_dlan_pk;

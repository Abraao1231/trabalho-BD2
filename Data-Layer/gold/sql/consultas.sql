-- ========================================
-- CONSULTAS ANALÍTICAS - CAMADA GOLD
-- Data Lakehouse - Análise de Lançamentos Cinematográficos
-- ========================================

-- ========================================
-- 1. TOP 10 disRIBUIDORAS POR FATURAMENTO TOTAL
-- ========================================
SELECT 
    dis.disribuidora AS disribuidora,
    dis.cnpj_disribuidora AS cnpj,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    COUNT(disINCT lan.srk_filme_fk) AS qtd_filmes_lancados
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
GROUP BY dis.disribuidora, dis.cnpj_disribuidora
ORDER BY faturamento_total DESC
LIMIT 10;


-- ========================================
-- 2. TOP 10 FILMES DE MAIOR BILHETERIA
-- ========================================
SELECT 
    fil.titulo_original,
    fil.tipo_obra,
    fil.pais_obra,
    dis.disribuidora,
    dla.ano,
    SUM(lan.renda_total) AS bilheteria_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
GROUP BY fil.titulo_original, fil.tipo_obra, fil.pais_obra, dis.disribuidora, dla.ano
ORDER BY bilheteria_total DESC
LIMIT 10;


-- ========================================
-- 3. FATURAMENTO POR PAÍS DE ORIGEM (EXCLUINDO EUA E CANADÁ)
-- ========================================
SELECT 
    fil.pais_obra,
    COUNT(disINCT fil.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio_por_lancamento
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
WHERE fil.pais_obra NOT IN ('ESTADOS UNIDOS', 'CANADÁ', 'CANADA')
GROUP BY fil.pais_obra
ORDER BY faturamento_total DESC
LIMIT 10;


-- ========================================
-- 4. DESEMPENHO POR TIPO DE OBRA
-- ========================================
SELECT 
    fil.tipo_obra,
    COUNT(disINCT fil.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
GROUP BY fil.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 5. FATURAMENTO POR TIPO DE OBRA (EXCLUINDO FICÇÃO E ANIMAÇÃO)
-- ========================================
SELECT 
    fil.tipo_obra,
    COUNT(disINCT fil.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
WHERE fil.tipo_obra NOT IN ('FICÇÃO', 'ANIMAÇÃO', 'FICCAO', 'ANIMACAO')
GROUP BY fil.tipo_obra
ORDER BY faturamento_total DESC;


-- ========================================
-- 6. ANÁLISE TEMPORAL - FATURAMENTO POR ANO
-- ========================================
SELECT 
    dla.ano,
    COUNT(disINCT lan.srk_filme_fk) AS qtd_lancamentos,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
GROUP BY dla.ano
ORDER BY dla.ano DESC;


-- ========================================
-- 7. SAZONALIDADE - FATURAMENTO POR MÊS DO ANO
-- ========================================
SELECT 
    dla.mes,
    CASE dla.mes
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
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
GROUP BY dla.mes
ORDER BY dla.mes;


-- ========================================
-- 8. TOP 10 FILMES COM MAIOR TICKET MÉDIO
-- ========================================
WITH ticket_medio_calc AS (
    SELECT 
        fil.titulo_original,
        fil.tipo_obra,
        fil.pais_obra,
        dis.disribuidora,
        SUM(lan.renda_total) AS renda_total,
        SUM(lan.publico_total) AS publico_total,
        ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
    INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
    WHERE lan.publico_total > 0
    GROUP BY fil.titulo_original, fil.tipo_obra, fil.pais_obra, dis.disribuidora
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
        fil.titulo_original,
        fil.tipo_obra,
        fil.pais_obra,
        dis.disribuidora,
        SUM(lan.renda_total) AS renda_total,
        SUM(lan.publico_total) AS publico_total,
        ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
    INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
    WHERE lan.publico_total > 0
    GROUP BY fil.titulo_original, fil.tipo_obra, fil.pais_obra, dis.disribuidora
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
faturamento_por_dis AS (
    SELECT 
        d.disribuidora,
        SUM(lan.renda_total) AS faturamento_disribuidora
    FROM gold.FAT_LANCAMENTO lan
    INNER JOIN gold.DIM_disRIBUIDORA d ON lan.srk_dis_fk = d.srk_dis_pk
    GROUP BY d.disribuidora
)
SELECT 
    fpd.disribuidora,
    fpd.faturamento_disribuidora,
    ft.total_mercado,
    ROUND((fpd.faturamento_disribuidora / NULLIF(ft.total_mercado, 0)) * 100, 2) AS market_share_percentual,
    SUM(ROUND((fpd.faturamento_disribuidora / NULLIF(ft.total_mercado, 0)) * 100, 2)) 
        OVER (ORDER BY fpd.faturamento_disribuidora DESC) AS market_share_acumulado
FROM faturamento_por_dis fpd
CROSS JOIN faturamento_total ft
ORDER BY fpd.faturamento_disribuidora DESC
LIMIT 15;


-- ========================================
-- 11. RANKING DE DESEMPENHO - disRIBUIDORAS POR ANO
-- ========================================
SELECT 
    dla.ano,
    dis.disribuidora,
    COUNT(disINCT lan.srk_filme_fk) AS qtd_filmes_lancados,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    RANK() OVER (PARTITION BY dla.ano ORDER BY SUM(lan.renda_total) DESC) AS ranking_ano
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
GROUP BY dla.ano, dis.disribuidora
ORDER BY dla.ano DESC, ranking_ano ASC;


-- ========================================
-- 12. FILMES MAIS ASSISTIDOS (MAIOR PÚBLICO)
-- ========================================
SELECT 
    fil.titulo_original,
    fil.tipo_obra,
    fil.pais_obra,
    dis.disribuidora,
    dla.ano,
    SUM(lan.publico_total) AS total_publico,
    SUM(lan.renda_total) AS faturamento_total,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
INNER JOIN gold.DIM_disRIBUIDORA dis ON lan.srk_dis_fk = dis.srk_dis_pk
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
GROUP BY fil.titulo_original, fil.tipo_obra, fil.pais_obra, dis.disribuidora, dla.ano
ORDER BY total_publico DESC
LIMIT 10;


-- ========================================
-- 13. ANÁLISE COMPARATIVA - BRASIL VS OUTROS PAÍSES
-- ========================================
SELECT 
    CASE 
        WHEN fil.pais_obra = 'BRASIL' THEN 'BRASIL'
        ELSE 'OUTROS PAÍSES'
    END AS origem,
    COUNT(disINCT fil.srk_filme_pk) AS qtd_filmes,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
GROUP BY 
    CASE 
        WHEN fil.pais_obra = 'BRASIL' THEN 'BRASIL'
        ELSE 'OUTROS PAÍSES'
    END
ORDER BY faturamento_total DESC;


-- ========================================
-- 14. EVOLUÇÃO DO TICKET MÉDIO POR ANO
-- ========================================
SELECT 
    dla.ano,
    COUNT(*) AS qtd_lancamentos,
    ROUND(AVG(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_medio,
    ROUND(MIN(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_minimo,
    ROUND(MAX(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS ticket_maximo,
    ROUND(STDDEV(lan.renda_total / NULLIF(lan.publico_total, 0)), 2) AS desvio_padrao_ticket
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk
WHERE lan.publico_total > 0
GROUP BY dla.ano
ORDER BY dla.ano;


-- ========================================
-- 15. PERFORMANCE DE FILMES POR CÓDIGO CPB/ROE
-- ========================================
SELECT 
    fil.cpb_roe,
    fil.titulo_original,
    fil.tipo_obra,
    SUM(lan.renda_total) AS faturamento_total,
    SUM(lan.publico_total) AS publico_total,
    COUNT(*) AS qtd_lancamentos_registrados
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_FILME filme ON lan.srk_filme_fk = fil.srk_filme_pk
WHERE fil.cpb_roe IS NOT NULL
GROUP BY fil.cpb_roe, fil.titulo_original, fil.tipo_obra
ORDER BY faturamento_total DESC
LIMIT 20;


-- ========================================
-- 16. DASHBOARD RESUMO EXECUTIVO
-- ========================================
SELECT 
    COUNT(disINCT lan.srk_filme_fk) AS total_filmes_unicos,
    COUNT(disINCT lan.srk_dis_fk) AS total_disribuidoras,
    SUM(lan.renda_total) AS faturamento_total_geral,
    SUM(lan.publico_total) AS publico_total_geral,
    ROUND(AVG(lan.renda_total), 2) AS faturamento_medio_lancamento,
    ROUND(SUM(lan.renda_total) / NULLIF(SUM(lan.publico_total), 0), 2) AS ticket_medio_geral,
    MIN(dla.ano) AS ano_inicial,
    MAX(dla.ano) AS ano_final
FROM gold.FAT_LANCAMENTO lan
INNER JOIN gold.DIM_DATA_LANCAMENTO dlan ON lan.srk_dlan_fk = dla.srk_dlan_pk;

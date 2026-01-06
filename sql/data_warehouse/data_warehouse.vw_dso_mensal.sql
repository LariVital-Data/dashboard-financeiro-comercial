CREATE OR REPLACE VIEW data_warehouse.vw_dso_mensal AS
WITH contas_a_receber AS (
    SELECT
        EXTRACT(YEAR FROM cr.vencimento)::int  AS ano,
        EXTRACT(MONTH FROM cr.vencimento)::int AS mes,
        SUM(cr.valor_original)                 AS total_contas_receber
    FROM financeiro.conta_receber cr
    WHERE cr.id_situacao IN (1, 2) -- EM_ABERTO, ATRASADA
    GROUP BY
        ano,
        mes
),
receita_mensal AS (
    SELECT
        dt.ano,
        dt.mes,
        SUM(nf.valor) AS receita_total
    FROM vendas.nota_fiscal nf
    JOIN data_warehouse.dim_tempo dt
        ON dt.data = nf.data_venda
    GROUP BY
        dt.ano,
        dt.mes
),
dias_mes AS (
    SELECT
        ano,
        mes,
        COUNT(*) AS dias_no_mes
    FROM data_warehouse.dim_tempo
    GROUP BY
        ano,
        mes
)
SELECT
    r.ano,
    r.mes,
    r.receita_total,
    c.total_contas_receber,
    d.dias_no_mes,
    CASE
        WHEN r.receita_total > 0
        THEN ROUND(
            (c.total_contas_receber / r.receita_total) * d.dias_no_mes,
            2
        )
        ELSE 0
    END AS dso
FROM receita_mensal r
LEFT JOIN contas_a_receber c
    ON c.ano = r.ano
   AND c.mes = r.mes
JOIN dias_mes d
    ON d.ano = r.ano
   AND d.mes = r.mes
ORDER BY
    r.ano,
    r.mes;

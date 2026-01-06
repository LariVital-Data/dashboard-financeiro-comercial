CREATE OR REPLACE VIEW data_warehouse.vw_taxa_inadimplencia_estado AS
WITH faturamento AS (
    SELECT
        dc.estado,
        dt.ano,
        dt.mes,
        SUM(nf.valor) AS valor_faturado
    FROM vendas.nota_fiscal nf
    JOIN data_warehouse.dim_cliente dc
        ON dc.id = nf.id_cliente
    JOIN data_warehouse.dim_tempo dt
        ON dt.data = nf.data_venda
    GROUP BY
        dc.estado,
        dt.ano,
        dt.mes
),
inadimplencia AS (
    SELECT
        estado,
        EXTRACT(YEAR FROM vencimento)::int AS ano,
        EXTRACT(MONTH FROM vencimento)::int AS mes,
        SUM(valor_em_aberto) AS valor_inadimplente
    FROM data_warehouse.vw_inadimplencia_cliente
    GROUP BY
        estado,
        ano,
        mes
)
SELECT
    f.estado,
    f.ano,
    f.mes,
    f.valor_faturado,
    COALESCE(i.valor_inadimplente, 0) AS valor_inadimplente,
    CASE
        WHEN f.valor_faturado > 0
        THEN ROUND((COALESCE(i.valor_inadimplente, 0) / f.valor_faturado) * 100, 2)
        ELSE 0
    END AS taxa_inadimplencia_percentual
FROM faturamento f
LEFT JOIN inadimplencia i
    ON i.estado = f.estado
   AND i.ano = f.ano
   AND i.mes = f.mes;
select * from data_warehouse.vw_taxa_inadimplencia_estado
CREATE OR REPLACE VIEW data_warehouse.vw_performance_vendedor AS
SELECT
    dv.id                AS id_vendedor,
    dv.nome              AS nome_vendedor,

    dt.ano,
    dt.mes,

    COUNT(nf.id)         AS qtd_vendas,
    SUM(nf.valor)        AS valor_total_vendas,
    ROUND(
        SUM(nf.valor) / NULLIF(COUNT(nf.id), 0),
        2
    )                    AS ticket_medio
FROM vendas.nota_fiscal nf
JOIN data_warehouse.dim_vendedor dv
    ON dv.id = nf.id_vendedor
JOIN data_warehouse.dim_tempo dt
    ON dt.data = nf.data_venda
GROUP BY
    dv.id,
    dv.nome,
    dt.ano,
    dt.mes;

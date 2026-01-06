CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_periodo AS
SELECT
    data,
    ano,
    mes,
    dia,

    -- Entradas e saídas separadas
    SUM(CASE WHEN tipo_fluxo = 'RECEBER' THEN valor_fluxo ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN tipo_fluxo = 'PAGAR'   THEN ABS(valor_fluxo) ELSE 0 END) AS total_saidas,

    -- Saldo líquido
    SUM(valor_fluxo) AS saldo_periodo
FROM data_warehouse.vw_fluxo_caixa_realizado
GROUP BY
    data,
    ano,
    mes,
    dia;





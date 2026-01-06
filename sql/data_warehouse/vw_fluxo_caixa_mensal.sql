CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_mensal AS
SELECT
    -- Chaves temporais
    EXTRACT(YEAR  FROM data)::int AS ano,
    EXTRACT(MONTH FROM data)::int AS mes,
    DATE_TRUNC('month', data)::date AS data,

    -- Entradas do mês
    SUM(
        CASE 
            WHEN tipo_fluxo = 'RECEBER'
            THEN valor_fluxo
            ELSE 0
        END
    ) AS total_entrada,

    -- Saídas do mês
    SUM(
        CASE 
            WHEN tipo_fluxo = 'PAGAR'
            THEN ABS(valor_fluxo)
            ELSE 0
        END
    ) AS total_saida,

    -- Saldo líquido do mês
    SUM(valor_fluxo) AS saldo_periodo
FROM data_warehouse.vw_fluxo_caixa_realizado
GROUP BY
    EXTRACT(YEAR  FROM data),
    EXTRACT(MONTH FROM data),
    DATE_TRUNC('month', data)
ORDER BY
    ano,
    mes;

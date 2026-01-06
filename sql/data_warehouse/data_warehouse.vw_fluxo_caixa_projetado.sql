CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_projetado AS
WITH titulos_projetados AS (

    -- =========================
    -- CONTAS A RECEBER
    -- =========================
    SELECT
        'RECEBER'                         AS tipo_fluxo,
        cr.vencimento                     AS data_referencia,
        cr.valor_original                 AS valor,
        CASE
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '30 days' THEN '0-30'
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '60 days' THEN '31-60'
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '90 days' THEN '61-90'
            ELSE '90+'
        END                               AS faixa_dias
    FROM financeiro.conta_receber cr
    WHERE cr.id_situacao IN (1, 2)

    UNION ALL

    -- ======================
    -- CONTAS A PAGAR
    -- ======================
    SELECT
        'PAGAR'                           AS tipo_fluxo,
        cp.vencimento                     AS data_referencia,
        cp.valor_original * -1            AS valor,
        CASE
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '30 days' THEN '0-30'
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '60 days' THEN '31-60'
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '90 days' THEN '61-90'
            ELSE '90+'
        END                               AS faixa_dias
    FROM financeiro.conta_pagar cp
    WHERE cp.id_situacao IN (1, 2)
)

SELECT
    faixa_dias,
    SUM(CASE WHEN tipo_fluxo = 'RECEBER' THEN valor ELSE 0 END) AS total_a_receber,
    SUM(CASE WHEN tipo_fluxo = 'PAGAR'   THEN ABS(valor) ELSE 0 END) AS total_a_pagar,
    SUM(valor)                                                   AS saldo_projetado
FROM titulos_projetados
GROUP BY faixa_dias
ORDER BY
    CASE faixa_dias
        WHEN '0-30' THEN 1
        WHEN '31-60' THEN 2
        WHEN '61-90' THEN 3
        ELSE 4
    END;

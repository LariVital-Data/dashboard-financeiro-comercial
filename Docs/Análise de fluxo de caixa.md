## 📊 ABA 1 — ANÁLISE DE FLUXO DE CAIXA

### 1. Título da Query

**Nome:**
Análise de Fluxo de Caixa Mensal, Projetado e DSO

### 2. Descrição e Objetivo

Realizar a análise do fluxo de caixa financeiro da organização, permitindo a visualização das entradas, saídas e saldo realizado por período, bem como a projeção futura do saldo de caixa e o cálculo do indicador financeiro DSO (Days Sales Outstanding).

**Contexto**

Este conjunto de queries faz parte do trabalho de conclusão do módulo de SQL, utilizando como base o banco de dados **corporativo**, estendido com o schema **financeiro**, no qual foram modeladas tabelas de fatos e dimensões financeiras.

Foram criadas views no schema **data_warehouse** com o objetivo de facilitar análises financeiras e a construção de dashboards no Power BI, fornecendo uma visão consolidada do fluxo de caixa realizado, projetado e dos indicadores de recebimento.

### 3. Estrutura das Queries
**3.1 View — Fluxo de Caixa Mensal Realizado**
```
CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_mensal AS
SELECT
    EXTRACT(YEAR  FROM data)::int AS ano,
    EXTRACT(MONTH FROM data)::int AS mes,
    DATE_TRUNC('month', data)::date AS data,

    SUM(
        CASE 
            WHEN tipo_fluxo = 'RECEBER'
            THEN valor_fluxo
            ELSE 0
        END
    ) AS total_entrada,

    SUM(
        CASE 
            WHEN tipo_fluxo = 'PAGAR'
            THEN ABS(valor_fluxo)
            ELSE 0
        END
    ) AS total_saida,

    SUM(valor_fluxo) AS saldo_periodo
FROM data_warehouse.vw_fluxo_caixa_realizado
GROUP BY
    EXTRACT(YEAR  FROM data),
    EXTRACT(MONTH FROM data),
    DATE_TRUNC('month', data)
ORDER BY
    ano,
    mes;
```
**3.2 View — Fluxo de Caixa Projetado (30/60/90 dias)**
```
CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_projetado AS
WITH titulos_projetados AS (
    SELECT
        'RECEBER' AS tipo_fluxo,
        cr.vencimento AS data_referencia,
        cr.valor_original AS valor,
        CASE
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '30 days' THEN '0-30'
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '60 days' THEN '31-60'
            WHEN cr.vencimento <= CURRENT_DATE + INTERVAL '90 days' THEN '61-90'
            ELSE '90+'
        END AS faixa_dias
    FROM financeiro.conta_receber cr
    WHERE cr.id_situacao IN (1, 2)

    UNION ALL

    SELECT
        'PAGAR' AS tipo_fluxo,
        cp.vencimento AS data_referencia,
        cp.valor_original * -1 AS valor,
        CASE
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '30 days' THEN '0-30'
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '60 days' THEN '31-60'
            WHEN cp.vencimento <= CURRENT_DATE + INTERVAL '90 days' THEN '61-90'
            ELSE '90+'
        END AS faixa_dias
    FROM financeiro.conta_pagar cp
    WHERE cp.id_situacao IN (1, 2)
)
SELECT
    faixa_dias,
    SUM(CASE WHEN tipo_fluxo = 'RECEBER' THEN valor ELSE 0 END) AS total_a_receber,
    SUM(CASE WHEN tipo_fluxo = 'PAGAR'   THEN ABS(valor) ELSE 0 END) AS total_a_pagar,
    SUM(valor) AS saldo_projetado
FROM titulos_projetados
GROUP BY faixa_dias
ORDER BY
    CASE faixa_dias
        WHEN '0-30' THEN 1
        WHEN '31-60' THEN 2
        WHEN '61-90' THEN 3
        ELSE 4
    END;
```

**3.3 View — Fluxo de Caixa por Período (Base Analítica)**
```
CREATE OR REPLACE VIEW data_warehouse.vw_fluxo_caixa_periodo AS
SELECT
    data,
    ano,
    mes,
    dia,

    SUM(CASE WHEN tipo_fluxo = 'RECEBER' THEN valor_fluxo ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN tipo_fluxo = 'PAGAR'   THEN ABS(valor_fluxo) ELSE 0 END) AS total_saidas,

    SUM(valor_fluxo) AS saldo_periodo
FROM data_warehouse.vw_fluxo_caixa_realizado
GROUP BY
    data,
    ano,
    mes,
    dia;
```
**3.4 View — DSO Mensal**
```
CREATE OR REPLACE VIEW data_warehouse.vw_dso_mensal AS
WITH contas_a_receber AS (
    SELECT
        EXTRACT(YEAR FROM cr.vencimento)::int  AS ano,
        EXTRACT(MONTH FROM cr.vencimento)::int AS mes,
        SUM(cr.valor_original) AS total_contas_receber
    FROM financeiro.conta_receber cr
    WHERE cr.id_situacao IN (1, 2)
    GROUP BY ano, mes
),
receita_mensal AS (
    SELECT
        dt.ano,
        dt.mes,
        SUM(nf.valor) AS receita_total
    FROM vendas.nota_fiscal nf
    JOIN data_warehouse.dim_tempo dt
        ON dt.data = nf.data_venda
    GROUP BY dt.ano, dt.mes
),
dias_mes AS (
    SELECT
        ano,
        mes,
        COUNT(*) AS dias_no_mes
    FROM data_warehouse.dim_tempo
    GROUP BY ano, mes
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
```
### 4. Explicação do Código
**Detalhamento das colunas**

- total_entrada / total_saida: Valores financeiros de entradas e saídas por período.

- saldo_periodo / saldo_projetado: Resultado líquido do fluxo de caixa.

- faixa_dias: Classificação temporal para projeção financeira.

- dso: Indicador de prazo médio de recebimento.

**Tabelas utilizadas**

- financeiro.conta_receber

- financeiro.conta_pagar

- vendas.nota_fiscal

- data_warehouse.dim_tempo

- Views analíticas do schema data_warehouse

### Condições e filtros aplicados

- Consideração apenas de títulos em aberto ou atrasados

- Classificação temporal baseada na data atual

- Exclusão de registros cancelados ou liquidados

### 5. Resultados Esperados
**Descrição dos Resultados**

- As queries retornam informações consolidadas que permitem:

- Acompanhar o fluxo de caixa mensal realizado

- Projetar o saldo financeiro futuro

- Avaliar a eficiência do recebimento por meio do DSO

**Formato dos Dados**

- Dados agregados por mês

- Métricas financeiras numéricas

- Estrutura adequada para visualização em dashboards
### 6. Exemplo de Saída
| Ano | Mês | Total Entrada | Total Saída | Saldo |
|-----|-----|---------------|-------------|-------|
|2025 |  1  |   150.000,00  | 120.000,00  |30.000 |

### 7. Análises e Insights
- Forte crescimento de caixa entre 2015 e 2017
- Estrutura de custos extremamente controlada: Ao longo de todo o período analisado, as saídas de caixa representam uma parcela muito pequena das entradas.
- Inflexão negativa a partir de 2018: A partir de 2018, ocorre uma queda abrupta e contínua nas entradas de caixa, com redução mês a mês.
- DSO historicamente baixo e controlado.
- Forte expectativa de entrada de caixa no curto prazo (0–30 dias).
- Ausência de saídas projetadas
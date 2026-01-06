## ABA 2 — Gestão de Inadimplência

### 1. Descrição e Objetivo

Analisar a inadimplência financeira de forma consolidada por **estado e período**, permitindo identificar regiões com maior risco de crédito e apoiar decisões relacionadas à política de cobrança e gestão financeira.

**Contexto**

Esta análise faz parte do painel de **Gestão de Inadimplência**, cujo foco é responder às seguintes perguntas de negócio:

- Qual o volume financeiro inadimplente?

- Qual a taxa de inadimplência por região (estado)?

- Quais clientes apresentam maior número de inadimplência?

A query utiliza dados do **schema financeiro** integrados ao **data warehouse corporativo**, consolidando informações de faturamento e contas em atraso.

### 3. Estrutura da Query
**Código SQL**
```
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
        THEN ROUND(
            (COALESCE(i.valor_inadimplente, 0) / f.valor_faturado) * 100,
            2
        )
        ELSE 0
    END AS taxa_inadimplencia_percentual
FROM faturamento f
LEFT JOIN inadimplencia i
    ON i.estado = f.estado
   AND i.ano = f.ano
   AND i.mes = f.mes;
```
### 4. Explicação do Código
**Detalhamento das Colunas**

- **estado**

    Unidade geográfica do cliente, utilizada para análise regional da inadimplência.

- **ano / mes**
    Chaves temporais que permitem análise histórica e comparação ao longo do tempo.

- **valor_faturado**
    Soma do valor das notas fiscais emitidas no período por estado, representando o faturamento bruto.

- **valor_inadimplente**
    Soma dos valores em aberto (contas vencidas ou não pagas) no período.

- **taxa_inadimplencia_percentual**
    Percentual que representa a proporção do valor inadimplente em relação ao faturamento total do estado no período.

**Tabelas e Views Utilizadas**

- **vendas.nota_fiscal**

    Fonte primária do faturamento realizado.

- **data_warehouse.dim_cliente**

    Dimensão responsável por fornecer a informação geográfica (estado).

- **data_warehouse.dim_tempo**

    Dimensão temporal utilizada para padronização de datas.

- **data_warehouse.vw_inadimplencia_cliente**

    View base que consolida os títulos em atraso por cliente, vencimento e estado.

### 5. Resultados Esperados
**Descrição dos Resultados**

A view retorna, para cada **estado e período**, o faturamento total, o valor inadimplente e a taxa percentual de inadimplência, permitindo análises comparativas regionais.

**Formato dos Dados**

- **Valores monetários:** numéricos

- **Taxa de inadimplência:** percentual com duas casas decimais

### 6. Exemplo de Saída

| estado | ano  | mes | valor_faturado | valor_inadimplente | taxa_inadimplencia_percentual |
|--------|------|-----|----------------|---------------------|-------------------------------|
| CE     | 2017 | 10  | 1.596.285,00   | 301.539,64          | 18,89                         |
| PE     | 2017 | 10  | 985.420,00     | 95.320,10           | 9,68                          |

### 7. Análises e Insights
- Identificação de regiões com maior risco financeiro.
- Comparação proporcional entre faturamento e inadimplência
- Base sólida para visualizações geográficas
- Análise de inadimplencia por cliente
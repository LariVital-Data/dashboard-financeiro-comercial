## ABA 3 — Performance Comercial

### 1. Descrição e Objetivo

Avaliar a performance comercial dos vendedores ao longo do tempo, permitindo identificar os profissionais com melhor desempenho em termos de volume de vendas, faturamento e ticket médio.

**Contexto**

Esta análise integra o painel de Performance Comercial, cujo objetivo é responder às seguintes perguntas de negócio:

- Qual vendedor está performando melhor?

- Qual o ticket médio das vendas realizadas?
- Qual o total de vendas por ano?

A query consolida dados do schema **vendas** com as dimensões do **data warehouse corporativo**, possibilitando análises temporais e comparativas entre vendedores.

### 2. Estrutura da Query
**Código SQL**
```
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
```
### 3. Explicação do Código
**Detalhamento das Colunas**

- **id_vendedor**
    
    Identificador único do vendedor.

- **nome_vendedor**

    Nome do vendedor responsável pela venda.

- **ano / mes**

    Chaves temporais utilizadas para análise histórica e segmentação por período.

- **qtd_vendas**

    Quantidade total de notas fiscais emitidas pelo vendedor no período.

- **valor_total_vendas**

    Soma do valor das vendas realizadas pelo vendedor no período.

- **ticket_medio**

    Valor médio por venda, calculado pela divisão do faturamento total pela quantidade de vendas.

**Tabelas e Dimensões Utilizadas**

- **vendas.nota_fiscal**

    Fonte primária dos dados de vendas realizadas.

- **data_warehouse.dim_vendedor**

    Dimensão que fornece informações cadastrais do vendedor.

- **data_warehouse.dim_tempo**

    Dimensão temporal responsável por padronizar as datas de venda.

**Condições e Regras Aplicadas**

- Apenas vendas efetivadas (notas fiscais emitidas) são consideradas.

- O cálculo do ticket médio utiliza NULLIF para evitar divisão por zero.

- A granularidade da análise é mensal por vendedor.


### 4. Resultados Esperados
**Descrição dos Resultados**

A view retorna métricas consolidadas de desempenho comercial por vendedor e período, permitindo análises comparativas e identificação de padrões de performance.

**Formato dos Dados**

- Valores monetários: numéricos

- Quantidade de vendas: inteiro

- Ticket médio: numérico com duas casas decimais

### 5. Exemplo de Saída
| id_vendedor | nome_vendedor | ano  | mes | qtd_vendas | valor_total_vendas | ticket_medio |
|-------------|---------------|------|-----|------------|---------------------|--------------|
| 1           | João Silva    | 2017 | 10  | 42         | 385.420,00          | 9.176,67     |
| 2           | Maria Souza   | 2017 | 10  | 35         | 298.315,00          | 8.523,29     |


### 6. Análises e Insights — Performance Comercial

A partir da análise dos dados de performance comercial, foi possível extrair os seguintes insights:

- Identificação dos vendedores com maior volume de vendas e maior faturamento, permitindo avaliar a performance individual da equipe comercial.
- Comparação temporal do desempenho comercial, possibilitando a análise da evolução das vendas ao longo dos períodos analisados.
- Avaliação do perfil de vendas, considerando volume, valor total e ticket médio.
- Análise evolutiva do ticket médio ao longo dos anos.

**Obs:** A análise evolutiva do ticket médio revelou uma **queda no ano de 2016**, quando comparado a 2015. Em 2015, o ticket médio era de 744.247, enquanto em 2016 passou para 735.084. À primeira vista, esse comportamento poderia indicar uma redução na performance comercial. No entanto, uma análise mais aprofundada dos indicadores demonstra um cenário distinto.

No mesmo período, observou-se um **aumento no faturamento total**, com crescimento aproximado de 610.429, além de um **crescimento no volume de vendas**, que passou de 5.310 vendas em 2015 para 5.500 vendas em 2016. Esses dados indicam que o crescimento do faturamento não acompanhou, na mesma proporção, o aumento da quantidade de vendas.

Esse comportamento evidencia uma **diluição do valor médio por venda**, caracterizando uma mudança no perfil comercial. Tal cenário pode estar associado à ampliação da base de clientes, à realização de vendas de menor valor unitário ou à adoção de uma estratégia comercial orientada a volume.

Dessa forma, a redução do ticket médio não representa uma perda de desempenho comercial, mas sim uma **alteração no mix de vendas**, na qual o crescimento do negócio ocorreu por meio de maior frequência de vendas com valores unitários ligeiramente menores. Esse tipo de comportamento é comum em cenários de expansão de mercado e, de forma isolada, não configura um risco para o negócio, desde que acompanhado por crescimento do faturamento e controle da inadimplência.

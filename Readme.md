# Projeto Final — Análise Financeira e Comercial  
**Módulo SQL | Trabalho de Conclusão**

---

## 1. Visão Geral

Este projeto tem como objetivo o desenvolvimento de um **ambiente analítico financeiro-comercial**, utilizando um banco de dados corporativo estendido com um **Data Warehouse** e um **schema financeiro**, com foco em análise de fluxo de caixa, inadimplência e performance comercial.

A solução foi construída a partir de dados transacionais provenientes dos schemas **vendas**, **financeiro** e **geral**, integrados e modelados em um **schema data_warehouse**, permitindo análises estratégicas por meio de **views analíticas** e visualizações em dashboard.

O trabalho foi desenvolvido como **trabalho de conclusão do módulo SQL**, aplicando conceitos de modelagem dimensional, criação de fatos e dimensões, agregações analíticas e organização de métricas de negócio.

---

## 2. Objetivos do Projeto

O projeto foi estruturado para responder a três grandes objetivos de negócio:

### 🔹 Objetivo 1 — Análise de Fluxo de Caixa Consolidado
- Avaliar entradas e saídas financeiras por período
- Analisar o saldo realizado e projetado
- Apoiar decisões de curto e médio prazo (30/60/90 dias)

### 🔹 Objetivo 2 — Gestão de Inadimplência
- Identificar valores inadimplentes
- Calcular taxa de inadimplência por região
- Apoiar políticas de crédito e cobrança

### 🔹 Objetivo 3 — Performance Comercial
- Avaliar desempenho de vendedores
- Analisar volume de vendas, faturamento e ticket médio
- Apoiar a gestão estratégica da área comercial

---

## 3. Arquitetura de Dados

O projeto está organizado em múltiplos schemas, cada um com uma responsabilidade clara:

### 📁 Schemas Utilizados

- **vendas**  
  Contém dados transacionais de vendas, como notas fiscais, parcelas e produtos.

- **financeiro**  
  Armazena informações de contas a pagar, contas a receber e situação dos títulos.

- **geral**  
  Fonte original de dados cadastrais de clientes (pessoa física e jurídica).

- **data_warehouse**  
  Schema analítico criado para o projeto, contendo:
  - Dimensões (cliente, vendedor, tempo, produto, forma de pagamento)
  - Views analíticas para suporte a dashboards

---

## 4. Modelagem Analítica

A modelagem adotada segue os princípios de **modelagem dimensional**, com separação clara entre:

- **Dimensões**  
  Cliente, Vendedor, Tempo, Produto, Forma de Pagamento

- **Fatos e Views Analíticas**  
  Vendas, Fluxo de Caixa, Inadimplência, Performance Comercial

As **views** foram criadas no schema `data_warehouse` com o objetivo de:
- Centralizar regras de negócio
- Simplificar o consumo dos dados no Power BI
- Garantir consistência nos cálculos dos KPIs

---

## 5. Ferramentas e Tecnologias Utilizadas

- **Banco de Dados:** PostgreSQL  
- **Modelagem:** Data Warehouse (modelo dimensional)
- **Linguagem:** SQL
- **Visualização:** Power BI
- **Documentação:** Markdown

---

## 6. Organização dos Dashboards

O dashboard final foi dividido em três abas principais:

1. **Visão Geral / Fluxo de Caixa**  
   KPIs financeiros, fluxo de caixa mensal, saldo projetado e DSO.

2. **Gestão de Inadimplência**  
   Inadimplência por estado, ranking de clientes inadimplentes e indicadores de risco.

3. **Performance Comercial**  
   Análise de vendas por vendedor, ticket médio e volume de vendas.

Cada aba foi documentada individualmente, detalhando:
- Objetivo de negócio
- View(s) utilizadas
- Métricas apresentadas
- Insights gerados

---

## 7. Premissas e Limitações

- O banco de dados contém apenas **vendas efetivadas** (notas fiscais).
- Não há tabela de metas comerciais.
- Não existe segmentação de clientes além do estado.
- As regras de negócio foram **simuladas** para fins acadêmicos.

---

## 8. Resultados Esperados

Ao final do projeto, espera-se:
- Um ambiente analítico consistente e organizado
- Dashboards claros, objetivos e orientados a decisão
- Aplicação prática dos conceitos de SQL e Data Warehouse
- Documentação técnica padronizada e reutilizável

---

## 9. Considerações Finais

Este projeto demonstra como o uso adequado de SQL, modelagem dimensional e boas práticas de organização de dados pode transformar dados transacionais em **informação estratégica**, apoiando decisões financeiras e comerciais de forma clara, confiável e escalável.

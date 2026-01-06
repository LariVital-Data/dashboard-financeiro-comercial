-- Table: financeiro.conta_receber

-- DROP TABLE IF EXISTS financeiro.conta_receber;

CREATE TABLE IF NOT EXISTS financeiro.conta_receber
(
    id integer NOT NULL DEFAULT nextval('financeiro.conta_receber_id_seq'::regclass),
    id_parcela bigint NOT NULL,
    vencimento date NOT NULL,
    valor_original numeric(18,2) NOT NULL,
    valor_atual numeric(18,2) NOT NULL,
    id_situacao integer NOT NULL,
    criado_em timestamp with time zone NOT NULL DEFAULT now(),
    atualizado_em timestamp with time zone NOT NULL DEFAULT now(),
    data_recebimento date,
    id_forma_pagamento integer,
    CONSTRAINT conta_receber_pkey PRIMARY KEY (id),
    CONSTRAINT conta_receber_id_parcela_key UNIQUE (id_parcela),
    CONSTRAINT conta_receber_id_parcela_fkey FOREIGN KEY (id_parcela)
        REFERENCES vendas.parcela (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT conta_receber_id_situacao_fkey FOREIGN KEY (id_situacao)
        REFERENCES financeiro.situacao_titulo (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_conta_receber_forma_pagamento FOREIGN KEY (id_forma_pagamento)
        REFERENCES vendas.forma_pagamento (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT conta_receber_valor_original_check CHECK (valor_original > 0::numeric)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS financeiro.conta_receber
    OWNER to postgres;
-- Table: financeiro.conta_pagar

-- DROP TABLE IF EXISTS financeiro.conta_pagar;

CREATE TABLE IF NOT EXISTS financeiro.conta_pagar
(
    id integer NOT NULL DEFAULT nextval('financeiro.conta_pagar_id_seq'::regclass),
    documento text COLLATE pg_catalog."default",
    emissao date NOT NULL DEFAULT now(),
    vencimento date NOT NULL,
    valor_original numeric(18,2) NOT NULL,
    valor_atual numeric(18,2) NOT NULL,
    id_situacao integer NOT NULL,
    criado_em timestamp with time zone NOT NULL DEFAULT now(),
    atualizado_em timestamp with time zone NOT NULL DEFAULT now(),
    data_pagamento date,
    id_forma_pagamento integer,
    descricao text COLLATE pg_catalog."default",
    CONSTRAINT conta_pagar_pkey PRIMARY KEY (id),
    CONSTRAINT conta_pagar_id_situacao_fkey FOREIGN KEY (id_situacao)
        REFERENCES financeiro.situacao_titulo (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_conta_pagar_forma_pagamento FOREIGN KEY (id_forma_pagamento)
        REFERENCES vendas.forma_pagamento (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT conta_pagar_valor_original_check CHECK (valor_original > 0::numeric)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS financeiro.conta_pagar
    OWNER to postgres;
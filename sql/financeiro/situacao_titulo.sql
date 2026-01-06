-- Table: financeiro.situacao_titulo

-- DROP TABLE IF EXISTS financeiro.situacao_titulo;

CREATE TABLE IF NOT EXISTS financeiro.situacao_titulo
(
    id integer NOT NULL DEFAULT nextval('financeiro.situacao_titulo_id_seq'::regclass),
    descricao text COLLATE pg_catalog."default",
    CONSTRAINT situacao_titulo_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS financeiro.situacao_titulo
    OWNER to postgres;
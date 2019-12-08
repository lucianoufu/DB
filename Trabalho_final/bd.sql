CREATE TABLE public.tb_cliente (
	id_cliente 		 integer     NOT NULL,
	nome 			 varchar(40) NOT NULL,
	dt_nascimento 	 date 		 NOT NULL,
	endereco 		 varchar(40) 	 NULL,
	cidade 			 varchar(40)     NULL,
	cep 			 varchar(9) 	 NULL,
	telefone_contato varchar(14) NOT NULL,
	cpf int8 					 NOT NULL,
	rg 				 varchar(13) NOT NULL,
	CONSTRAINT tb_cliente_pk PRIMARY KEY (id_cliente)
);


CREATE TABLE public.tb_carros (
	id_carro 		  integer     NOT NULL,
	modelo 			  varchar(15) NOT NULL,
	dt_ultima_revisao date 			  NULL,
	dt_de_lancamento  date 			  NULL,
	motorizacao       integer 		  NULL,
	tanque            integer 		  NULL,
	CONSTRAINT tb_carros_pk PRIMARY KEY (id_carro)
);


CREATE TABLE public.tb_venda (
	id_carro   integer   NOT NULL,
	id_cliente integer   NOT NULL,
	dt_venda   timestamp NOT NULL,
	quantidade integer   NOT NULL,
	valor      integer   NOT NULL,
	CONSTRAINT tb_venda_fk   FOREIGN KEY (id_carro)   REFERENCES public.tb_carros(id_carro),
	CONSTRAINT tb_venda_fk_1 FOREIGN KEY (id_cliente) REFERENCES public.tb_cliente(id_cliente)
);


CREATE TABLE public.tb_estoque (
	id_carro   integer NOT NULL,
	quantidade integer NOT NULL
);
ALTER TABLE public.tb_estoque ADD CONSTRAINT tb_estoque_fk FOREIGN KEY (id_carro) REFERENCES public.tb_carros(id_carro);


--AUDITORIAS

--Auditoria para tabela tb_clientes

CREATE TABLE tb_cliente_auditoria
(
	operacao 		 VARCHAR(7)  NOT NULL,
	usuario 		 VARCHAR     NOT NULL,
	data_alteracao   Timestamp   NOT NULL,
	id_cliente 		 integer     NOT NULL,
	nome 			 varchar(40) NOT NULL,
	dt_nascimento 	 date        NOT NULL,
	endereco 		 varchar(40)     NULL,
	cidade 			 varchar(40)     NULL,
	cep 		     varchar(9)      NULL,
	telefone_contato varchar(14) NOT NULL,
	cpf 			 int8        NOT NULL,
	rg 				 varchar(13) NOT NULL
);

CREATE OR REPLACE FUNCTION fn_cliente_auditoria() RETURNS Trigger AS
$$
	BEGIN
		IF(tg_op = 'DELETE')    THEN
			INSERT INTO tb_cliente_auditoria SELECT 'DELETE', user, now(), old.*;
		ELSIF(tg_op = 'UPDATE') THEN
			INSERT INTO tb_cliente_auditoria SELECT 'UPDATE', user, now(), new.*;
			RETURN new;
		ELSIF(tg_op = 'INSERT') THEN
			INSERT INTO tb_cliente_auditoria SELECT 'INSERT', user, now(), new.*;
			RETURN new;
		END IF;
		RETURN NULL;
	END
$$
LANGUAGE plpgsql;

CREATE TRIGGER tb_cliente_auditoria AFTER INSERT OR UPDATE OR DELETE ON tb_cliente FOR EACH ROW EXECUTE PROCEDURE fn_cliente_auditoria();

--Auditoria para tb_carros

CREATE TABLE tb_carros_auditoria
(
	operacao 		  VARCHAR(7)  NOT NULL,
	usuario 		  VARCHAR     NOT NULL,
	data_alteracao    Timestamp   NOT NULL,
	id_carro 		  integer     NOT NULL,
	modelo 			  varchar(15) NOT NULL,
	dt_ultima_revisao date 			  NULL,
	dt_de_lancamento  date 			  NULL,
	motorizacao       integer 		  NULL,
	tanque            integer 		  NULL
);


CREATE OR REPLACE FUNCTION fn_carros_auditoria() RETURNS Trigger AS
$$
	BEGIN
		IF(tg_op = 'DELETE')    THEN
			INSERT INTO tb_carros_auditoria SELECT 'DELETE', user, now(), old.*;
		ELSIF(tg_op = 'UPDATE') THEN
			INSERT INTO tb_carros_auditoria SELECT 'UPDATE', user, now(), new.*;
			RETURN new;
		ELSIF(tg_op = 'INSERT') THEN
			INSERT INTO tb_carros_auditoria SELECT 'INSERT', user, now(), new.*;
			RETURN new;
		END IF;
		RETURN NULL;
	END
$$
LANGUAGE plpgsql;

CREATE TRIGGER tb_carros_auditoria AFTER INSERT OR UPDATE OR DELETE ON tb_carros FOR EACH ROW EXECUTE PROCEDURE fn_carros_auditoria();

--Auditoria para tb_venda

CREATE TABLE tb_venda_auditoria
(
	operacao 		 VARCHAR(7) NOT NULL,
	usuario 		 VARCHAR NOT NULL,
	data_alteracao   Timestamp NOT NULL,
	id_carro   integer   NOT NULL,
	id_cliente integer   NOT NULL,
	dt_venda   timestamp NOT NULL,
	quantidade integer   NOT NULL,
	valor      integer   NOT NULL
);


CREATE OR REPLACE FUNCTION fn_venda_auditoria() RETURNS Trigger AS
$$
	BEGIN
		IF(tg_op = 'DELETE') THEN
			INSERT INTO tb_venda_auditoria SELECT 'DELETE', user, now(), old.*;
		ELSIF(tg_op = 'UPDATE') THEN
			INSERT INTO tb_venda_auditoria SELECT 'UPDATE', user, now(), new.*;
			RETURN new;
		ELSIF(tg_op = 'INSERT') THEN
			INSERT INTO tb_venda_auditoria SELECT 'INSERT', user, now(), new.*;
			RETURN new;
		END IF;
		RETURN NULL;
	END
$$
LANGUAGE plpgsql;

CREATE TRIGGER tb_venda_auditoria AFTER INSERT OR UPDATE OR DELETE ON tb_venda FOR EACH ROW EXECUTE PROCEDURE fn_venda_auditoria();

--Auditoria para tb_estoque

CREATE TABLE tb_estoque_auditoria
(
	operacao 		 VARCHAR(7) NOT NULL,
	usuario 		 VARCHAR NOT NULL,
	data_alteracao   Timestamp NOT NULL,
	id_carro   integer NOT NULL,
	quantidade integer NOT NULL
);


CREATE OR REPLACE FUNCTION fn_estoque_auditoria() RETURNS Trigger AS
$$
	BEGIN
		IF(tg_op = 'DELETE') THEN
			INSERT INTO tb_estoque_auditoria SELECT 'DELETE', user, now(), old.*;
		ELSIF(tg_op = 'UPDATE') THEN
			INSERT INTO tb_estoque_auditoria SELECT 'UPDATE', user, now(), new.*;
			RETURN new;
		ELSIF(tg_op = 'INSERT') THEN
			INSERT INTO tb_estoque_auditoria SELECT 'INSERT', user, now(), new.*;
			RETURN new;
		END IF;
		RETURN NULL;
	END
$$
LANGUAGE plpgsql;

CREATE TRIGGER tb_estoque_auditoria AFTER INSERT OR UPDATE OR DELETE ON tb_venda FOR EACH ROW EXECUTE PROCEDURE fn_estoque_auditoria();

--Funções

CREATE OR REPLACE FUNCTION fn_alterar_usuario (p_opcao VARCHAR,ant_nome varchar(40), p_id_cliente integer, p_nome varchar(40), p_dt_nascimento date, p_endereco varchar(40), p_cidade varchar(40), p_cep varchar(9), p_telefone_contato varchar(14), p_cpf int8, p_rg varchar(13)) RETURNS TEXT AS
$$
  BEGIN 
     IF (p_opcao = 'I') THEN
	 	INSERT INTO tb_cliente VALUES (p_id_cliente, p_nome, p_dt_nascimento, p_endereco, p_cidade, p_cep, p_telefone_contato, p_cpf int8, p_rg);
		RETURN 'Cliente inserido com sucesso!';
	ELSIF (p_opcao = 'A') THEN	
		UPDATE 	tb_cliente SET  nome = p_nome, idade = p_idade, genero = p_genero, endereco = p_endereco, cidade = p_cidade, cep = p_cep, telefone_contato = p_telefone_contato, id_cliente = p_id_cliente WHERE nome = ant_nome;
		RETURN 'Cliente alterado com sucesso';
	ELSIF (p_opcao = 'D') THEN
		DELETE FROM tb_cliente WHERE nome = ant_nome;
		IF NOT  FOUND THEN
			RAISE EXCEPTION 'Cliente não encontrado';
		ELSE
			RETURN 'Cliente deletado com sucesso';
		END IF;
	ELSE
		RETURN 'A sua função não funcionou';
	END IF;
END	 
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fn_alterar_carro (p_opcao VARCHAR,ant_modelo varchar(40), p_id_carro integer, p_modelo varchar(15), p_dt_ultima_revisao date, p_dt_de_lancamento  date, p_motorizacao integer, p_tanque integer) RETURNS TEXT AS
$$
  BEGIN 
     IF (p_opcao = 'I') THEN
	 	INSERT INTO tb_cliente VALUES (p_id_carro, p_modelo, p_dt_ultima_revisao, p_dt_de_lancamento, p_motorizacao, p_tanque);
		RETURN 'Carro inserido com sucesso!';
	ELSIF (p_opcao = 'A') THEN	
		UPDATE 	tb_cliente SET  id_carro = p_id_carro, modelo = p_modelo, dt_ultima_revisao = p_dt_ultima_revisao, dt_de_lancamento = p_dt_de_lancamento, motorizacao = p_motorizacao, tanque = p_tanque WHERE modelo = ant_modelo;
		RETURN 'Carro alterado com sucesso';
	ELSIF (p_opcao = 'D') THEN
		DELETE FROM tb_cliente WHERE modelo = ant_modelo;
		IF NOT  FOUND THEN
			RAISE EXCEPTION 'Carro não encontrado';
		ELSE
			RETURN 'Carro deletado com sucesso';
		END IF;
	ELSE
		RETURN 'A sua função não funcionou';
	END IF;
END	 
$$
LANGUAGE PLPGSQL;

--Joins

--Clientes que compraram algum carro.
CREATE VIEW cliente_carro AS
(
	SELECT nome,modelo FROM tb_cliente INNER JOIN tb_venda ON tb_cliente.id_cliente = tb_venda.id_cliente
);

--Relação de carros e estoque
CREATE VIEW carros_estoque AS
(
	SELECT * FROM tb_estoque RIGHT JOIN tb_carros ON tb_estoque.id_carro = tb_carros.id_carro
)

--Segurança

CREATE GROUP administradores;
CREATE GROUP vendedores;
CREATE GROUP trab_estoque;

REVOKE ALL ON tb_carros            FROM GROUP vendedores;
REVOKE ALL ON tb_cliente           FROM GROUP vendedores;
REVOKE ALL ON tb_venda             FROM GROUP vendedores;
REVOKE ALL ON tb_estoque           FROM GROUP vendedores;
REVOKE ALL ON tb_carros_auditoria  FROM GROUP vendedores;
REVOKE ALL ON tb_cliente_auditoria FROM GROUP vendedores;
REVOKE ALL ON tb_estoque_auditoria FROM GROUP vendedores;
REVOKE ALL ON tb_venda_auditoria   FROM GROUP vendedores;
REVOKE ALL ON tb_carros_auditoria  FROM GROUP vendedores;
REVOKE ALL ON tb_cliente_auditoria FROM GROUP administradores;
REVOKE ALL ON tb_estoque_auditoria FROM GROUP administradores;
REVOKE ALL ON tb_venda_auditoria   FROM GROUP administradores;
REVOKE ALL ON tb_carros            FROM GROUP trab_estoque;
REVOKE ALL ON tb_cliente           FROM GROUP trab_estoque;
REVOKE ALL ON tb_venda             FROM GROUP trab_estoque;
REVOKE ALL ON tb_estoque           FROM GROUP trab_estoque;

GRANT ALL    ON tb_cliente TO GROUP administradores;
GRANT ALL    ON tb_estoque TO GROUP administradores;
GRANT ALL    ON tb_carros  TO GROUP administradores;
GRANT ALL    ON tb_venda   TO GROUP administradores;
GRANT INSERT ON tb_cliente TO GROUP vendedores;
GRANT ALL    ON tb_venda   TO GROUP vendedores;
GRANT UPDATE ON tb_estoque TO GROUP trab_estoque;

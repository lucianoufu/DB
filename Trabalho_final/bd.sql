CREATE TABLE public.tb_cliente (
	nome                     varchar(60) NOT NULL,
	idade                    integer     NOT NULL,
	genero                   char(1)     NOT NULL,
	endereco                 varchar(20) NOT NULL,
	cidade                   varchar(10) NOT NULL,
	cep                      integer     NOT NULL,
	telefone_contato         integer     NOT NULL,
	id_cliente               integer     NOT NULL,
	CONSTRAINT tb_cliente_pk PRIMARY KEY (id_cliente)
);

ALTER TABLE public.tb_cliente ALTER COLUMN telefone_contato TYPE varchar(20) USING telefone_contato::varchar;


CREATE TABLE public.tb_carros (
	id_carro 						integer 	NOT NULL,
	condição 						varchar(5)  NOT NULL,
	cor 							varchar(10) NOT NULL,
	kilometragem float8 						NOT NULL,
	ano_de_fabricacao   			integer 	NOT NULL,
	dt_revisao 						date 			NULL,
	largura float8 								NOT NULL,
	comprimento float4 							NOT NULL,
	altura float4 								NOT NULL,
	comprimento_entre_eixos float4 					NULL,
	"Motorização(cv)"   			integer 	NOT NULL,
	"tanque(L)" 	    			varchar 	NOT NULL,
	CONSTRAINT tb_carros_pk PRIMARY KEY (id_carro)
);
ALTER TABLE public.tb_cliente ALTER COLUMN endereco TYPE varchar(50) USING endereco::varchar;
ALTER TABLE public.tb_carros ADD modelo varchar(50);
ALTER TABLE public.tb_carros ALTER COLUMN condição TYPE varchar(10) USING condição::varchar;


CREATE TABLE public.tb_venda (
	id_carro 	integer NOT NULL,
	id_cliente  integer     NULL,
	data_venda  date    NOT NULL,
	quantidade  integer NOT NULL,
	valor float4 		NOT NULL,
	CONSTRAINT tb_venda_fk   FOREIGN KEY (id_carro)   REFERENCES public.tb_carros(id_carro),
	CONSTRAINT tb_venda_fk_1 FOREIGN KEY (id_cliente) REFERENCES public.tb_cliente(id_cliente)
);

ALTER TABLE public.tb_venda ALTER COLUMN data_venda TYPE timestamp USING data_venda::timestamp;

ALTER TABLE public.tb_venda DROP CONSTRAINT tb_venda_fk;
ALTER TABLE public.tb_venda ADD  CONSTRAINT tb_venda_fk   FOREIGN KEY (id_carro)   REFERENCES public.tb_carros(id_carro);
ALTER TABLE public.tb_venda ADD  CONSTRAINT tb_venda_fk_2 FOREIGN KEY (id_cliente) REFERENCES public.tb_cliente(id_cliente);
ALTER TABLE public.tb_venda DROP CONSTRAINT tb_venda_fk_2;
ALTER TABLE public.tb_venda DROP CONSTRAINT tb_venda_fk_1;
ALTER TABLE public.tb_venda ADD  CONSTRAINT tb_venda_fk_1 FOREIGN KEY (id_cliente) REFERENCES public.tb_cliente(id_cliente);
--Adição da coluna modelo na tabela tb_carros
ALTER TABLE public.tb_carros ADD modelo varchar NOT NULL;

CREATE TABLE public.tb_estoque (
	quantidade integer NOT NULL,
	id_carro integer NOT NULL,
	CONSTRAINT tb_estoque_fk FOREIGN KEY (id_carro) REFERENCES public.tb_carros(id_carro)
);


CREATE OR REPLACE FUNCTION fn_usuario (p_opcao VARCHAR,p_nome VARCHAR, nome VARCHAR, novo_nome varchar,nova_idade integer, novo_genero char, novo_endereco varchar, novo_cidade varchar, novo_cep integer, novo_telefone_contato integer, novo_id_cliente integer) RETURNS TEXT AS
$$
  BEGIN 
     IF (p_opcao = 'I') THEN
	 	INSERT INTO tb_cliente VALUES (novo_nome, nova_idade, novo_genero, novo_endereco, novo_cidade, novo_cep, novo_telefone_contato, novo_id_cliente);
		RETURN 'Valor inserido com sucesso!';
	ELSIF (p_opcao = 'A') THEN	
		UPDATE 	tb_cliente SET  nome = novo_nome, idade = nova_idade, genero = novo_genero, endereco = novo_endereco, cidade = novo_cidade, cep = novo_cep, telefone_contato = novo_telefone_contato, id_cliente = novo_id_cliente WHERE nome = p_nome;
		RETURN 'valor alterado com sucesso';
	ELSIF (p_opcao = 'D') THEN
		DELETE FROM tb_cliente WHERE nome = p_nome;
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

CREATE TABLE public.tb_venda_auditoria (
	operacao    varchar NOT NULL,
	usuario     varchar NOT NULL,
	id_carro 	integer NOT NULL,
	id_cliente  integer     NULL,
	data_venda  date    NOT NULL,
	quantidade  integer NOT NULL,
	valor float4 		NOT NULL
	
);

CREATE OR REPLACE FUNCTION fn_venda_auditoria() RETURNS Trigger AS
$$
	BEGIN
		IF(tg_op = 'DELETE') THEN
			INSERT INTO tb_venda_auditoria SELECT 'DELETE', user, old.*;
			RETURN old;
		ELSIF(tg_op = 'INSERT') THEN
			INSERT INTO tb_venda_auditoria SELECT 'INSERT', user, new.*;
			RETURN New;
		ELSIF(tg_op = 'UPDATE') THEN
			INSERT INTO tb_venda_auditoria SELECT 'UPDATE', user, new.*;
			RETURN New;
		END IF;
		RETURN NULL;
	END
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER tb_venda_auditoria AFTER INSERT OR UPDATE OR DELETE ON tb_venda FOR EACH ROW EXECUTE PROCEDURE fn_venda_auditoria();


--Criação de usuários
--Usuário vendedor
CREATE USER vendedor
REVOKE ALL ON tb_carros FROM vendedor
REVOKE ALL ON tb_cliente FROM vendedor
GRANT SELECT, INSERT ON tb_cliente TO vendedor

--Administrador
CREATE USER administrador_bd

--INSERÇÃO DE VALORES

--Inserção de dados na tabela tb_cliente
INSERT INTO tb_cliente VALUES('Vinícius',22,'M','Rua José Andrasso - Bairro Martins 532','Uberlândia',38400340,'(34) 988476057',1)
INSERT INTO tb_cliente VALUES('Luciano',19,'M','Av Espacial - Bairro Jd.Ipanema 699','Uberlândia',38406289,'(34) 984027219',2)
INSERT INTO tb_cliente VALUES('Izabela',19,'M','Rua José Fonseca e Silva - Bairro Martins 702','Uberlândia',3840513,'(34) 945678013',3)
INSERT INTO tb_cliente VALUES('Gustavo',28,'M','Av. Araguari - Bairro Roosevelt 742','Uberlândia',3840520,'(34) 989769813',4)
INSERT INTO tb_cliente VALUES('Augosta',22,'M','Rua Uberlândia - Bairro Brasil 532','Araguari',38400654,'(34) 913791559',5)

--Inserção de dados na tabela tb_carros
INSERT INTO tb_carros VALUES(1,'Novo','Branco',0,20-03-2019,'20-03-2019',4,12,8,4,350,3000,'X5')
INSERT INTO tb_carros VALUES(2,'Usado','Azul',48000,28-09-2003,'11-01-2018',4,12,8,4,350,3000,'X5 (E70)')
INSERT INTO tb_carros VALUES(3,'Novo','Vermelho',0,14-07-2019,'14-07-2019',4,12,8,4,350,3000,'M3')
INSERT INTO tb_carros VALUES(4,'Usando','Branco',89000,13-04-2003,'10-03-2017',4,12,8,4,350,3000,'M3-GTR')
INSERT INTO tb_carros VALUES(5,'Novo','Cinza',0,20-03-2019,'20-03-2019',4,12,8,4,350,3000,'i8')

--Inserção de valores na tabela tb_venda
INSERT INTO tb_venda VALUES (1,1,'13-07-2019',1,320000)
INSERT INTO tb_venda VALUES (2,4,'03-11-2019',1,92000)
INSERT INTO tb_venda VALUES (3,3,'16-03-2019',1,122000)
INSERT INTO tb_venda VALUES (4,2,'28-05-2019',1,101000)
INSERT INTO tb_venda VALUES (5,5,'04-01-2019',1,590000)



--Inserção de dados na tabela tb_estoque
INSERT INTO tb_estoque VALUES (20,1)
INSERT INTO tb_estoque VALUES (10,2)
INSERT INTO tb_estoque VALUES (15,3)
INSERT INTO tb_estoque VALUES (30,4)
INSERT INTO tb_estoque VALUES (35,5)

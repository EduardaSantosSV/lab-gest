--
-- PostgreSQL database dump
--

\restrict kblvnDLqLKovr0Ws0EgRuCIzSEOE0kz3qFbEcVKSwMhVEe1WirkNPmfESYbJeFC

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_equipamento_ativo_apos_conclusao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_equipamento_ativo_apos_conclusao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'concluido' AND OLD.status <> 'concluido' THEN
        UPDATE equipamentos
        SET status = 'ativo'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: fn_equipamento_em_manutencao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_equipamento_em_manutencao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE equipamentos
    SET status = 'manutencao'
    WHERE id_equipamento = NEW.id_equipamento;

    RETURN NEW;
END;
$$;


--
-- Name: fn_preencher_data_fechamento(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_preencher_data_fechamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'concluido' AND OLD.status <> 'concluido' THEN
        NEW.data_fechamento = CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: fn_validar_devolucao_chave(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_validar_devolucao_chave() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status_chave = 'devolvida' THEN
        IF NEW.data_devolucao IS NULL OR NEW.hora_devolucao IS NULL THEN
            RAISE EXCEPTION 'Para status devolvida, informe data_devolucao e hora_devolucao.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agenda_labs_chave; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agenda_labs_chave (
    id_agenda integer NOT NULL,
    data_retirada date NOT NULL,
    hora_retirada time without time zone NOT NULL,
    data_devolucao date,
    hora_devolucao time without time zone,
    status_chave character varying(30) NOT NULL,
    siape_professor character(6) NOT NULL,
    id_laboratorio integer NOT NULL,
    CONSTRAINT chk_status_chave CHECK (((status_chave)::text = ANY ((ARRAY['retirada'::character varying, 'devolvida'::character varying, 'atrasada'::character varying])::text[])))
);


--
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agenda_labs_chave_id_agenda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agenda_labs_chave_id_agenda_seq OWNED BY public.agenda_labs_chave.id_agenda;


--
-- Name: aluno; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aluno (
    matricula character(10) NOT NULL,
    curso character varying(100) NOT NULL,
    semestre integer NOT NULL,
    id_usuario integer NOT NULL,
    CONSTRAINT chk_matricula_format CHECK ((matricula ~ '^[0-9]{10}$'::text))
);


--
-- Name: equipamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipamentos (
    id_equipamento integer NOT NULL,
    nome character varying(100) NOT NULL,
    tipo character varying(100),
    status character varying(50),
    descricao text,
    id_laboratorio integer NOT NULL,
    patrimonio character varying(30)
);


--
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipamentos_id_equipamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipamentos_id_equipamento_seq OWNED BY public.equipamentos.id_equipamento;


--
-- Name: laboratorio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laboratorio (
    id_laboratorio integer NOT NULL,
    bloco character varying(50),
    andar integer,
    capacidade integer
);


--
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.laboratorio_id_laboratorio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.laboratorio_id_laboratorio_seq OWNED BY public.laboratorio.id_laboratorio;


--
-- Name: ministra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ministra (
    siape_professor character(6) NOT NULL,
    id_turma integer NOT NULL
);


--
-- Name: pertence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pertence (
    matricula_aluno character(10) NOT NULL,
    id_turma integer NOT NULL
);


--
-- Name: professor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professor (
    siape character(6) NOT NULL,
    curso character varying(100) NOT NULL,
    departamento character varying(100) NOT NULL,
    id_usuario integer,
    CONSTRAINT chk_siape_6_numeros CHECK ((siape ~ '^[0-9]{6}$'::text))
);


--
-- Name: solicitacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitacao (
    id_solicitacao integer NOT NULL,
    data_abertura timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_fechamento timestamp without time zone,
    descricao text NOT NULL,
    tipo_solicitacao character varying(50) NOT NULL,
    status character varying(30) NOT NULL,
    id_usuario_solicitante integer NOT NULL,
    cpf_tecnico_responsavel character(11),
    id_equipamento integer NOT NULL,
    CONSTRAINT chk_status_solicitacao CHECK (((status)::text = ANY ((ARRAY['aberto'::character varying, 'em atendimento'::character varying, 'concluido'::character varying, 'cancelado'::character varying])::text[])))
);


--
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solicitacao_id_solicitacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solicitacao_id_solicitacao_seq OWNED BY public.solicitacao.id_solicitacao;


--
-- Name: tecnico_ti; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tecnico_ti (
    cpf character(11) NOT NULL,
    id_usuario integer NOT NULL,
    CONSTRAINT chk_cpf_formato CHECK ((cpf ~ '^[0-9]{11}$'::text))
);


--
-- Name: turma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turma (
    id_turma integer NOT NULL,
    curso character varying(100) NOT NULL,
    disciplina character varying(100) NOT NULL,
    semestre integer NOT NULL,
    ano integer NOT NULL
);


--
-- Name: turma_id_turma_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.turma_id_turma_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: turma_id_turma_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.turma_id_turma_seq OWNED BY public.turma.id_turma;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    tipo_usuario character varying(20),
    senha character varying(255)
);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- Name: utiliza; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utiliza (
    id_turma integer NOT NULL,
    id_equipamento integer NOT NULL,
    id_laboratorio integer NOT NULL
);


--
-- Name: agenda_labs_chave id_agenda; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agenda_labs_chave ALTER COLUMN id_agenda SET DEFAULT nextval('public.agenda_labs_chave_id_agenda_seq'::regclass);


--
-- Name: equipamentos id_equipamento; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipamentos ALTER COLUMN id_equipamento SET DEFAULT nextval('public.equipamentos_id_equipamento_seq'::regclass);


--
-- Name: laboratorio id_laboratorio; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laboratorio ALTER COLUMN id_laboratorio SET DEFAULT nextval('public.laboratorio_id_laboratorio_seq'::regclass);


--
-- Name: solicitacao id_solicitacao; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao ALTER COLUMN id_solicitacao SET DEFAULT nextval('public.solicitacao_id_solicitacao_seq'::regclass);


--
-- Name: turma id_turma; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma ALTER COLUMN id_turma SET DEFAULT nextval('public.turma_id_turma_seq'::regclass);


--
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- Data for Name: agenda_labs_chave; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agenda_labs_chave (id_agenda, data_retirada, hora_retirada, data_devolucao, hora_devolucao, status_chave, siape_professor, id_laboratorio) FROM stdin;
1	2026-07-01	07:30:00	2026-07-01	11:30:00	devolvida	123456	1
2	2026-07-01	13:00:00	2026-07-01	17:00:00	devolvida	234567	2
3	2026-07-02	08:00:00	2026-07-02	12:00:00	devolvida	345678	3
4	2026-07-02	14:00:00	\N	\N	retirada	456789	4
5	2026-07-03	07:45:00	2026-07-03	10:30:00	devolvida	567890	5
6	2026-07-03	13:30:00	\N	\N	retirada	678901	6
7	2026-07-04	08:10:00	2026-07-04	11:50:00	devolvida	789012	7
8	2026-07-04	14:20:00	\N	\N	atrasada	890123	8
9	2026-07-05	07:55:00	2026-07-05	12:10:00	devolvida	901234	9
10	2026-07-05	13:10:00	\N	\N	retirada	112233	10
11	2026-07-01	07:30:00	2026-07-01	11:30:00	devolvida	123456	1
12	2026-07-01	13:00:00	2026-07-01	17:00:00	devolvida	234567	2
13	2026-07-02	08:00:00	2026-07-02	12:00:00	devolvida	345678	3
14	2026-07-02	14:00:00	\N	\N	retirada	456789	4
15	2026-07-03	07:45:00	2026-07-03	10:30:00	devolvida	567890	5
16	2026-07-03	13:30:00	\N	\N	retirada	678901	6
17	2026-07-04	08:10:00	2026-07-04	11:50:00	devolvida	789012	7
18	2026-07-04	14:20:00	\N	\N	atrasada	890123	8
19	2026-07-05	07:55:00	2026-07-05	12:10:00	devolvida	901234	9
20	2026-07-05	13:10:00	\N	\N	retirada	112233	10
\.


--
-- Data for Name: aluno; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aluno (matricula, curso, semestre, id_usuario) FROM stdin;
2024000001	Análise e Desenvolvimento de Sistemas	1	11
2024000002	Análise e Desenvolvimento de Sistemas	2	12
2024000003	Redes de Computadores	3	13
2024000004	Sistemas de Informação	4	14
2024000005	Engenharia de Software	2	15
2024000006	Ciência da Computação	5	16
2024000007	Banco de Dados	3	17
2024000008	Segurança da Informação	4	18
2024000009	Programação Web	1	19
2024000010	Gestão de Tecnologia	2	20
\.


--
-- Data for Name: equipamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipamentos (id_equipamento, nome, tipo, status, descricao, id_laboratorio, patrimonio) FROM stdin;
2	Notebook Lenovo ThinkPad	Computador portátil	ativo	Notebook para laboratório de programação	1	PAT-1002
3	Desktop HP ProDesk	Computador desktop	ativo	Computador de bancada para alunos	2	PAT-1003
5	Servidor Dell PowerEdge	Servidor	ativo	Servidor de aplicações internas	3	PAT-1005
6	Switch Cisco 24 portas	Equipamento de rede	ativo	Switch principal do laboratório	3	PAT-1006
7	Roteador TP-Link Archer	Equipamento de rede	ativo	Roteador Wi-Fi do laboratório	4	PAT-1007
8	Impressora HP LaserJet	Periférico	ativo	Impressora compartilhada do setor	4	PAT-1008
9	Scanner Epson WorkForce	Periférico	ativo	Scanner para digitalização de documentos	5	PAT-1009
10	Projetor Epson PowerLite	Multimídia	ativo	Projetor usado em aulas	5	PAT-1010
11	Monitor LG 24 polegadas	Periférico	ativo	Monitor reserva do laboratório	6	PAT-1011
12	Teclado Logitech K120	Periférico	ativo	Teclado USB padrão	6	PAT-1012
13	Mouse Logitech M90	Periférico	ativo	Mouse USB padrão	7	PAT-1013
14	HD Externo Seagate 1TB	Armazenamento	ativo	Dispositivo para backup	8	PAT-1014
15	SSD Kingston 480GB	Armazenamento	ativo	SSD para upgrade de máquinas	9	PAT-1015
1	Notebook Dell Latitude	Computador portátil	ativo	Notebook usado em aulas práticas	1	PAT-1001
4	Desktop Dell OptiPlex	Computador desktop	manutencao	Computador com falha de inicialização	2	PAT-1004
\.


--
-- Data for Name: laboratorio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.laboratorio (id_laboratorio, bloco, andar, capacidade) FROM stdin;
1	Bloco A	1	30
2	Bloco A	2	28
3	Bloco B	1	35
4	Bloco B	2	32
5	Bloco C	1	25
6	Bloco C	2	26
7	Bloco D	1	40
8	Bloco D	2	38
9	Bloco E	1	24
10	Bloco E	2	22
11	Bloco A	1	30
12	Bloco A	2	28
13	Bloco B	1	35
14	Bloco B	2	32
15	Bloco C	1	25
16	Bloco C	2	26
17	Bloco D	1	40
18	Bloco D	2	38
19	Bloco E	1	24
20	Bloco E	2	22
\.


--
-- Data for Name: ministra; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ministra (siape_professor, id_turma) FROM stdin;
123456	1
234567	2
345678	3
456789	4
567890	5
678901	6
789012	7
890123	8
901234	9
112233	10
\.


--
-- Data for Name: pertence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pertence (matricula_aluno, id_turma) FROM stdin;
2024000001	1
2024000002	1
2024000003	2
2024000004	3
2024000005	4
2024000006	5
2024000007	6
2024000008	7
2024000009	8
2024000010	9
2024000001	10
2024000002	3
2024000005	6
2024000007	8
2024000009	10
\.


--
-- Data for Name: professor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.professor (siape, curso, departamento, id_usuario) FROM stdin;
678901	Banco de Dados	Departamento de Tecnologia	\N
789012	Segurança da Informação	Departamento de Redes	\N
890123	Programação Web	Departamento de Sistemas	\N
901234	Arquitetura de Computadores	Departamento de Hardware	\N
112233	Gestão de Tecnologia	Departamento de Administração	\N
123456	Análise e Desenvolvimento de Sistemas	Departamento de Computação	1
234567	Redes de Computadores	Departamento de Tecnologia da Informação	2
345678	Sistemas de Informação	Departamento de Computação	3
456789	Engenharia de Software	Departamento de Engenharia	4
567890	Ciência da Computação	Departamento de Computação	5
\.


--
-- Data for Name: solicitacao; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.solicitacao (id_solicitacao, data_abertura, data_fechamento, descricao, tipo_solicitacao, status, id_usuario_solicitante, cpf_tecnico_responsavel, id_equipamento) FROM stdin;
2	2026-07-10 11:34:35.631058	\N	Internet lenta no laboratório de redes	rede	em atendimento	12	22233344455	6
3	2026-07-10 11:34:35.631058	\N	Desktop reiniciando sozinho durante a aula	hardware	aberto	11	33344455566	3
4	2026-07-10 11:34:35.631058	\N	Impressora não imprime documentos enviados	periferico	em atendimento	13	44455566677	8
5	2026-07-10 11:34:35.631058	\N	Servidor apresentou falha de acesso remoto	servidor	aberto	14	55566677788	5
7	2026-07-10 11:34:35.631058	\N	Mouse desconectando durante o uso	periferico	concluido	12	77788899900	13
8	2026-07-10 11:34:35.631058	\N	Projetor sem imagem na sala de aula	multimidia	aberto	16	88899900011	10
10	2026-07-10 11:34:35.631058	\N	HD externo não reconhecido pelo computador	armazenamento	aberto	17	00011122233	14
11	2026-07-10 11:34:35.631058	\N	Roteador reiniciando constantemente	rede	aberto	18	22233344455	7
12	2026-07-10 11:34:35.631058	\N	SSD instalado não aparece no sistema	armazenamento	em atendimento	19	33344455566	15
13	2026-07-10 11:34:35.631058	\N	Notebook Lenovo com tela travando	hardware	aberto	20	11122233344	2
14	2026-07-10 11:34:35.631058	\N	Scanner não digitaliza corretamente	periferico	concluido	13	44455566677	9
15	2026-07-10 11:34:35.631058	\N	Desktop Dell com erro na inicialização	hardware	em atendimento	14	55566677788	4
16	2026-07-10 11:34:35.64465	\N	Notebook com tela piscando	hardware	aberto	11	11122233344	1
1	2026-07-10 11:34:35.631058	2026-07-10 11:34:35.646145	Notebook não liga após atualização do sistema	hardware	concluido	11	11122233344	1
9	2026-07-10 11:34:35.631058	\N	Monitor apagando após alguns minutos	hardware	em atendimento	11	99900011122	11
6	2026-07-10 11:34:35.631058	\N	Teclado com várias teclas sem funcionar	periferico	em atendimento	15	66677788899	12
\.


--
-- Data for Name: tecnico_ti; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tecnico_ti (cpf, id_usuario) FROM stdin;
11122233344	1
22233344455	2
33344455566	3
44455566677	4
55566677788	5
66677788899	6
77788899900	7
88899900011	8
99900011122	9
00011122233	10
\.


--
-- Data for Name: turma; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.turma (id_turma, curso, disciplina, semestre, ano) FROM stdin;
1	Análise e Desenvolvimento de Sistemas	Banco de Dados	2	2026
2	Análise e Desenvolvimento de Sistemas	Programação Orientada a Objetos	2	2026
3	Redes de Computadores	Infraestrutura de Redes	3	2026
4	Sistemas de Informação	Engenharia de Software	4	2026
5	Ciência da Computação	Arquitetura de Computadores	3	2026
6	Banco de Dados	Modelagem de Dados	1	2026
7	Segurança da Informação	Segurança em Redes	4	2026
8	Programação Web	HTML, CSS e JavaScript	1	2026
9	Gestão de Tecnologia	Gestão de Projetos de TI	2	2026
10	Engenharia de Software	Qualidade de Software	5	2026
11	Análise e Desenvolvimento de Sistemas	Banco de Dados	2	2026
12	Análise e Desenvolvimento de Sistemas	Programação Orientada a Objetos	2	2026
13	Redes de Computadores	Infraestrutura de Redes	3	2026
14	Sistemas de Informação	Engenharia de Software	4	2026
15	Ciência da Computação	Arquitetura de Computadores	3	2026
16	Banco de Dados	Modelagem de Dados	1	2026
17	Segurança da Informação	Segurança em Redes	4	2026
18	Programação Web	HTML, CSS e JavaScript	1	2026
19	Gestão de Tecnologia	Gestão de Projetos de TI	2	2026
20	Engenharia de Software	Qualidade de Software	5	2026
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario (id_usuario, nome, email, tipo_usuario, senha) FROM stdin;
13	Mateus Costa	mateus.costa@email.com	aluno	$2y$10$8OT1OUf7Xs.VdLvKG2KQS.0aYmHLeozpIkDLIstw1Q8x2TAUNCC9W
14	Larissa Almeida	larissa.almeida@email.com	aluno	$2y$10$1N4XZyYLzXFHCFJZTtXph.GGs4C4gkANAEPNejo/QJKvo8pQ7mV.a
15	Diego Fernandes	diego.fernandes@email.com	aluno	$2y$10$0lAxO5RXqfoWeA2ZeaGv1.2ufTqvIirG.dqYOY1x0XmDH/HkoRVQ.
16	Bianca Ribeiro	bianca.ribeiro@email.com	aluno	$2y$10$BPDbjN5CFwecl2I2GLKyZeYr8ffk3/d62rWjPLN9iR8JGelouSTLO
17	Pedro Henrique	pedro.henrique@email.com	aluno	$2y$10$MGqI7M9D8jZ2Vd0XCWf9tO4.oEwHtzxpFOKEreB/ZaJ.yhkDMCiuS
18	Amanda Carvalho	amanda.carvalho@email.com	aluno	$2y$10$/RRa50MMbWLzyIF9E7qWAO9hdskmvfUogESJf0SD71PH.NvDGg8I.
19	Thiago Nunes	thiago.nunes@email.com	aluno	$2y$10$jn9E7kprX.OaoW3yiMccT.7k6jeAtFAb3WkQt.u21JWH839beHRvK
20	Isabela Ferreira	isabela.ferreira@email.com	aluno	$2y$10$WV462QtebMUSrnD/UlYkOu9WQcD0HjJBOAgi6C6TugkjA/rx2wMY2
1	Carlos Henrique	carlos.henrique@email.com	professor	$2y$10$wrfWLzl9X.NXbe1iPqajUuvHUJrk7/oxM5P9aOxCCalpr9bSktJXO
2	Mariana Lopes	mariana.lopes@email.com	professor	$2y$10$kvq.X1UNEhLh2IJSGQcGIubhyueKvtkhAIlAtppOFpaQ1IxRja/e2
3	João Victor	joao.victor@email.com	professor	$2y$10$TiWRM.eTQqDLeQsD4jVOle/kU8N.TQxQG51vaZ6.nVJuvW1k6pz8C
4	Ana Beatriz	ana.beatriz@email.com	professor	$2y$10$2BQ.ukW0N1tq9M14AR.iJ.E0OACHikVkSfkjFmpoF8r8JjEwFij7K
5	Rafael Souza	rafael.souza@email.com	professor	$2y$10$Z73UCYhTIY51CEy5Xe9Nz.mFr2vGDqt//Seaggz61RVR.6V/YMy6a
6	Camila Martins	camila.martins@email.com	tecnico	$2y$10$LeBd1yHWF39EUHcxvigDCOQ2ow75R7ejh0hbr88dJoY2tM7TWzFzG
7	Bruno Oliveira	bruno.oliveira@email.com	tecnico	$2y$10$HXQ920vzTZwzY4Ta.gT/wOUaeUNxcZ4LUqV0P1xj6jzDtXTTmLFZ6
8	Fernanda Lima	fernanda.lima@email.com	tecnico	$2y$10$ZnsZKroCVEfn6bW0Lb9iQ.TZwgzwvhemTjVnUTho7DT9BHmE5TrCy
9	Lucas Pereira	lucas.pereira@email.com	tecnico	$2y$10$vFepqWeMa0w1KDkeLLfz3.j0XhQWExifCOcFKXi9CqJMy8lp0q7/.
10	Patrícia Gomes	patricia.gomes@email.com	tecnico	$2y$10$xktFEfvy/YvgHpoPbOBzB.WVtnnPstjUuIlwkFFWf5UUlha7GOxDu
11	Gabriel Santos	gabriel.santos@email.com	aluno	$2y$10$../57jHnMbqqOHcmfOPr4uJBXsp1aWaCtXKmWYK3iMvNk//hjFTLe
12	Juliana Rocha	juliana.rocha@email.com	aluno	$2y$10$W7nDCjDSgNp2zmHFI8sas.maOJkBzl1lZJQdRz.599Hj9HgHqT.iy
\.


--
-- Data for Name: utiliza; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.utiliza (id_turma, id_equipamento, id_laboratorio) FROM stdin;
1	1	1
1	2	1
2	3	2
3	6	3
4	5	3
5	10	5
6	11	6
7	7	4
8	12	6
9	14	8
10	15	9
2	4	2
3	8	4
6	9	5
8	13	7
\.


--
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.agenda_labs_chave_id_agenda_seq', 21, true);


--
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipamentos_id_equipamento_seq', 16, true);


--
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.laboratorio_id_laboratorio_seq', 20, true);


--
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.solicitacao_id_solicitacao_seq', 19, true);


--
-- Name: turma_id_turma_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.turma_id_turma_seq', 20, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 21, true);


--
-- Name: agenda_labs_chave agenda_labs_chave_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT agenda_labs_chave_pkey PRIMARY KEY (id_agenda);


--
-- Name: aluno aluno_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aluno
    ADD CONSTRAINT aluno_pkey PRIMARY KEY (matricula);


--
-- Name: equipamentos equipamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT equipamentos_pkey PRIMARY KEY (id_equipamento);


--
-- Name: laboratorio laboratorio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laboratorio
    ADD CONSTRAINT laboratorio_pkey PRIMARY KEY (id_laboratorio);


--
-- Name: ministra ministra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT ministra_pkey PRIMARY KEY (siape_professor, id_turma);


--
-- Name: pertence pertence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT pertence_pkey PRIMARY KEY (matricula_aluno, id_turma);


--
-- Name: professor professor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor
    ADD CONSTRAINT professor_pkey PRIMARY KEY (siape);


--
-- Name: solicitacao solicitacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT solicitacao_pkey PRIMARY KEY (id_solicitacao);


--
-- Name: tecnico_ti tecnico_ti_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tecnico_ti
    ADD CONSTRAINT tecnico_ti_pkey PRIMARY KEY (cpf);


--
-- Name: turma turma_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma
    ADD CONSTRAINT turma_pkey PRIMARY KEY (id_turma);


--
-- Name: equipamentos uq_equipamentos_patrimonio; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT uq_equipamentos_patrimonio UNIQUE (patrimonio);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: utiliza utiliza_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT utiliza_pkey PRIMARY KEY (id_turma, id_equipamento, id_laboratorio);


--
-- Name: solicitacao trg_equipamento_ativo_apos_conclusao; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_equipamento_ativo_apos_conclusao AFTER UPDATE ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_equipamento_ativo_apos_conclusao();


--
-- Name: solicitacao trg_equipamento_em_manutencao; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_equipamento_em_manutencao AFTER INSERT ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_equipamento_em_manutencao();


--
-- Name: solicitacao trg_preencher_data_fechamento; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_preencher_data_fechamento BEFORE UPDATE ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_preencher_data_fechamento();


--
-- Name: agenda_labs_chave trg_validar_devolucao_chave; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validar_devolucao_chave BEFORE INSERT OR UPDATE ON public.agenda_labs_chave FOR EACH ROW EXECUTE FUNCTION public.fn_validar_devolucao_chave();


--
-- Name: agenda_labs_chave fk_agenda_laboratorio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT fk_agenda_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- Name: agenda_labs_chave fk_agenda_professor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT fk_agenda_professor FOREIGN KEY (siape_professor) REFERENCES public.professor(siape);


--
-- Name: aluno fk_aluno_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aluno
    ADD CONSTRAINT fk_aluno_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: equipamentos fk_equip_lab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT fk_equip_lab FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- Name: ministra fk_ministra_professor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT fk_ministra_professor FOREIGN KEY (siape_professor) REFERENCES public.professor(siape);


--
-- Name: ministra fk_ministra_turma; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT fk_ministra_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


--
-- Name: pertence fk_pertence_aluno; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT fk_pertence_aluno FOREIGN KEY (matricula_aluno) REFERENCES public.aluno(matricula);


--
-- Name: pertence fk_pertence_turma; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT fk_pertence_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


--
-- Name: professor fk_professor_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor
    ADD CONSTRAINT fk_professor_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: solicitacao fk_solic_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- Name: solicitacao fk_solic_tecnico; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_tecnico FOREIGN KEY (cpf_tecnico_responsavel) REFERENCES public.tecnico_ti(cpf);


--
-- Name: solicitacao fk_solic_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_usuario FOREIGN KEY (id_usuario_solicitante) REFERENCES public.usuario(id_usuario);


--
-- Name: tecnico_ti fk_tecnico_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tecnico_ti
    ADD CONSTRAINT fk_tecnico_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: utiliza fk_utiliza_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- Name: utiliza fk_utiliza_laboratorio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- Name: utiliza fk_utiliza_turma; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


--
-- PostgreSQL database dump complete
--

\unrestrict kblvnDLqLKovr0Ws0EgRuCIzSEOE0kz3qFbEcVKSwMhVEe1WirkNPmfESYbJeFC


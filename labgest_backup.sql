--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2026-07-09 21:13:11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 239 (class 1255 OID 34603)
-- Name: fn_equipamento_ativo_apos_conclusao(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fn_equipamento_ativo_apos_conclusao() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 34599)
-- Name: fn_equipamento_em_manutencao(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fn_equipamento_em_manutencao() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 34601)
-- Name: fn_preencher_data_fechamento(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fn_preencher_data_fechamento() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 34605)
-- Name: fn_validar_devolucao_chave(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fn_validar_devolucao_chave() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 34612)
-- Name: fn_validar_horario_agendamento(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validar_horario_agendamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status_chave IN ('retirada', 'atrasada') THEN

        IF NEW.hora_retirada NOT IN (
            '08:00'::time,
            '10:00'::time,
            '13:30'::time,
            '15:10'::time,
            '17:00'::time,
            '18:40'::time,
            '20:20'::time
        ) THEN
            RAISE EXCEPTION 'Horário inválido. O agendamento deve ser feito apenas nos horários permitidos.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM agenda_labs_chave a
            WHERE a.id_laboratorio = NEW.id_laboratorio
              AND a.data_retirada = NEW.data_retirada
              AND a.hora_retirada = NEW.hora_retirada
              AND a.status_chave IN ('retirada', 'atrasada')
              AND (
                    TG_OP = 'INSERT'
                    OR a.id_agenda <> NEW.id_agenda
                  )
        ) THEN
            RAISE EXCEPTION 'Este laboratório já está agendado para este dia e horário.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_validar_horario_agendamento() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 34497)
-- Name: agenda_labs_chave; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.agenda_labs_chave OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 34496)
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agenda_labs_chave_id_agenda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agenda_labs_chave_id_agenda_seq OWNER TO postgres;

--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 229
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agenda_labs_chave_id_agenda_seq OWNED BY public.agenda_labs_chave.id_agenda;


--
-- TOC entry 220 (class 1259 OID 34386)
-- Name: aluno; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aluno (
    matricula character(10) NOT NULL,
    curso character varying(100) NOT NULL,
    semestre integer NOT NULL,
    id_usuario integer NOT NULL,
    CONSTRAINT chk_matricula_format CHECK ((matricula ~ '^[0-9]{10}$'::text))
);


ALTER TABLE public.aluno OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 34416)
-- Name: equipamentos; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.equipamentos OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 34415)
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipamentos_id_equipamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipamentos_id_equipamento_seq OWNER TO postgres;

--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 224
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipamentos_id_equipamento_seq OWNED BY public.equipamentos.id_equipamento;


--
-- TOC entry 235 (class 1259 OID 34561)
-- Name: faz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faz (
    matricula_aluno character(10) NOT NULL,
    id_turma integer NOT NULL
);


ALTER TABLE public.faz OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 34409)
-- Name: laboratorio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.laboratorio (
    id_laboratorio integer NOT NULL,
    bloco character varying(50),
    andar integer,
    capacidade integer
);


ALTER TABLE public.laboratorio OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 34408)
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.laboratorio_id_laboratorio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.laboratorio_id_laboratorio_seq OWNER TO postgres;

--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 222
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.laboratorio_id_laboratorio_seq OWNED BY public.laboratorio.id_laboratorio;


--
-- TOC entry 234 (class 1259 OID 34546)
-- Name: ministra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ministra (
    siape_professor character(6) NOT NULL,
    id_turma integer NOT NULL
);


ALTER TABLE public.ministra OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 34514)
-- Name: pertence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pertence (
    id_equipamento integer NOT NULL,
    id_laboratorio integer NOT NULL
);


ALTER TABLE public.pertence OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 34380)
-- Name: professor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professor (
    siape character(6) NOT NULL,
    curso character varying(100) NOT NULL,
    departamento character varying(100) NOT NULL,
    id_usuario integer,
    CONSTRAINT chk_siape_6_numeros CHECK ((siape ~ '^[0-9]{6}$'::text))
);


ALTER TABLE public.professor OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 34481)
-- Name: realiza_manutencao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.realiza_manutencao (
    id_solicitacao integer NOT NULL,
    id_equipamento integer NOT NULL
);


ALTER TABLE public.realiza_manutencao OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 34456)
-- Name: solicitacao; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.solicitacao OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 34455)
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.solicitacao_id_solicitacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.solicitacao_id_solicitacao_seq OWNER TO postgres;

--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 226
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.solicitacao_id_solicitacao_seq OWNED BY public.solicitacao.id_solicitacao;


--
-- TOC entry 221 (class 1259 OID 34397)
-- Name: tecnico_ti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tecnico_ti (
    cpf character(11) NOT NULL,
    id_usuario integer NOT NULL,
    CONSTRAINT chk_cpf_formato CHECK ((cpf ~ '^[0-9]{11}$'::text))
);


ALTER TABLE public.tecnico_ti OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 34540)
-- Name: turma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turma (
    id_turma integer NOT NULL,
    curso character varying(100) NOT NULL,
    disciplina character varying(100) NOT NULL,
    semestre integer NOT NULL,
    ano integer NOT NULL
);


ALTER TABLE public.turma OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 34539)
-- Name: turma_id_turma_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.turma_id_turma_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.turma_id_turma_seq OWNER TO postgres;

--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 232
-- Name: turma_id_turma_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.turma_id_turma_seq OWNED BY public.turma.id_turma;


--
-- TOC entry 218 (class 1259 OID 34362)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    tipo_usuario character varying(20),
    senha character varying(255)
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 34361)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 236 (class 1259 OID 34576)
-- Name: utiliza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utiliza (
    id_turma integer NOT NULL,
    id_equipamento integer NOT NULL,
    id_laboratorio integer NOT NULL
);


ALTER TABLE public.utiliza OWNER TO postgres;

--
-- TOC entry 4762 (class 2604 OID 34500)
-- Name: agenda_labs_chave id_agenda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_labs_chave ALTER COLUMN id_agenda SET DEFAULT nextval('public.agenda_labs_chave_id_agenda_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 34419)
-- Name: equipamentos id_equipamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipamentos ALTER COLUMN id_equipamento SET DEFAULT nextval('public.equipamentos_id_equipamento_seq'::regclass);


--
-- TOC entry 4758 (class 2604 OID 34412)
-- Name: laboratorio id_laboratorio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorio ALTER COLUMN id_laboratorio SET DEFAULT nextval('public.laboratorio_id_laboratorio_seq'::regclass);


--
-- TOC entry 4760 (class 2604 OID 34459)
-- Name: solicitacao id_solicitacao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitacao ALTER COLUMN id_solicitacao SET DEFAULT nextval('public.solicitacao_id_solicitacao_seq'::regclass);


--
-- TOC entry 4763 (class 2604 OID 34543)
-- Name: turma id_turma; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turma ALTER COLUMN id_turma SET DEFAULT nextval('public.turma_id_turma_seq'::regclass);


--
-- TOC entry 4757 (class 2604 OID 34365)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 4983 (class 0 OID 34497)
-- Dependencies: 230
-- Data for Name: agenda_labs_chave; Type: TABLE DATA; Schema: public; Owner: postgres
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
12	2026-07-09	19:50:00	\N	\N	retirada	234567	1
14	2026-07-09	19:53:00	\N	\N	retirada	234567	1
16	2026-07-17	00:05:00	\N	\N	retirada	234567	1
17	2026-07-13	08:00:00	\N	\N	retirada	234567	1
18	2026-07-15	13:30:00	\N	\N	retirada	234567	4
\.


--
-- TOC entry 4973 (class 0 OID 34386)
-- Dependencies: 220
-- Data for Name: aluno; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- TOC entry 4978 (class 0 OID 34416)
-- Dependencies: 225
-- Data for Name: equipamentos; Type: TABLE DATA; Schema: public; Owner: postgres
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
14	HD Externo Seagate 1TB	Armazenamento	ativo	Dispositivo para backup	8	PAT-1014
15	SSD Kingston 480GB	Armazenamento	ativo	SSD para upgrade de máquinas	9	PAT-1015
12	Teclado Logitech K120	Periférico	manutencao	Teclado USB padrão	6	PAT-1012
11	Monitor LG 24 polegadas	Periférico	manutencao	Monitor reserva do laboratório	6	PAT-1011
4	Desktop Dell OptiPlex	Computador desktop	manutencao	Computador com falha de inicialização	2	PAT-1004
13	Mouse Logitech M90	Periférico	manutencao	Mouse USB padrão	7	PAT-1013
1	Notebook Dell Latitude	Computador portátil	manutencao	Notebook usado em aulas práticas	1	PAT-1001
\.


--
-- TOC entry 4988 (class 0 OID 34561)
-- Dependencies: 235
-- Data for Name: faz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faz (matricula_aluno, id_turma) FROM stdin;
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
-- TOC entry 4976 (class 0 OID 34409)
-- Dependencies: 223
-- Data for Name: laboratorio; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- TOC entry 4987 (class 0 OID 34546)
-- Dependencies: 234
-- Data for Name: ministra; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- TOC entry 4984 (class 0 OID 34514)
-- Dependencies: 231
-- Data for Name: pertence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pertence (id_equipamento, id_laboratorio) FROM stdin;
\.


--
-- TOC entry 4972 (class 0 OID 34380)
-- Dependencies: 219
-- Data for Name: professor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professor (siape, curso, departamento, id_usuario) FROM stdin;
345678	Sistemas de Informação	Departamento de Computação	3
456789	Engenharia de Software	Departamento de Engenharia	4
567890	Ciência da Computação	Departamento de Computação	5
123456	Análise e Desenvolvimento de Sistemas	Departamento de Computação	1
234567	Redes de Computadores	Departamento de Tecnologia da Informação	2
678901	Banco de Dados	Departamento de Tecnologia	3
789012	Segurança da Informação	Departamento de Redes	4
890123	Programação Web	Departamento de Sistemas	5
901234	Arquitetura de Computadores	Departamento de Hardware	6
112233	Gestão de Tecnologia	Departamento de Administração	7
\.


--
-- TOC entry 4981 (class 0 OID 34481)
-- Dependencies: 228
-- Data for Name: realiza_manutencao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.realiza_manutencao (id_solicitacao, id_equipamento) FROM stdin;
1	1
2	6
3	3
4	8
5	5
6	12
7	13
8	10
9	11
10	14
11	7
12	15
13	2
14	9
15	4
\.


--
-- TOC entry 4980 (class 0 OID 34456)
-- Dependencies: 227
-- Data for Name: solicitacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.solicitacao (id_solicitacao, data_abertura, data_fechamento, descricao, tipo_solicitacao, status, id_usuario_solicitante, cpf_tecnico_responsavel, id_equipamento) FROM stdin;
2	2026-07-03 21:26:05.572622	\N	Internet lenta no laboratório de redes	rede	em atendimento	12	22233344455	6
3	2026-07-03 21:26:05.572622	\N	Desktop reiniciando sozinho durante a aula	hardware	aberto	11	33344455566	3
4	2026-07-03 21:26:05.572622	\N	Impressora não imprime documentos enviados	periferico	em atendimento	13	44455566677	8
5	2026-07-03 21:26:05.572622	\N	Servidor apresentou falha de acesso remoto	servidor	aberto	14	55566677788	5
6	2026-07-03 21:26:05.572622	\N	Teclado com várias teclas sem funcionar	periferico	concluido	15	66677788899	12
7	2026-07-03 21:26:05.572622	\N	Mouse desconectando durante o uso	periferico	concluido	12	77788899900	13
8	2026-07-03 21:26:05.572622	\N	Projetor sem imagem na sala de aula	multimidia	aberto	16	88899900011	10
9	2026-07-03 21:26:05.572622	\N	Monitor apagando após alguns minutos	hardware	em atendimento	11	99900011122	11
10	2026-07-03 21:26:05.572622	\N	HD externo não reconhecido pelo computador	armazenamento	aberto	17	00011122233	14
11	2026-07-03 21:26:05.572622	\N	Roteador reiniciando constantemente	rede	aberto	18	22233344455	7
12	2026-07-03 21:26:05.572622	\N	SSD instalado não aparece no sistema	armazenamento	em atendimento	19	33344455566	15
13	2026-07-03 21:26:05.572622	\N	Notebook Lenovo com tela travando	hardware	aberto	20	11122233344	2
14	2026-07-03 21:26:05.572622	\N	Scanner não digitaliza corretamente	periferico	concluido	13	44455566677	9
15	2026-07-03 21:26:05.572622	\N	Desktop Dell com erro na inicialização	hardware	em atendimento	14	55566677788	4
16	2026-07-03 21:38:50.150271	\N	Notebook com tela piscando	hardware	aberto	11	11122233344	1
1	2026-07-03 21:26:05.572622	2026-07-03 21:40:30.818355	Notebook não liga após atualização do sistema	hardware	concluido	11	11122233344	1
17	2026-07-05 14:19:32.55513	\N	teclado não funciona 	hardware	aberto	16	44455566677	12
19	2026-07-09 19:30:08.895007	\N	pc esta travando 	hardware	em atendimento	16	99900011122	4
20	2026-07-09 20:19:21.329303	\N	mouse não esta funcionando	hardware	em atendimento	16	99900011122	13
21	2026-07-09 20:22:25.387343	\N	nao esta ligando	hardware	aberto	2	99900011122	1
\.


--
-- TOC entry 4974 (class 0 OID 34397)
-- Dependencies: 221
-- Data for Name: tecnico_ti; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- TOC entry 4986 (class 0 OID 34540)
-- Dependencies: 233
-- Data for Name: turma; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- TOC entry 4971 (class 0 OID 34362)
-- Dependencies: 218
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, nome, email, tipo_usuario, senha) FROM stdin;
1	Carlos Henrique	carlos.henrique@email.com	professor	123456
2	Mariana Lopes	mariana.lopes@email.com	professor	123456
3	João Victor	joao.victor@email.com	professor	123456
4	Ana Beatriz	ana.beatriz@email.com	professor	123456
5	Rafael Souza	rafael.souza@email.com	professor	123456
6	Camila Martins	camila.martins@email.com	professor	123456
7	Bruno Oliveira	bruno.oliveira@email.com	professor	123456
8	Fernanda Lima	fernanda.lima@email.com	tecnico	234567
9	Lucas Pereira	lucas.pereira@email.com	tecnico	234567
10	Patrícia Gomes	patricia.gomes@email.com	tecnico	234567
11	Gabriel Santos	gabriel.santos@email.com	aluno	345678
12	Juliana Rocha	juliana.rocha@email.com	aluno	345678
13	Mateus Costa	mateus.costa@email.com	aluno	345678
14	Larissa Almeida	larissa.almeida@email.com	aluno	345678
15	Diego Fernandes	diego.fernandes@email.com	aluno	345678
16	Bianca Ribeiro	bianca.ribeiro@email.com	aluno	345678
17	Pedro Henrique	pedro.henrique@email.com	aluno	345678
18	Amanda Carvalho	amanda.carvalho@email.com	aluno	345678
19	Thiago Nunes	thiago.nunes@email.com	aluno	345678
20	Isabela Ferreira	isabela.ferreira@email.com	aluno	345678
\.


--
-- TOC entry 4989 (class 0 OID 34576)
-- Dependencies: 236
-- Data for Name: utiliza; Type: TABLE DATA; Schema: public; Owner: postgres
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
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 229
-- Name: agenda_labs_chave_id_agenda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agenda_labs_chave_id_agenda_seq', 18, true);


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 224
-- Name: equipamentos_id_equipamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipamentos_id_equipamento_seq', 15, true);


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 222
-- Name: laboratorio_id_laboratorio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.laboratorio_id_laboratorio_seq', 10, true);


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 226
-- Name: solicitacao_id_solicitacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.solicitacao_id_solicitacao_seq', 21, true);


--
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 232
-- Name: turma_id_turma_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turma_id_turma_seq', 10, true);


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 20, true);


--
-- TOC entry 4790 (class 2606 OID 34503)
-- Name: agenda_labs_chave agenda_labs_chave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT agenda_labs_chave_pkey PRIMARY KEY (id_agenda);


--
-- TOC entry 4776 (class 2606 OID 34391)
-- Name: aluno aluno_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aluno
    ADD CONSTRAINT aluno_pkey PRIMARY KEY (matricula);


--
-- TOC entry 4782 (class 2606 OID 34423)
-- Name: equipamentos equipamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT equipamentos_pkey PRIMARY KEY (id_equipamento);


--
-- TOC entry 4798 (class 2606 OID 34565)
-- Name: faz faz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faz
    ADD CONSTRAINT faz_pkey PRIMARY KEY (matricula_aluno, id_turma);


--
-- TOC entry 4780 (class 2606 OID 34414)
-- Name: laboratorio laboratorio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorio
    ADD CONSTRAINT laboratorio_pkey PRIMARY KEY (id_laboratorio);


--
-- TOC entry 4796 (class 2606 OID 34550)
-- Name: ministra ministra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT ministra_pkey PRIMARY KEY (siape_professor, id_turma);


--
-- TOC entry 4792 (class 2606 OID 34518)
-- Name: pertence pertence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT pertence_pkey PRIMARY KEY (id_equipamento, id_laboratorio);


--
-- TOC entry 4774 (class 2606 OID 34385)
-- Name: professor professor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor
    ADD CONSTRAINT professor_pkey PRIMARY KEY (siape);


--
-- TOC entry 4788 (class 2606 OID 34485)
-- Name: realiza_manutencao realiza_manutencao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realiza_manutencao
    ADD CONSTRAINT realiza_manutencao_pkey PRIMARY KEY (id_solicitacao, id_equipamento);


--
-- TOC entry 4786 (class 2606 OID 34465)
-- Name: solicitacao solicitacao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT solicitacao_pkey PRIMARY KEY (id_solicitacao);


--
-- TOC entry 4778 (class 2606 OID 34402)
-- Name: tecnico_ti tecnico_ti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tecnico_ti
    ADD CONSTRAINT tecnico_ti_pkey PRIMARY KEY (cpf);


--
-- TOC entry 4794 (class 2606 OID 34545)
-- Name: turma turma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turma
    ADD CONSTRAINT turma_pkey PRIMARY KEY (id_turma);


--
-- TOC entry 4784 (class 2606 OID 34597)
-- Name: equipamentos uq_equipamentos_patrimonio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT uq_equipamentos_patrimonio UNIQUE (patrimonio);


--
-- TOC entry 4770 (class 2606 OID 34369)
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- TOC entry 4772 (class 2606 OID 34367)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4800 (class 2606 OID 34580)
-- Name: utiliza utiliza_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT utiliza_pkey PRIMARY KEY (id_turma, id_equipamento, id_laboratorio);


--
-- TOC entry 4821 (class 2620 OID 34604)
-- Name: solicitacao trg_equipamento_ativo_apos_conclusao; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_equipamento_ativo_apos_conclusao AFTER UPDATE ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_equipamento_ativo_apos_conclusao();


--
-- TOC entry 4822 (class 2620 OID 34600)
-- Name: solicitacao trg_equipamento_em_manutencao; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_equipamento_em_manutencao AFTER INSERT ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_equipamento_em_manutencao();


--
-- TOC entry 4823 (class 2620 OID 34602)
-- Name: solicitacao trg_preencher_data_fechamento; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_preencher_data_fechamento BEFORE UPDATE ON public.solicitacao FOR EACH ROW EXECUTE FUNCTION public.fn_preencher_data_fechamento();


--
-- TOC entry 4824 (class 2620 OID 34606)
-- Name: agenda_labs_chave trg_validar_devolucao_chave; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_devolucao_chave BEFORE INSERT OR UPDATE ON public.agenda_labs_chave FOR EACH ROW EXECUTE FUNCTION public.fn_validar_devolucao_chave();


--
-- TOC entry 4810 (class 2606 OID 34509)
-- Name: agenda_labs_chave fk_agenda_laboratorio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT fk_agenda_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- TOC entry 4811 (class 2606 OID 34504)
-- Name: agenda_labs_chave fk_agenda_professor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda_labs_chave
    ADD CONSTRAINT fk_agenda_professor FOREIGN KEY (siape_professor) REFERENCES public.professor(siape);


--
-- TOC entry 4802 (class 2606 OID 34392)
-- Name: aluno fk_aluno_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aluno
    ADD CONSTRAINT fk_aluno_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4804 (class 2606 OID 34424)
-- Name: equipamentos fk_equip_lab; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipamentos
    ADD CONSTRAINT fk_equip_lab FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- TOC entry 4816 (class 2606 OID 34566)
-- Name: faz fk_faz_aluno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faz
    ADD CONSTRAINT fk_faz_aluno FOREIGN KEY (matricula_aluno) REFERENCES public.aluno(matricula);


--
-- TOC entry 4817 (class 2606 OID 34571)
-- Name: faz fk_faz_turma; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faz
    ADD CONSTRAINT fk_faz_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


--
-- TOC entry 4814 (class 2606 OID 34551)
-- Name: ministra fk_ministra_professor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT fk_ministra_professor FOREIGN KEY (siape_professor) REFERENCES public.professor(siape);


--
-- TOC entry 4815 (class 2606 OID 34556)
-- Name: ministra fk_ministra_turma; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ministra
    ADD CONSTRAINT fk_ministra_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


--
-- TOC entry 4812 (class 2606 OID 34519)
-- Name: pertence fk_pertence_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT fk_pertence_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- TOC entry 4813 (class 2606 OID 34524)
-- Name: pertence fk_pertence_laboratorio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertence
    ADD CONSTRAINT fk_pertence_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- TOC entry 4801 (class 2606 OID 34607)
-- Name: professor fk_professor_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professor
    ADD CONSTRAINT fk_professor_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4808 (class 2606 OID 34491)
-- Name: realiza_manutencao fk_realiza_manutencao_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realiza_manutencao
    ADD CONSTRAINT fk_realiza_manutencao_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- TOC entry 4809 (class 2606 OID 34486)
-- Name: realiza_manutencao fk_realiza_manutencao_solicitacao; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realiza_manutencao
    ADD CONSTRAINT fk_realiza_manutencao_solicitacao FOREIGN KEY (id_solicitacao) REFERENCES public.solicitacao(id_solicitacao);


--
-- TOC entry 4805 (class 2606 OID 34476)
-- Name: solicitacao fk_solic_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- TOC entry 4806 (class 2606 OID 34471)
-- Name: solicitacao fk_solic_tecnico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_tecnico FOREIGN KEY (cpf_tecnico_responsavel) REFERENCES public.tecnico_ti(cpf);


--
-- TOC entry 4807 (class 2606 OID 34466)
-- Name: solicitacao fk_solic_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitacao
    ADD CONSTRAINT fk_solic_usuario FOREIGN KEY (id_usuario_solicitante) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4803 (class 2606 OID 34403)
-- Name: tecnico_ti fk_tecnico_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tecnico_ti
    ADD CONSTRAINT fk_tecnico_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4818 (class 2606 OID 34586)
-- Name: utiliza fk_utiliza_equipamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_equipamento FOREIGN KEY (id_equipamento) REFERENCES public.equipamentos(id_equipamento);


--
-- TOC entry 4819 (class 2606 OID 34591)
-- Name: utiliza fk_utiliza_laboratorio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_laboratorio FOREIGN KEY (id_laboratorio) REFERENCES public.laboratorio(id_laboratorio);


--
-- TOC entry 4820 (class 2606 OID 34581)
-- Name: utiliza fk_utiliza_turma; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utiliza
    ADD CONSTRAINT fk_utiliza_turma FOREIGN KEY (id_turma) REFERENCES public.turma(id_turma);


-- Completed on 2026-07-09 21:13:26

--
-- PostgreSQL database dump complete
--


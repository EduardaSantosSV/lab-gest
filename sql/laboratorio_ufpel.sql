CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE tecnico_ti (
    id_tecnico INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_tecnico_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE professor (
    siape CHAR(6) PRIMARY KEY,
    curso VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    CONSTRAINT chk_siape_6_numeros
    CHECK (siape ~ '^[0-9]{6}$')
);

CREATE TABLE aluno (
    matricula CHAR(10) PRIMARY KEY,
    curso VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_aluno_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT chk_matricula_format
    CHECK (matricula ~ '^[0-9]{10}$')
);

DROP TABLE IF EXISTS tecnico_ti CASCADE;


CREATE TABLE tecnico_ti (
    cpf CHAR(11) PRIMARY KEY,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_tecnico_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT chk_cpf_formato
    CHECK (cpf ~ '^[0-9]{11}$')
);

CREATE TABLE laboratorio (
    id_laboratorio SERIAL PRIMARY KEY,
    bloco VARCHAR(50),
    andar INT,
    capacidade INT
);

CREATE TABLE equipamentos (
    id_equipamento SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(100),
    status VARCHAR(50),
    descricao TEXT,
    id_laboratorio INT NOT NULL,
    CONSTRAINT fk_equip_lab
    FOREIGN KEY (id_laboratorio) REFERENCES laboratorio(id_laboratorio)
);

CREATE TABLE solicitacao (
    id_solicitacao SERIAL PRIMARY KEY,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP,
    descricao TEXT NOT NULL,
    tipo_solicitacao VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    -- quem abriu o chamado
    id_usuario_solicitante INT NOT NULL,
    -- quem resolve o chamado (técnico CPF)
    cpf_tecnico_responsavel CHAR(11),
    -- equipamento com problema
    id_equipamento INT NOT NULL,
    -- RELACIONAMENTOS (FKs)
    CONSTRAINT fk_solic_usuario
        FOREIGN KEY (id_usuario_solicitante)
        REFERENCES usuario(id_usuario),
    CONSTRAINT fk_solic_tecnico
        FOREIGN KEY (cpf_tecnico_responsavel)
        REFERENCES tecnico_ti(cpf),
    CONSTRAINT fk_solic_equip
        FOREIGN KEY (id_equipamento)
        REFERENCES equipamentos(id_equipamento),
    -- regras de integridade
    CONSTRAINT chk_status
        CHECK (status IN ('aberto', 'em atendimento', 'concluido', 'cancelado'))
);

DROP TABLE IF EXISTS solicitacao CASCADE;

CREATE TABLE solicitacao (
    id_solicitacao SERIAL PRIMARY KEY,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP,
    descricao TEXT NOT NULL,
    tipo_solicitacao VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    id_usuario_solicitante INT NOT NULL,
    cpf_tecnico_responsavel CHAR(11),
    id_equipamento INT NOT NULL,

    CONSTRAINT fk_solic_usuario
        FOREIGN KEY (id_usuario_solicitante)
        REFERENCES usuario(id_usuario),
    CONSTRAINT fk_solic_tecnico
        FOREIGN KEY (cpf_tecnico_responsavel)
        REFERENCES tecnico_ti(cpf),
    CONSTRAINT fk_solic_equipamento
        FOREIGN KEY (id_equipamento)
        REFERENCES equipamentos(id_equipamento),
    CONSTRAINT chk_status_solicitacao
        CHECK (status IN ('aberto', 'em atendimento', 'concluido', 'cancelado'))
);

CREATE TABLE realiza_manutencao (
    id_solicitacao INT NOT NULL,
    id_equipamento INT NOT NULL,
    PRIMARY KEY (id_solicitacao, id_equipamento),
    CONSTRAINT fk_realiza_manutencao_solicitacao
        FOREIGN KEY (id_solicitacao)
        REFERENCES solicitacao(id_solicitacao),
    CONSTRAINT fk_realiza_manutencao_equipamento
        FOREIGN KEY (id_equipamento)
        REFERENCES equipamentos(id_equipamento)
);

CREATE TABLE agenda_labs_chave (
    id_agenda SERIAL PRIMARY KEY,
    data_retirada DATE NOT NULL,
    hora_retirada TIME NOT NULL,
    data_devolucao DATE,
    hora_devolucao TIME,
    status_chave VARCHAR(30) NOT NULL,
    siape_professor CHAR(6) NOT NULL,
    id_laboratorio INT NOT NULL,
    CONSTRAINT fk_agenda_professor
        FOREIGN KEY (siape_professor)
        REFERENCES professor(siape),
    CONSTRAINT fk_agenda_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio),
    CONSTRAINT chk_status_chave
        CHECK (status_chave IN ('retirada', 'devolvida', 'atrasada'))
);

CREATE TABLE pertence (
    id_equipamento INT NOT NULL,
    id_laboratorio INT NOT NULL,
    PRIMARY KEY (id_equipamento, id_laboratorio),
    CONSTRAINT fk_pertence_equipamento
        FOREIGN KEY (id_equipamento)
        REFERENCES equipamentos(id_equipamento),
    CONSTRAINT fk_pertence_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio)
);

CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    curso VARCHAR(100) NOT NULL,
    disciplina VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    ano INT NOT NULL
);

CREATE TABLE ministra (
    siape_professor CHAR(6) NOT NULL,
    id_turma INT NOT NULL,
    PRIMARY KEY (siape_professor, id_turma),
    CONSTRAINT fk_ministra_professor
        FOREIGN KEY (siape_professor)
        REFERENCES professor(siape),
    CONSTRAINT fk_ministra_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma)
);

CREATE TABLE faz (
    matricula_aluno CHAR(10) NOT NULL,
    id_turma INT NOT NULL,

    PRIMARY KEY (matricula_aluno, id_turma),

    CONSTRAINT fk_faz_aluno
        FOREIGN KEY (matricula_aluno)
        REFERENCES aluno(matricula),

    CONSTRAINT fk_faz_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma)
);

CREATE TABLE utiliza (
    id_turma INT NOT NULL,
    id_equipamento INT NOT NULL,
    id_laboratorio INT NOT NULL,

    PRIMARY KEY (id_turma, id_equipamento, id_laboratorio),

    CONSTRAINT fk_utiliza_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma),

    CONSTRAINT fk_utiliza_equipamento
        FOREIGN KEY (id_equipamento)
        REFERENCES equipamentos(id_equipamento),

    CONSTRAINT fk_utiliza_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio)
);

select*from pertence;

INSERT INTO usuario (nome, email) VALUES
('Carlos Henrique', 'carlos.henrique@email.com'),
('Mariana Lopes', 'mariana.lopes@email.com'),
('João Victor', 'joao.victor@email.com'),
('Ana Beatriz', 'ana.beatriz@email.com'),
('Rafael Souza', 'rafael.souza@email.com'),
('Camila Martins', 'camila.martins@email.com'),
('Bruno Oliveira', 'bruno.oliveira@email.com'),
('Fernanda Lima', 'fernanda.lima@email.com'),
('Lucas Pereira', 'lucas.pereira@email.com'),
('Patrícia Gomes', 'patricia.gomes@email.com'),
('Gabriel Santos', 'gabriel.santos@email.com'),
('Juliana Rocha', 'juliana.rocha@email.com'),
('Mateus Costa', 'mateus.costa@email.com'),
('Larissa Almeida', 'larissa.almeida@email.com'),
('Diego Fernandes', 'diego.fernandes@email.com'),
('Bianca Ribeiro', 'bianca.ribeiro@email.com'),
('Pedro Henrique', 'pedro.henrique@email.com'),
('Amanda Carvalho', 'amanda.carvalho@email.com'),
('Thiago Nunes', 'thiago.nunes@email.com'),
('Isabela Ferreira', 'isabela.ferreira@email.com');

INSERT INTO tecnico_ti (cpf, id_usuario) VALUES
('11122233344', 1),
('22233344455', 2),
('33344455566', 3),
('44455566677', 4),
('55566677788', 5),
('66677788899', 6),
('77788899900', 7),
('88899900011', 8),
('99900011122', 9),
('00011122233', 10);

INSERT INTO professor (siape, curso, departamento) VALUES
('123456', 'Análise e Desenvolvimento de Sistemas', 'Departamento de Computação'),
('234567', 'Redes de Computadores', 'Departamento de Tecnologia da Informação'),
('345678', 'Sistemas de Informação', 'Departamento de Computação'),
('456789', 'Engenharia de Software', 'Departamento de Engenharia'),
('567890', 'Ciência da Computação', 'Departamento de Computação'),
('678901', 'Banco de Dados', 'Departamento de Tecnologia'),
('789012', 'Segurança da Informação', 'Departamento de Redes'),
('890123', 'Programação Web', 'Departamento de Sistemas'),
('901234', 'Arquitetura de Computadores', 'Departamento de Hardware'),
('112233', 'Gestão de Tecnologia', 'Departamento de Administração');

INSERT INTO aluno (matricula, curso, semestre, id_usuario) VALUES
('2024000001', 'Análise e Desenvolvimento de Sistemas', 1, 11),
('2024000002', 'Análise e Desenvolvimento de Sistemas', 2, 12),
('2024000003', 'Redes de Computadores', 3, 13),
('2024000004', 'Sistemas de Informação', 4, 14),
('2024000005', 'Engenharia de Software', 2, 15),
('2024000006', 'Ciência da Computação', 5, 16),
('2024000007', 'Banco de Dados', 3, 17),
('2024000008', 'Segurança da Informação', 4, 18),
('2024000009', 'Programação Web', 1, 19),
('2024000010', 'Gestão de Tecnologia', 2, 20);

SELECT * FROM tecnico_ti;

INSERT INTO laboratorio (bloco, andar, capacidade) VALUES
('Bloco A', 1, 30),
('Bloco A', 2, 28),
('Bloco B', 1, 35),
('Bloco B', 2, 32),
('Bloco C', 1, 25),
('Bloco C', 2, 26),
('Bloco D', 1, 40),
('Bloco D', 2, 38),
('Bloco E', 1, 24),
('Bloco E', 2, 22);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'equipamentos'
ORDER BY ordinal_position;

ALTER TABLE equipamentos
ADD COLUMN patrimonio VARCHAR(30);

ALTER TABLE equipamentos
ADD CONSTRAINT uq_equipamentos_patrimonio
UNIQUE (patrimonio);



INSERT INTO equipamentos (patrimonio, nome, tipo, status, descricao, id_laboratorio) VALUES
('PAT-1001', 'Notebook Dell Latitude', 'Computador portátil', 'ativo', 'Notebook usado em aulas práticas', 1),
('PAT-1002', 'Notebook Lenovo ThinkPad', 'Computador portátil', 'ativo', 'Notebook para laboratório de programação', 1),
('PAT-1003', 'Desktop HP ProDesk', 'Computador desktop', 'ativo', 'Computador de bancada para alunos', 2),
('PAT-1004', 'Desktop Dell OptiPlex', 'Computador desktop', 'manutencao', 'Computador com falha de inicialização', 2),
('PAT-1005', 'Servidor Dell PowerEdge', 'Servidor', 'ativo', 'Servidor de aplicações internas', 3),
('PAT-1006', 'Switch Cisco 24 portas', 'Equipamento de rede', 'ativo', 'Switch principal do laboratório', 3),
('PAT-1007', 'Roteador TP-Link Archer', 'Equipamento de rede', 'ativo', 'Roteador Wi-Fi do laboratório', 4),
('PAT-1008', 'Impressora HP LaserJet', 'Periférico', 'ativo', 'Impressora compartilhada do setor', 4),
('PAT-1009', 'Scanner Epson WorkForce', 'Periférico', 'ativo', 'Scanner para digitalização de documentos', 5),
('PAT-1010', 'Projetor Epson PowerLite', 'Multimídia', 'ativo', 'Projetor usado em aulas', 5),
('PAT-1011', 'Monitor LG 24 polegadas', 'Periférico', 'ativo', 'Monitor reserva do laboratório', 6),
('PAT-1012', 'Teclado Logitech K120', 'Periférico', 'ativo', 'Teclado USB padrão', 6),
('PAT-1013', 'Mouse Logitech M90', 'Periférico', 'ativo', 'Mouse USB padrão', 7),
('PAT-1014', 'HD Externo Seagate 1TB', 'Armazenamento', 'ativo', 'Dispositivo para backup', 8),
('PAT-1015', 'SSD Kingston 480GB', 'Armazenamento', 'ativo', 'SSD para upgrade de máquinas', 9);

INSERT INTO turma (curso, disciplina, semestre, ano) VALUES
('Análise e Desenvolvimento de Sistemas', 'Banco de Dados', 2, 2026),
('Análise e Desenvolvimento de Sistemas', 'Programação Orientada a Objetos', 2, 2026),
('Redes de Computadores', 'Infraestrutura de Redes', 3, 2026),
('Sistemas de Informação', 'Engenharia de Software', 4, 2026),
('Ciência da Computação', 'Arquitetura de Computadores', 3, 2026),
('Banco de Dados', 'Modelagem de Dados', 1, 2026),
('Segurança da Informação', 'Segurança em Redes', 4, 2026),
('Programação Web', 'HTML, CSS e JavaScript', 1, 2026),
('Gestão de Tecnologia', 'Gestão de Projetos de TI', 2, 2026),
('Engenharia de Software', 'Qualidade de Software', 5, 2026);

INSERT INTO solicitacao (
    descricao,
    tipo_solicitacao,
    status,
    id_usuario_solicitante,
    cpf_tecnico_responsavel,
    id_equipamento
) VALUES
('Notebook não liga após atualização do sistema', 'hardware', 'aberto', 11, '11122233344', 1),
('Internet lenta no laboratório de redes', 'rede', 'em atendimento', 12, '22233344455', 6),
('Desktop reiniciando sozinho durante a aula', 'hardware', 'aberto', 11, '33344455566', 3),
('Impressora não imprime documentos enviados', 'periferico', 'em atendimento', 13, '44455566677', 8),
('Servidor apresentou falha de acesso remoto', 'servidor', 'aberto', 14, '55566677788', 5),
('Teclado com várias teclas sem funcionar', 'periferico', 'concluido', 15, '66677788899', 12),
('Mouse desconectando durante o uso', 'periferico', 'concluido', 12, '77788899900', 13),
('Projetor sem imagem na sala de aula', 'multimidia', 'aberto', 16, '88899900011', 10),
('Monitor apagando após alguns minutos', 'hardware', 'em atendimento', 11, '99900011122', 11),
('HD externo não reconhecido pelo computador', 'armazenamento', 'aberto', 17, '00011122233', 14),
('Roteador reiniciando constantemente', 'rede', 'aberto', 18, '22233344455', 7),
('SSD instalado não aparece no sistema', 'armazenamento', 'em atendimento', 19, '33344455566', 15),
('Notebook Lenovo com tela travando', 'hardware', 'aberto', 20, '11122233344', 2),
('Scanner não digitaliza corretamente', 'periferico', 'concluido', 13, '44455566677', 9),
('Desktop Dell com erro na inicialização', 'hardware', 'em atendimento', 14, '55566677788', 4);

INSERT INTO realiza_manutencao (id_solicitacao, id_equipamento) VALUES
(1, 1),(2, 6),(3, 3),(4, 8),(5, 5),(6, 12),(7, 13),
(8, 10),(9, 11),(10, 14),(11, 7),(12, 15),(13, 2),
(14, 9),(15, 4);

INSERT INTO agenda_labs_chave (
    data_retirada,
    hora_retirada,
    data_devolucao,
    hora_devolucao,
    status_chave,
    siape_professor,
    id_laboratorio
) VALUES
('2026-07-01', '07:30', '2026-07-01', '11:30', 'devolvida', '123456', 1),
('2026-07-01', '13:00', '2026-07-01', '17:00', 'devolvida', '234567', 2),
('2026-07-02', '08:00', '2026-07-02', '12:00', 'devolvida', '345678', 3),
('2026-07-02', '14:00', NULL, NULL, 'retirada', '456789', 4),
('2026-07-03', '07:45', '2026-07-03', '10:30', 'devolvida', '567890', 5),
('2026-07-03', '13:30', NULL, NULL, 'retirada', '678901', 6),
('2026-07-04', '08:10', '2026-07-04', '11:50', 'devolvida', '789012', 7),
('2026-07-04', '14:20', NULL, NULL, 'atrasada', '890123', 8),
('2026-07-05', '07:55', '2026-07-05', '12:10', 'devolvida', '901234', 9),
('2026-07-05', '13:10', NULL, NULL, 'retirada', '112233', 10);

INSERT INTO ministra (siape_professor, id_turma) VALUES
('123456', 1),
('234567', 2),
('345678', 3),
('456789', 4),
('567890', 5),
('678901', 6),
('789012', 7),
('890123', 8),
('901234', 9),
('112233', 10);

INSERT INTO faz (matricula_aluno, id_turma) VALUES
('2024000001', 1),
('2024000002', 1),
('2024000003', 2),
('2024000004', 3),
('2024000005', 4),
('2024000006', 5),
('2024000007', 6),
('2024000008', 7),
('2024000009', 8),
('2024000010', 9),
('2024000001', 10),
('2024000002', 3),
('2024000005', 6),
('2024000007', 8),
('2024000009', 10);

INSERT INTO utiliza (id_turma, id_equipamento, id_laboratorio) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 3, 2),
(3, 6, 3),
(4, 5, 3),
(5, 10, 5),
(6, 11, 6),
(7, 7, 4),
(8, 12, 6),
(9, 14, 8),
(10, 15, 9),
(2, 4, 2),
(3, 8, 4),
(6, 9, 5),
(8, 13, 7);

--TRIGGER
--1 Quando uma nova solicitação for criada, o equipamento associado muda automaticamente para manutencao.
CREATE OR REPLACE FUNCTION fn_equipamento_em_manutencao()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE equipamentos
    SET status = 'manutencao'
    WHERE id_equipamento = NEW.id_equipamento;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_equipamento_em_manutencao
AFTER INSERT ON solicitacao
FOR EACH ROW
EXECUTE FUNCTION fn_equipamento_em_manutencao();

--2 Quando o status mudar para concluido, o sistema preenche automaticamente data_fechamento.
CREATE OR REPLACE FUNCTION fn_preencher_data_fechamento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'concluido' AND OLD.status <> 'concluido' THEN
        NEW.data_fechamento = CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_preencher_data_fechamento
BEFORE UPDATE ON solicitacao
FOR EACH ROW
EXECUTE FUNCTION fn_preencher_data_fechamento();

--3 Quando solicitação for concluída, equipamento volta para “ativo”
CREATE OR REPLACE FUNCTION fn_equipamento_ativo_apos_conclusao()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'concluido' AND OLD.status <> 'concluido' THEN
        UPDATE equipamentos
        SET status = 'ativo'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_equipamento_ativo_apos_conclusao
AFTER UPDATE ON solicitacao
FOR EACH ROW
EXECUTE FUNCTION fn_equipamento_ativo_apos_conclusao();

--4 Impedir devolver chave sem data e hora de devolução
CREATE OR REPLACE FUNCTION fn_validar_devolucao_chave()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_chave = 'devolvida' THEN
        IF NEW.data_devolucao IS NULL OR NEW.hora_devolucao IS NULL THEN
            RAISE EXCEPTION 'Para status devolvida, informe data_devolucao e hora_devolucao.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_devolucao_chave
BEFORE INSERT OR UPDATE ON agenda_labs_chave
FOR EACH ROW
EXECUTE FUNCTION fn_validar_devolucao_chave();

--consultas DAS TRIGGERS

SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
ORDER BY event_object_table, trigger_name;

--TESTE
INSERT INTO solicitacao (
    descricao,
    tipo_solicitacao,
    status,
    id_usuario_solicitante,
    cpf_tecnico_responsavel,
    id_equipamento
) VALUES (
    'Notebook com tela piscando',
    'hardware',
    'aberto',
    11,
    '11122233344',
    1
);

SELECT id_equipamento, nome, status
FROM equipamentos
WHERE id_equipamento = 1;

UPDATE solicitacao
SET status = 'concluido'
WHERE id_solicitacao = 1;
SELECT * FROM solicitacao;

SELECT id_solicitacao, status, data_fechamento
FROM solicitacao
WHERE id_solicitacao = 1;

SELECT id_equipamento, nome, status
FROM equipamentos
WHERE id_equipamento = 1;

---------------

SELECT
    s.id_solicitacao,
    u.nome AS quem_abriu,
    t.cpf AS cpf_tecnico,
    ut.nome AS tecnico_responsavel,
    e.patrimonio,
    e.nome AS equipamento,
    l.bloco,
    l.andar,
    s.status
FROM solicitacao s
INNER JOIN usuario u
    ON s.id_usuario_solicitante = u.id_usuario
INNER JOIN tecnico_ti t
    ON s.cpf_tecnico_responsavel = t.cpf
INNER JOIN usuario ut
    ON t.id_usuario = ut.id_usuario
INNER JOIN equipamentos e
    ON s.id_equipamento = e.id_equipamento
INNER JOIN laboratorio l
    ON e.id_laboratorio = l.id_laboratorio;


ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS tipo_usuario VARCHAR(20);

ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS senha VARCHAR(255);


-- Usuários 1 a 5 como PROFESSORES
UPDATE usuario
SET senha = '123456', tipo_usuario = 'professor'
WHERE id_usuario BETWEEN 1 AND 5;

-- Usuários 6 a 10 como TÉCNICOS DE TI
UPDATE usuario
SET senha = '234567', tipo_usuario = 'tecnico'
WHERE id_usuario BETWEEN 6 AND 10;

-- Usuários 11 a 20 como ALUNOS
UPDATE usuario
SET senha = '345678', tipo_usuario = 'aluno'
WHERE id_usuario BETWEEN 11 AND 20;

ALTER TABLE professor
ADD COLUMN id_usuario INT;

ALTER TABLE professor
ADD CONSTRAINT fk_professor_usuario
FOREIGN KEY (id_usuario)
REFERENCES usuario(id_usuario);

select * from usuario;
SELECT *FROM professor;
SELECT *FROM solicitacoes;



UPDATE professor
SET id_usuario = 1
WHERE siape = '123456';

UPDATE professor
SET id_usuario = 2
WHERE siape = '234567';

UPDATE professor
SET id_usuario = 3
WHERE siape = '345678';

UPDATE professor
SET id_usuario = 4
WHERE siape = '456789';

UPDATE professor
SET id_usuario = 5
WHERE siape = '567890';

UPDATE usuario
SET tipo_usuario = 'professor',
    senha = '123456'
WHERE id_usuario IN (1,2,3,4,5,6,7);

SELECT
    id_usuario,
    nome,
    tipo_usuario,
    senha,
	siape
FROM usuario
WHERE tipo_usuario = 'professor'
ORDER BY id_usuario;

SELECT id_usuario, nome, email, senha, tipo_usuario
FROM usuario
ORDER BY id_usuario;
	

    SELECT id_usuario, nome, email, tipo_usuario, senha
FROM usuario
WHERE tipo_usuario = 'professor'
ORDER BY id_usuario;

UPDATE professor
SET id_usuario = 1
WHERE siape = '123456';

UPDATE professor
SET id_usuario = 2
WHERE siape = '234567';

UPDATE professor
SET id_usuario = 3
WHERE siape = '678901';

UPDATE professor
SET id_usuario = 4
WHERE siape = '789012';

UPDATE professor
SET id_usuario = 5
WHERE siape = '890123';

UPDATE professor
SET id_usuario = 6
WHERE siape = '901234';

UPDATE professor
SET id_usuario = 7
WHERE siape = '112233';

SELECT
    u.id_usuario,
    u.nome,
    u.email,
    u.tipo_usuario,
    p.siape,
    p.curso,
    p.departamento
FROM usuario u
INNER JOIN professor p
    ON u.id_usuario = p.id_usuario
ORDER BY u.id_usuario;

CREATE OR REPLACE FUNCTION fn_validar_horario_agendamento()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;
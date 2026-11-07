-- =====================================================================
-- Sonar - script do banco de dados (versão PostgreSQL 12+)
-- Revisão após os testes da seção 19.2. Correções: F-13 a F-18.
-- Uso: crie o banco (CREATE DATABASE sonar;) e execute: psql -d sonar -f sonar_postgresql.sql
-- =====================================================================

-- ---------- Contexto institucional ----------

CREATE TABLE INSTITUICAO (
    id_instituicao INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           VARCHAR(255) NOT NULL,
    tipo           VARCHAR(20)  NOT NULL,
    cidade         VARCHAR(120),
    dominio_email  VARCHAR(120) NOT NULL UNIQUE,              -- valida o vínculo no cadastro (RNE-001)
    CONSTRAINT ck_instituicao_tipo CHECK (tipo IN ('PUBLICA', 'PRIVADA'))
);

CREATE TABLE ESTUDANTE (
    id_estudante   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_instituicao INT          NOT NULL,                       -- RNE-001
    nome           VARCHAR(255) NOT NULL,
    email          VARCHAR(255) NOT NULL UNIQUE,                -- F-13
    curso          VARCHAR(120) NOT NULL,                       -- F-18
    periodo        SMALLINT     NOT NULL,                       -- F-18
    senha_hash     VARCHAR(255) NOT NULL,                       -- F-18: nunca a senha em texto
    data_cadastro  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         VARCHAR(20)  NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT ck_estudante_periodo CHECK (periodo BETWEEN 1 AND 10),
    CONSTRAINT ck_estudante_status  CHECK (status IN ('ATIVO', 'SUSPENSO', 'ENCERRADO')),
    FOREIGN KEY (id_instituicao) REFERENCES INSTITUICAO (id_instituicao)
);

CREATE TABLE DISCIPLINA (
    id_disciplina  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_instituicao INT          NOT NULL,
    nome           VARCHAR(255) NOT NULL,
    codigo         VARCHAR(30)  NOT NULL,
    periodo        SMALLINT,
    professor      VARCHAR(255),
    UNIQUE (id_instituicao, codigo),
    FOREIGN KEY (id_instituicao) REFERENCES INSTITUICAO (id_instituicao)
);

CREATE TABLE ESTUDANTE_DISCIPLINA (
    id_estudante  INT NOT NULL,
    id_disciplina INT NOT NULL,
    semestre      VARCHAR(10) NOT NULL,                         -- ex.: 2026/2
    status        VARCHAR(20) NOT NULL DEFAULT 'CURSANDO',
    PRIMARY KEY (id_estudante, id_disciplina, semestre),
    CONSTRAINT ck_matricula_status CHECK (status IN ('CURSANDO', 'APROVADO', 'REPROVADO', 'TRANCADO')),
    FOREIGN KEY (id_estudante)  REFERENCES ESTUDANTE (id_estudante)   ON DELETE CASCADE,  -- F-14
    FOREIGN KEY (id_disciplina) REFERENCES DISCIPLINA (id_disciplina)
);

CREATE TABLE AULA (
    id_aula        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_disciplina  INT         NOT NULL,
    data           DATE        NOT NULL,
    horario_inicio TIME        NOT NULL,
    horario_fim    TIME        NOT NULL,
    sala           VARCHAR(30) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'PREVISTA',
    CONSTRAINT ck_aula_horario CHECK (horario_fim > horario_inicio),                       -- F-15
    CONSTRAINT ck_aula_status  CHECK (status IN ('PREVISTA', 'REALIZADA', 'CANCELADA', 'ALTERADA')),
    FOREIGN KEY (id_disciplina) REFERENCES DISCIPLINA (id_disciplina) ON DELETE CASCADE
);

-- Mudança gravada como registro próprio, sem sobrescrever a aula (RF-015)
CREATE TABLE MUDANCA (
    id_mudanca     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aula        INT          NOT NULL,
    tipo           VARCHAR(20)  NOT NULL,
    valor_anterior VARCHAR(255) NOT NULL,
    valor_novo     VARCHAR(255) NOT NULL,
    data_registro  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo         VARCHAR(255),
    CONSTRAINT ck_mudanca_tipo CHECK (tipo IN ('SALA', 'HORARIO', 'DATA', 'CANCELAMENTO')),
    FOREIGN KEY (id_aula) REFERENCES AULA (id_aula) ON DELETE CASCADE
);

-- ---------- Dados do estudante (apagados junto com a conta: RF-006, RNE-004) ----------

CREATE TABLE PERFIL_ACESSIBILIDADE (
    id_perfil                INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudante             INT NOT NULL UNIQUE,             -- F-13: um perfil por estudante
    estilo_aprendizagem      VARCHAR(30),                     -- campos opcionais: perfil parcial é permitido (RF-007)
    tolerancia_sensorial     VARCHAR(30),
    comunicacao_preferencial VARCHAR(30),
    data_atualizacao         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante) ON DELETE CASCADE
);

CREATE TABLE PREFERENCIA (
    id_preferencia INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_perfil      INT          NOT NULL,
    categoria      VARCHAR(30)  NOT NULL,
    descricao      VARCHAR(255),
    valor          VARCHAR(255) NOT NULL,
    ativo          BOOLEAN      NOT NULL DEFAULT FALSE,       -- RNE-007: nada ativado por padrão
    CONSTRAINT ck_preferencia_categoria CHECK (categoria IN ('APRENDIZAGEM', 'SENSORIAL', 'COMUNICACAO', 'VISUAL')),
    FOREIGN KEY (id_perfil) REFERENCES PERFIL_ACESSIBILIDADE (id_perfil) ON DELETE CASCADE
);

CREATE TABLE CONSENTIMENTO (
    id_consentimento   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudante       INT         NOT NULL,
    finalidade         VARCHAR(30) NOT NULL,
    versao_termo       VARCHAR(20) NOT NULL,                  -- RF-004: versão do termo aceito
    autorizado         BOOLEAN     NOT NULL,
    data_consentimento TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_revogacao     TIMESTAMP,
    CONSTRAINT ck_consentimento_finalidade CHECK (finalidade IN
        ('PERFIL', 'TRANSCRICAO', 'FILTRAGEM_ACUSTICA', 'DADOS_ANONIMOS')),                   -- RNE-003
    CONSTRAINT ck_consentimento_datas CHECK (data_revogacao IS NULL OR data_revogacao >= data_consentimento),  -- F-15
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante) ON DELETE CASCADE
);

-- A transcrição pertence ao estudante que a gerou (F-16, RNE-004, RNE-010)
CREATE TABLE TRANSCRICAO (
    id_transcricao INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudante   INT         NOT NULL,
    id_aula        INT,
    data_geracao   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idioma         VARCHAR(10) NOT NULL DEFAULT 'pt-BR',
    status         VARCHAR(20) NOT NULL DEFAULT 'PROCESSANDO',
    texto_completo TEXT,
    CONSTRAINT ck_transcricao_status CHECK (status IN ('PROCESSANDO', 'CONCLUIDA', 'ERRO')),
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante) ON DELETE CASCADE,
    FOREIGN KEY (id_aula)      REFERENCES AULA (id_aula)           ON DELETE SET NULL
);

CREATE TABLE SEGMENTO_TRANSCRICAO (
    id_segmento    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transcricao INT           NOT NULL,
    ordem          INT           NOT NULL,
    inicio         DECIMAL(10,2) NOT NULL,                    -- segundos desde o início da aula
    fim            DECIMAL(10,2) NOT NULL,
    texto          TEXT          NOT NULL,
    UNIQUE (id_transcricao, ordem),
    CONSTRAINT ck_segmento_tempo CHECK (fim >= inicio),
    FOREIGN KEY (id_transcricao) REFERENCES TRANSCRICAO (id_transcricao) ON DELETE CASCADE
);

CREATE TABLE FEEDBACK (
    id_feedback   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudante  INT         NOT NULL,
    id_aula       INT,
    tipo_recurso  VARCHAR(30) NOT NULL,
    avaliacao     SMALLINT    NOT NULL,
    comentario    VARCHAR(500),
    data_feedback TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_feedback_avaliacao CHECK (avaliacao BETWEEN 1 AND 3),   -- RF-017: duas ou três opções
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante) ON DELETE CASCADE,
    FOREIGN KEY (id_aula)      REFERENCES AULA (id_aula)           ON DELETE SET NULL
);

CREATE TABLE TAREFA_IA (
    id_tarefa    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudante INT          NOT NULL,
    titulo       VARCHAR(255) NOT NULL,
    descricao    TEXT,
    data_criacao TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    prazo        DATE,
    status       VARCHAR(20)  NOT NULL DEFAULT 'ABERTA',
    CONSTRAINT ck_tarefa_status CHECK (status IN ('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante) ON DELETE CASCADE
);

CREATE TABLE MICROETAPA (
    id_microetapa INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_tarefa     INT          NOT NULL,
    descricao     VARCHAR(500) NOT NULL,
    ordem         INT          NOT NULL,
    prazo         DATE,
    status        VARCHAR(20)  NOT NULL DEFAULT 'PENDENTE',
    UNIQUE (id_tarefa, ordem),
    CONSTRAINT ck_microetapa_status CHECK (status IN ('PENDENTE', 'CONCLUIDA')),
    FOREIGN KEY (id_tarefa) REFERENCES TAREFA_IA (id_tarefa) ON DELETE CASCADE
);

-- ---------- Camada física ----------

-- O dispositivo pertence à IES e é cedido em comodato (RNE-014); excluir o estudante só desfaz o vínculo
CREATE TABLE DISPOSITIVO_IOT (
    id_dispositivo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_instituicao INT          NOT NULL,
    id_estudante   INT,
    identificador  VARCHAR(60)  NOT NULL UNIQUE,              -- número de série
    modelo         VARCHAR(60)  NOT NULL,
    data_vinculo   TIMESTAMP,
    status         VARCHAR(20)  NOT NULL DEFAULT 'DISPONIVEL',
    CONSTRAINT ck_dispositivo_status CHECK (status IN ('DISPONIVEL', 'EMPRESTADO', 'MANUTENCAO', 'BAIXADO')),
    FOREIGN KEY (id_instituicao) REFERENCES INSTITUICAO (id_instituicao),
    FOREIGN KEY (id_estudante)   REFERENCES ESTUDANTE (id_estudante) ON DELETE SET NULL
);

CREATE TABLE SESSAO_ACUSTICA (
    id_sessao          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_dispositivo     INT         NOT NULL,
    id_aula            INT,
    inicio             TIMESTAMP    NOT NULL,
    fim                TIMESTAMP,
    modo_processamento VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
    status             VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
    CONSTRAINT ck_sessao_tempo  CHECK (fim IS NULL OR fim >= inicio),
    CONSTRAINT ck_sessao_modo   CHECK (modo_processamento IN ('LOCAL', 'NUVEM')),
    CONSTRAINT ck_sessao_status CHECK (status IN ('ATIVA', 'FINALIZADA', 'ERRO')),
    FOREIGN KEY (id_dispositivo) REFERENCES DISPOSITIVO_IOT (id_dispositivo),
    FOREIGN KEY (id_aula)        REFERENCES AULA (id_aula) ON DELETE SET NULL
);

CREATE TABLE MEDICAO_RUIDO (
    id_medicao  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_sessao   INT           NOT NULL,
    data_hora   TIMESTAMP      NOT NULL,                       -- antes "timestamp" (palavra reservada)
    nivel_ruido DECIMAL(5,2)  NOT NULL,                       -- dB
    snr         DECIMAL(5,2),
    frequencia  DECIMAL(8,2),
    CONSTRAINT ck_medicao_nivel CHECK (nivel_ruido BETWEEN 0 AND 140),
    FOREIGN KEY (id_sessao) REFERENCES SESSAO_ACUSTICA (id_sessao) ON DELETE CASCADE
);

-- ---------- Painel institucional (F-17, RNE-005, RNE-012) ----------
-- O painel lê só esta visão: ruído por sala, sem identificar estudante ou dispositivo,
-- e apenas quando houver ao menos 5 estudantes distintos no recorte.
CREATE VIEW VW_RUIDO_POR_SALA AS
SELECT a.sala,
       COUNT(DISTINCT s.id_sessao)             AS sessoes,
       ROUND(AVG(m.nivel_ruido), 1)            AS ruido_medio_db,
       ROUND(MAX(m.nivel_ruido), 1)            AS ruido_maximo_db
FROM MEDICAO_RUIDO m
JOIN SESSAO_ACUSTICA s ON s.id_sessao = m.id_sessao
JOIN DISPOSITIVO_IOT d ON d.id_dispositivo = s.id_dispositivo
JOIN AULA a            ON a.id_aula = s.id_aula
GROUP BY a.sala
HAVING COUNT(DISTINCT d.id_estudante) >= 5;

-- Usuário do painel: só enxerga a visão agregada (troque a senha antes de usar)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'painel_ies') THEN
        CREATE ROLE painel_ies LOGIN PASSWORD 'TroqueEstaSenha#2026';
    END IF;
END $$;
GRANT SELECT ON VW_RUIDO_POR_SALA TO painel_ies;

-- ---------- Dados iniciais ----------
INSERT INTO INSTITUICAO (nome, tipo, cidade, dominio_email)
VALUES ('UniEVANGÉLICA', 'PRIVADA', 'Anápolis', 'unievangelica.edu.br');

CREATE TABLE INSTITUICAO (
    id_instituicao INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(255),
    tipo           VARCHAR(255),
    cidade         VARCHAR(255)
);

CREATE TABLE ESTUDANTE (
    id_estudante   INT AUTO_INCREMENT PRIMARY KEY,
    id_instituicao INT,
    nome           VARCHAR(255),
    email          VARCHAR(255),
    data_cadastro  DATE,
    status         VARCHAR(255),
    FOREIGN KEY (id_instituicao) REFERENCES INSTITUICAO (id_instituicao)
);

CREATE TABLE PERFIL_ACESSIBILIDADE (
    id_perfil                INT AUTO_INCREMENT PRIMARY KEY,
    id_estudante             INT,
    estilo_aprendizagem      VARCHAR(255),
    tolerancia_sensorial     VARCHAR(255),
    comunicacao_preferencial VARCHAR(255),
    data_atualizacao         DATE,
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante)
);

CREATE TABLE PREFERENCIA (
    id_preferencia INT AUTO_INCREMENT PRIMARY KEY,
    id_perfil      INT,
    categoria      VARCHAR(255),
    descricao      VARCHAR(255),
    valor          VARCHAR(255),
    ativo          BOOLEAN,
    FOREIGN KEY (id_perfil) REFERENCES PERFIL_ACESSIBILIDADE (id_perfil)
);

CREATE TABLE DISCIPLINA (
    id_disciplina INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(255),
    codigo        VARCHAR(255),
    periodo       VARCHAR(255),
    professor     VARCHAR(255)
);

CREATE TABLE ESTUDANTE_DISCIPLINA (
    id_estudante  INT,
    id_disciplina INT,
    semestre      VARCHAR(255),
    status        VARCHAR(255),
    PRIMARY KEY (id_estudante, id_disciplina),
    FOREIGN KEY (id_estudante)  REFERENCES ESTUDANTE (id_estudante),
    FOREIGN KEY (id_disciplina) REFERENCES DISCIPLINA (id_disciplina)
);

CREATE TABLE AULA (
    id_aula        INT AUTO_INCREMENT PRIMARY KEY,
    id_disciplina  INT,
    data           DATE,
    horario_inicio TIME,
    horario_fim    TIME,
    sala           VARCHAR(255),
    status         VARCHAR(255),
    FOREIGN KEY (id_disciplina) REFERENCES DISCIPLINA (id_disciplina)
);

CREATE TABLE MUDANCA (
    id_mudanca     INT AUTO_INCREMENT PRIMARY KEY,
    id_aula        INT,
    tipo           VARCHAR(255),
    valor_anterior VARCHAR(255),
    valor_novo     VARCHAR(255),
    data_registro  DATETIME,
    motivo         VARCHAR(255),
    FOREIGN KEY (id_aula) REFERENCES AULA (id_aula)
);

CREATE TABLE TRANSCRICAO (
    id_transcricao INT AUTO_INCREMENT PRIMARY KEY,
    id_aula        INT,
    data_geracao   DATETIME,
    idioma         VARCHAR(255),
    status         VARCHAR(255),
    texto_completo TEXT,
    FOREIGN KEY (id_aula) REFERENCES AULA (id_aula)
);

CREATE TABLE SEGMENTO_TRANSCRICAO (
    id_segmento    INT AUTO_INCREMENT PRIMARY KEY,
    id_transcricao INT,
    ordem          INT,
    inicio         DECIMAL(10,2),
    fim            DECIMAL(10,2),
    texto          TEXT,
    FOREIGN KEY (id_transcricao) REFERENCES TRANSCRICAO (id_transcricao)
);

CREATE TABLE CONSENTIMENTO (
    id_consentimento   INT AUTO_INCREMENT PRIMARY KEY,
    id_estudante       INT,
    finalidade         VARCHAR(255),
    autorizado         BOOLEAN,
    data_consentimento DATETIME,
    data_revogacao     DATETIME,
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante)
);

CREATE TABLE FEEDBACK (
    id_feedback   INT AUTO_INCREMENT PRIMARY KEY,
    id_estudante  INT,
    id_aula       INT,
    tipo_recurso  VARCHAR(255),
    avaliacao     INT,
    comentario    VARCHAR(255),
    data_feedback DATETIME,
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante),
    FOREIGN KEY (id_aula)      REFERENCES AULA (id_aula)
);

CREATE TABLE TAREFA_IA (
    id_tarefa    INT AUTO_INCREMENT PRIMARY KEY,
    id_estudante INT,
    titulo       VARCHAR(255),
    descricao    VARCHAR(255),
    data_criacao DATETIME,
    prazo        DATE,
    status       VARCHAR(255),
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante)
);

CREATE TABLE MICROETAPA (
    id_microetapa INT AUTO_INCREMENT PRIMARY KEY,
    id_tarefa     INT,
    descricao     VARCHAR(255),
    ordem         INT,
    prazo         DATE,
    status        VARCHAR(255),
    FOREIGN KEY (id_tarefa) REFERENCES TAREFA_IA (id_tarefa)
);

CREATE TABLE DISPOSITIVO_IOT (
    id_dispositivo INT AUTO_INCREMENT PRIMARY KEY,
    id_estudante   INT,
    identificador  VARCHAR(255),
    modelo         VARCHAR(255),
    data_vinculo   DATE,
    status         VARCHAR(255),
    FOREIGN KEY (id_estudante) REFERENCES ESTUDANTE (id_estudante)
);

CREATE TABLE SESSAO_ACUSTICA (
    id_sessao          INT AUTO_INCREMENT PRIMARY KEY,
    id_dispositivo     INT,
    id_aula            INT,
    inicio             DATETIME,
    fim                DATETIME,
    modo_processamento VARCHAR(255),
    status             VARCHAR(255),
    FOREIGN KEY (id_dispositivo) REFERENCES DISPOSITIVO_IOT (id_dispositivo),
    FOREIGN KEY (id_aula)        REFERENCES AULA (id_aula)
);

CREATE TABLE MEDICAO_RUIDO (
    id_medicao  INT AUTO_INCREMENT PRIMARY KEY,
    id_sessao   INT,
    `timestamp` DATETIME,
    nivel_ruido DECIMAL(10,2),
    snr         DECIMAL(10,2),
    frequencia  DECIMAL(10,2),
    FOREIGN KEY (id_sessao) REFERENCES SESSAO_ACUSTICA (id_sessao)
);

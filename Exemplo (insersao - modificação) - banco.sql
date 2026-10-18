
--INSERÇÕES

-- a) Cadastrar a instituição
INSERT INTO INSTITUICAO (nome, tipo, cidade)
VALUES ('UniEVANGÉLICA', 'Universidade', 'Anápolis');

-- b) Cadastrar dois estudantes vinculados à instituição 1
INSERT INTO ESTUDANTE (id_instituicao, nome, email, data_cadastro, status)
VALUES
    (1, 'Maria Oliveira', 'maria.oliveira@email.com', CURDATE(), 'ATIVO'),
    (1, 'Lucas Santos',   'lucas.santos@email.com',   CURDATE(), 'ATIVO');

-- c) Criar o perfil de acessibilidade de cada estudante
INSERT INTO PERFIL_ACESSIBILIDADE
    (id_estudante, estilo_aprendizagem, tolerancia_sensorial, comunicacao_preferencial, data_atualizacao)
VALUES
    (1, 'VISUAL',   'BAIXA', 'TEXTO', CURDATE()),
    (2, 'AUDITIVO', 'MEDIA', 'VOZ',   CURDATE());

-- d) Cadastrar as preferências do perfil da Maria (id_perfil = 1)
INSERT INTO PREFERENCIA (id_perfil, categoria, descricao, valor, ativo)
VALUES
    (1, 'NOTIFICACAO', 'Aviso antecipado de mudança de sala', '30 min', TRUE),
    (1, 'TEXTO',       'Tamanho da fonte da transcrição',     'GRANDE', TRUE),
    (1, 'AUDIO',       'Nível de redução de ruído',           'ALTA',   TRUE);

-- e) Cadastrar as disciplinas
INSERT INTO DISCIPLINA (nome, codigo, periodo, professor)
VALUES
    ('Banco de Dados',           'BD101', '3º', 'Prof. Carlos Lima'),
    ('Engenharia de Requisitos', 'ER201', '3º', 'Prof.ª Ana Souza');

-- f) Matricular os estudantes nas disciplinas
INSERT INTO ESTUDANTE_DISCIPLINA (id_estudante, id_disciplina, semestre, status)
VALUES
    (1, 1, '2026/2', 'CURSANDO'),
    (1, 2, '2026/2', 'CURSANDO'),
    (2, 1, '2026/2', 'CURSANDO');

-- g) Cadastrar as aulas de hoje e a da próxima semana
INSERT INTO AULA (id_disciplina, data, horario_inicio, horario_fim, sala, status)
VALUES
    (1, CURDATE(),                           '08:00:00', '09:40:00', 'Sala 201', 'AGENDADA'),
    (2, CURDATE(),                           '10:00:00', '11:40:00', 'Sala 105', 'AGENDADA'),
    (1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), '08:00:00', '09:40:00', 'Sala 201', 'AGENDADA');

-- h) Registrar os consentimentos dos estudantes
INSERT INTO CONSENTIMENTO (id_estudante, finalidade, autorizado, data_consentimento, data_revogacao)
VALUES
    (1, 'TRANSCRICAO_AULA', TRUE, NOW(), NULL),
    (1, 'COLETA_RUIDO',     TRUE, NOW(), NULL),
    (2, 'TRANSCRICAO_AULA', TRUE, NOW(), NULL),
    (2, 'COLETA_RUIDO',     TRUE, NOW(), NULL);

-- i) Vincular um dispositivo IoT à Maria
INSERT INTO DISPOSITIVO_IOT (id_estudante, identificador, modelo, data_vinculo, status)
VALUES (1, 'DISP-0001', 'Modelo A1', CURDATE(), 'ATIVO');

-- j) Criar uma tarefa para a Maria e decompor em microetapas
INSERT INTO TAREFA_IA (id_estudante, titulo, descricao, data_criacao, prazo, status)
VALUES (1, 'Trabalho de modelagem de dados', 'Entregar o MER do projeto',
        NOW(), DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'EM_ANDAMENTO');

INSERT INTO MICROETAPA (id_tarefa, descricao, ordem, prazo, status)
VALUES
    (1, 'Listar as entidades do sistema',  1, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'PENDENTE'),
    (1, 'Definir os relacionamentos',      2, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'PENDENTE'),
    (1, 'Desenhar o diagrama final',       3, DATE_ADD(CURDATE(), INTERVAL 8 DAY), 'PENDENTE');



-- ATUALIZAÇÕES E EXCLUSÕES 


-- k) A Maria concluiu a primeira microetapa
UPDATE MICROETAPA
SET status = 'CONCLUIDA'
WHERE id_tarefa = 1 AND ordem = 1;

-- l) A Maria desativou a preferência de fonte grande
UPDATE PREFERENCIA
SET ativo = FALSE
WHERE id_perfil = 1 AND categoria = 'TEXTO';

-- m) O Lucas revogou o consentimento de coleta de ruído
UPDATE CONSENTIMENTO
SET autorizado = FALSE,
    data_revogacao = NOW()
WHERE id_estudante = 2 AND finalidade = 'COLETA_RUIDO';

-- n) O Lucas trancou a disciplina de Banco de Dados
UPDATE ESTUDANTE_DISCIPLINA
SET status = 'TRANCADA'
WHERE id_estudante = 2 AND id_disciplina = 1;

-- o) A preferência desativada não será mais usada: excluir do banco
DELETE FROM PREFERENCIA
WHERE id_perfil = 1 AND categoria = 'TEXTO' AND ativo = FALSE;


-- CONFERÊNCIA

SELECT * FROM AULA;
SELECT * FROM MUDANCA;
SELECT * FROM SESSAO_ACUSTICA;
SELECT * FROM MEDICAO_RUIDO;
SELECT * FROM TRANSCRICAO;
SELECT * FROM SEGMENTO_TRANSCRICAO;
SELECT * FROM FEEDBACK;

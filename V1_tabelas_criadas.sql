-- =====================================================
-- Banco de dados
-- =====================================================
CREATE DATABASE IF NOT EXISTS bwMarcenaria;
USE bwMarcenaria;

-- =====================================================
-- Tabela empresa
-- =====================================================
CREATE TABLE empresa (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    cnpj          VARCHAR(20)  NOT NULL,
    razao_social  VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150) NULL,
    telefone      VARCHAR(20)  NULL,
    data_cadastro TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_empresa_cnpj UNIQUE (cnpj)
);

-- =====================================================
-- Tabela usuario
-- =====================================================
CREATE TABLE usuario (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id         INT          NULL,
    tipo_cliente       VARCHAR(20)  NOT NULL,
    perfil             VARCHAR(20)  NOT NULL DEFAULT 'CLIENTE',
    nome               VARCHAR(100) NOT NULL,
    sobrenome          VARCHAR(100) NOT NULL,
    cpf                VARCHAR(20),
    data_nascimento    DATE,
    email              VARCHAR(150) NOT NULL,
    telefone           VARCHAR(20)  NULL,
    origem_contato     VARCHAR(30)  NULL,
    instagram_username VARCHAR(60)  NULL,
    instagram_id       VARCHAR(40)  NULL,
    senha_hash         VARCHAR(100) NULL,
    ativo              BOOLEAN      NOT NULL DEFAULT TRUE,
    etapa_funil        VARCHAR(20)  DEFAULT 'Novo Lead',
    data_cadastro      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_usuario_email     UNIQUE (email),
    CONSTRAINT uk_usuario_instagram UNIQUE (instagram_id),

    CONSTRAINT chk_usuario_tipo_cliente
        CHECK (tipo_cliente IN ('Pessoa Fisica', 'Pessoa Juridica')),

    CONSTRAINT chk_usuario_perfil 
        CHECK (perfil IN ('CLIENTE', 'ADMIN')),

    CONSTRAINT chk_usuario_etapa_funil
        CHECK (etapa_funil IN (
            'Novo Lead', 'Em Qualificacao', 'Qualificado', 
            'Apresentacao', 'Em Negociacao', 'Fechado'
        )),

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (empresa_id) REFERENCES empresa (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE INDEX idx_usuario_empresa ON usuario (empresa_id);

-- =====================================================
-- Tabela projetos
-- =====================================================
CREATE TABLE projetos (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id     INT          NOT NULL,
    titulo_projeto VARCHAR(150) NOT NULL,
    valor_total    DECIMAL(10, 2),
    status         VARCHAR(20)  DEFAULT 'Planejamento',

    CONSTRAINT chk_projetos_status
        CHECK (status IN ('Planejamento', 'Em Execucao', 'Concluido', 'Cancelado')),

    CONSTRAINT fk_projetos_cliente
        FOREIGN KEY (cliente_id) REFERENCES usuario (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela calendario_eventos
-- =====================================================
CREATE TABLE calendario_eventos (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id  INT         NOT NULL,
    tipo_evento VARCHAR(20) NOT NULL,
    data_inicio TIMESTAMP   NOT NULL,
    data_fim    TIMESTAMP   NOT NULL,
    observacoes TEXT,

    CONSTRAINT chk_calendario_tipo_evento
        CHECK (tipo_evento IN ('ENTREGA', 'MONTAGEM', 'VISITA')),

    CONSTRAINT fk_calendario_projeto
        FOREIGN KEY (projeto_id) REFERENCES projetos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela chatbot_logs
-- =====================================================
CREATE TABLE chatbot_logs (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id       INT,
    instagram_id     VARCHAR(40) NULL,
    mensagem_usuario TEXT        NOT NULL,
    resposta_ia      TEXT        NOT NULL,
    data_interacao   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_chatbot_cliente
        FOREIGN KEY (cliente_id) REFERENCES usuario (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE INDEX idx_chat_instagram ON chatbot_logs (instagram_id);

-- =====================================================
-- Tabela fluxo_financeiro
-- =====================================================
CREATE TABLE fluxo_financeiro (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id     INT            NOT NULL,
    tipo_transacao VARCHAR(10)    NOT NULL,
    valor          DECIMAL(10, 2) NOT NULL,
    data_transacao DATETIME       NOT NULL,
    categoria      VARCHAR(100),
    descricao      TEXT,
    status         VARCHAR(20)    DEFAULT 'Pendente',

    CONSTRAINT chk_financeiro_tipo
        CHECK (tipo_transacao IN ('RECEITA', 'DESPESA')),

    CONSTRAINT chk_financeiro_status
        CHECK (status IN ('PENDENTE', 'PAGO', 'ATRASADO', 'CANCELADO')),

    CONSTRAINT fk_financeiro_projeto
        FOREIGN KEY (projeto_id) REFERENCES projetos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela rastreabilidade_madeira
-- =====================================================
CREATE TABLE rastreabilidade_madeira (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id    INT          NOT NULL,
    lote          VARCHAR(100) NOT NULL,
    tipo_madeira  VARCHAR(100) NOT NULL,
    fornecedor    VARCHAR(150) NOT NULL,
    origem        VARCHAR(150) NOT NULL,
    certificacoes VARCHAR(255) NOT NULL,
    volume        VARCHAR(100) NOT NULL,
    data_registro TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_madeira_projeto
        FOREIGN KEY (projeto_id) REFERENCES projetos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela simulacoes_ia
-- =====================================================
CREATE TABLE simulacoes_ia (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id        INT         NOT NULL,
    descricao_prompt  TEXT        NOT NULL,
    ambiente          VARCHAR(20) NOT NULL,
    estilo_desejado   VARCHAR(20) NOT NULL,
    acabamento        VARCHAR(100),
    imagem_gerada_url VARCHAR(255),
    data_simulacao    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_simulacoes_ambiente
        CHECK (ambiente IN ('COZINHA', 'QUARTO', 'SALA', 'BANHEIRO', 'ESCRITORIO', 'OUTRO')),

    CONSTRAINT chk_simulacoes_estilo
        CHECK (estilo_desejado IN ('MODERNO', 'RUSTICO', 'MINIMALISTA', 'INDUSTRIAL', 'CLASSICO', 'OUTRO')),

    CONSTRAINT fk_simulacoes_cliente
        FOREIGN KEY (cliente_id) REFERENCES usuario (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela tabela_precos_referencia
-- =====================================================
CREATE TABLE tabela_precos_referencia (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    categoria        VARCHAR(30)    NOT NULL,
    preco_referencia DECIMAL(10, 2) NOT NULL,
    descricao        TEXT,
    material_base    VARCHAR(150)   NOT NULL,
    unidade          VARCHAR(20)    NOT NULL,
    data_atualizacao TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_categoria
        CHECK (categoria IN ('Marcenaria Planejada', 'Dormitorio e Closset', 'Mao de Obra')),

    CONSTRAINT chk_unidade
        CHECK (unidade IN ('Unidade', 'Metro Quadrado', 'Metro Linear', 'Hora'))
);

-- =====================================================
-- Tabela lead_instagram
-- =====================================================
CREATE TABLE lead_instagram (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    instagram_id           VARCHAR(40) NOT NULL,
    crm_lead_id            VARCHAR(30),
    nome                   VARCHAR(100),
    sao_paulo              BOOLEAN     DEFAULT FALSE,
    ambiente               VARCHAR(60),
    movel                  VARCHAR(80),
    cor                    VARCHAR(40),
    material               VARCHAR(40),
    orcamento              DECIMAL(10, 2),
    situacao_projeto       VARCHAR(40),
    precisa_visita_tecnica BOOLEAN     DEFAULT FALSE,
    resumo_conversa        TEXT,
    token_hash             CHAR(64),
    token_expira_em        DATETIME,
    token_usado_em         DATETIME    NULL,
    link_enviado_em        DATETIME    NULL,
    usuario_id             INT         NULL,
    criado_em              TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    atualizado_em          TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uk_lead_instagram UNIQUE (instagram_id),
    CONSTRAINT uk_lead_token     UNIQUE (token_hash),

    CONSTRAINT fk_lead_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =====================================================
-- Tabela mensagens_chat
-- =====================================================
CREATE TABLE mensagens_chat (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT         NOT NULL,
    autor_id   INT         NULL,
    remetente  VARCHAR(10) NOT NULL,
    conteudo   TEXT        NOT NULL,
    criado_em  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_mensagem_remetente 
        CHECK (remetente IN ('CLIENTE', 'ADMIN')),

    CONSTRAINT fk_mensagem_cliente
        FOREIGN KEY (cliente_id) REFERENCES usuario (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_mensagem_autor
        FOREIGN KEY (autor_id) REFERENCES usuario (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE INDEX idx_mensagem_conversa ON mensagens_chat (cliente_id, id);
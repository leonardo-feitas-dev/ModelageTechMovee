-- ============================================
-- Extensões Necessárias
-- ============================================
-- Ativando a extensão 'uuid-ossp' para gerar UUIDs, se necessário
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Tabelas
-- ============================================

-- Tabela de Endereços
CREATE TABLE Enderecos (
    id SERIAL PRIMARY KEY,
    cep VARCHAR(9) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    rua VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL
);

-- Tabela de Fotos
CREATE TABLE Fotos (
    id SERIAL PRIMARY KEY,
    url VARCHAR(255) NOT NULL
);

-- Tabela de Telefones
CREATE TABLE Telefones (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(15) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Responsavel', 'Transportador'))
);

-- Tabela de Responsáveis
CREATE TABLE Responsaveis (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    foto_id INT REFERENCES Fotos(id),
    endereco_id INT REFERENCES Enderecos(id),
    telefone_id INT REFERENCES Telefones(id)
);

-- Tabela de Transportadores
CREATE TABLE Transportadores (
    cnh VARCHAR(11) PRIMARY KEY,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    foto_id INT REFERENCES Fotos(id),
    telefone_id INT REFERENCES Telefones(id)
);

-- Tabela de Vans
CREATE TABLE Vans (
    placa VARCHAR(7) PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    acessibilidade BOOLEAN NOT NULL,
    mensalidade DECIMAL(10, 2) NOT NULL,
    capacidade INT NOT NULL,
    foto_id INT REFERENCES Fotos(id),
    transportador_cnh VARCHAR(11) REFERENCES Transportadores(cnh)
);

-- Tabela de Escolas
CREATE TABLE Escolas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco_id INT REFERENCES Enderecos(id)
);

-- Tabela de Alunos
CREATE TABLE Alunos (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE NOT NULL,
    escola_id INT REFERENCES Escolas(id),
    pcd BOOLEAN NOT NULL,
    id_foto INT REFERENCES Fotos(id),
    endereco_id INT REFERENCES Enderecos(id),
    responsavel_cpf VARCHAR(11) REFERENCES Responsaveis(cpf),
    turno VARCHAR(10) NOT NULL CHECK (turno IN ('Manha', 'Tarde', 'Noite'))
);

-- ============================================
-- Tabelas de Logs para todas as tabelas
-- ============================================

-- Log para Enderecos
CREATE TABLE LogEnderecos (
    id SERIAL PRIMARY KEY,
    endereco_id INT,
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Fotos
CREATE TABLE LogFotos (
    id SERIAL PRIMARY KEY,
    foto_id INT,
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Telefones
CREATE TABLE LogTelefones (
    id SERIAL PRIMARY KEY,
    telefone_id INT,
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Escolas
CREATE TABLE LogEscolas (
    id SERIAL PRIMARY KEY,
    escola_id INT,
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Responsaveis
CREATE TABLE LogResponsaveis (
    id SERIAL PRIMARY KEY,
    responsavel_cpf VARCHAR(11),
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Transportadores
CREATE TABLE LogTransportadores (
    id SERIAL PRIMARY KEY,
    transportador_cnh VARCHAR(11),
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Vans
CREATE TABLE LogVans (
    id SERIAL PRIMARY KEY,
    van_placa VARCHAR(7),
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Log para Alunos
CREATE TABLE LogAlunos (
    id SERIAL PRIMARY KEY,
    aluno_cpf VARCHAR(11),
    operacao VARCHAR(10),
    alteracao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Functions e Triggers para logs das tabelas
-- ============================================

-- Function genérica para logs detalhados
CREATE OR REPLACE FUNCTION log_detalhado()
RETURNS TRIGGER AS $$
DECLARE
    v_alteracao TEXT;
    v_id_field TEXT;
    v_id_value TEXT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_alteracao := 'Registro excluído: ' || row_to_json(OLD)::TEXT;
        v_id_field := TG_ARGV[0];
        EXECUTE format('INSERT INTO %I(%I, operacao, alteracao) VALUES ($1, $2, $3)',
            TG_ARGV[1], v_id_field)
        USING OLD.*::JSON->>v_id_field, TG_OP, v_alteracao;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        v_alteracao := 'Registro atualizado de: ' || row_to_json(OLD)::TEXT || ' para ' || row_to_json(NEW)::TEXT;
        v_id_field := TG_ARGV[0];
        EXECUTE format('INSERT INTO %I(%I, operacao, alteracao) VALUES ($1, $2, $3)',
            TG_ARGV[1], v_id_field)
        USING NEW.*::JSON->>v_id_field, TG_OP, v_alteracao;
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        v_alteracao := 'Registro inserido: ' || row_to_json(NEW)::TEXT;
        v_id_field := TG_ARGV[0];
        EXECUTE format('INSERT INTO %I(%I, operacao, alteracao) VALUES ($1, $2, $3)',
            TG_ARGV[1], v_id_field)
        USING NEW.*::JSON->>v_id_field, TG_OP, v_alteracao;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers usando a função genérica

-- Trigger para Enderecos
CREATE TRIGGER trg_log_enderecos
AFTER INSERT OR UPDATE OR DELETE ON Enderecos
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('id', 'LogEnderecos');

-- Trigger para Fotos
CREATE TRIGGER trg_log_fotos
AFTER INSERT OR UPDATE OR DELETE ON Fotos
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('id', 'LogFotos');

-- Trigger para Telefones
CREATE TRIGGER trg_log_telefones
AFTER INSERT OR UPDATE OR DELETE ON Telefones
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('id', 'LogTelefones');

-- Trigger para Escolas
CREATE TRIGGER trg_log_escolas
AFTER INSERT OR UPDATE OR DELETE ON Escolas
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('id', 'LogEscolas');

-- Trigger para Responsaveis
CREATE TRIGGER trg_log_responsaveis
AFTER INSERT OR UPDATE OR DELETE ON Responsaveis
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('cpf', 'LogResponsaveis');

-- Trigger para Transportadores
CREATE TRIGGER trg_log_transportadores
AFTER INSERT OR UPDATE OR DELETE ON Transportadores
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('cnh', 'LogTransportadores');

-- Trigger para Vans
CREATE TRIGGER trg_log_vans
AFTER INSERT OR UPDATE OR DELETE ON Vans
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('placa', 'LogVans');

-- Trigger para Alunos
CREATE TRIGGER trg_log_alunos
AFTER INSERT OR UPDATE OR DELETE ON Alunos
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('cpf', 'LogAlunos');

-- ============================================
-- Procedures de Inserção, Atualização e Deleção
-- ============================================

-- Procedures para Responsaveis
CREATE OR REPLACE PROCEDURE inserir_responsavel(
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_email VARCHAR(100),
    p_senha VARCHAR(100),
    p_foto_id INT,
    p_endereco_id INT,
    p_telefone_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'CPF já cadastrado.';
    END IF;
    IF EXISTS (SELECT 1 FROM Responsaveis WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email já cadastrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_telefone_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    INSERT INTO Responsaveis (cpf, nome, dt_nascimento, email, senha, foto_id, endereco_id, telefone_id)
    VALUES (p_cpf, p_nome, p_dt_nascimento, p_email, p_senha, p_foto_id, p_endereco_id, p_telefone_id);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_responsavel(
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_email VARCHAR(100),
    p_senha VARCHAR(100),
    p_foto_id INT,
    p_endereco_id INT,
    p_telefone_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF NOT EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'Responsável não encontrado.';
    END IF;
    IF EXISTS (SELECT 1 FROM Responsaveis WHERE email = p_email AND cpf != p_cpf) THEN
        RAISE EXCEPTION 'Email já cadastrado para outro responsável.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_telefone_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    UPDATE Responsaveis
    SET nome = p_nome, dt_nascimento = p_dt_nascimento, email = p_email, senha = p_senha,
        foto_id = p_foto_id, endereco_id = p_endereco_id, telefone_id = p_telefone_id
    WHERE cpf = p_cpf;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_responsavel(p_cpf VARCHAR(11))
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'Responsável não encontrado.';
    END IF;
    DELETE FROM Responsaveis WHERE cpf = p_cpf;
END;
$$;

-- Procedures para Transportadores
CREATE OR REPLACE PROCEDURE inserir_transportador(
    p_cnh VARCHAR(11),
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_email VARCHAR(100),
    p_senha VARCHAR(100),
    p_foto_id INT,
    p_telefone_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF EXISTS (SELECT 1 FROM Transportadores WHERE cnh = p_cnh) THEN
        RAISE EXCEPTION 'CNH já cadastrada.';
    END IF;
    IF EXISTS (SELECT 1 FROM Transportadores WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'CPF já cadastrado.';
    END IF;
    IF EXISTS (SELECT 1 FROM Transportadores WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email já cadastrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_telefone_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    INSERT INTO Transportadores (cnh, cpf, nome, dt_nascimento, email, senha, foto_id, telefone_id)
    VALUES (p_cnh, p_cpf, p_nome, p_dt_nascimento, p_email, p_senha, p_foto_id, p_telefone_id);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_transportador(
    p_cnh VARCHAR(11),
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_email VARCHAR(100),
    p_senha VARCHAR(100),
    p_foto_id INT,
    p_telefone_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF NOT EXISTS (SELECT 1 FROM Transportadores WHERE cnh = p_cnh) THEN
        RAISE EXCEPTION 'Transportador não encontrado.';
    END IF;
    IF EXISTS (SELECT 1 FROM Transportadores WHERE cpf = p_cpf AND cnh != p_cnh) THEN
        RAISE EXCEPTION 'CPF já cadastrado para outro transportador.';
    END IF;
    IF EXISTS (SELECT 1 FROM Transportadores WHERE email = p_email AND cnh != p_cnh) THEN
        RAISE EXCEPTION 'Email já cadastrado para outro transportador.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_telefone_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    UPDATE Transportadores
    SET cpf = p_cpf, nome = p_nome, dt_nascimento = p_dt_nascimento, email = p_email,
        senha = p_senha, foto_id = p_foto_id, telefone_id = p_telefone_id
    WHERE cnh = p_cnh;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_transportador(p_cnh VARCHAR(11))
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Transportadores WHERE cnh = p_cnh) THEN
        RAISE EXCEPTION 'Transportador não encontrado.';
    END IF;
    DELETE FROM Transportadores WHERE cnh = p_cnh;
END;
$$;

-- Procedures para Alunos
CREATE OR REPLACE PROCEDURE inserir_aluno(
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_escola_id INT,
    p_pcd BOOLEAN,
    p_id_foto INT,
    p_endereco_id INT,
    p_responsavel_cpf VARCHAR(11),
    p_turno VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF EXISTS (SELECT 1 FROM Alunos WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'CPF já cadastrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Escolas WHERE id = p_escola_id) THEN
        RAISE EXCEPTION 'Escola não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_id_foto) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_responsavel_cpf) THEN
        RAISE EXCEPTION 'Responsável não encontrado.';
    END IF;
    INSERT INTO Alunos (cpf, nome, dt_nascimento, escola_id, pcd, id_foto, endereco_id, responsavel_cpf, turno)
    VALUES (p_cpf, p_nome, p_dt_nascimento, p_escola_id, p_pcd, p_id_foto, p_endereco_id, p_responsavel_cpf, p_turno);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_aluno(
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    p_dt_nascimento DATE,
    p_escola_id INT,
    p_pcd BOOLEAN,
    p_id_foto INT,
    p_endereco_id INT,
    p_responsavel_cpf VARCHAR(11),
    p_turno VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF NOT EXISTS (SELECT 1 FROM Alunos WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'Aluno não encontrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Escolas WHERE id = p_escola_id) THEN
        RAISE EXCEPTION 'Escola não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_id_foto) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_responsavel_cpf) THEN
        RAISE EXCEPTION 'Responsável não encontrado.';
    END IF;
    UPDATE Alunos
    SET nome = p_nome, dt_nascimento = p_dt_nascimento, escola_id = p_escola_id,
        pcd = p_pcd, id_foto = p_id_foto, endereco_id = p_endereco_id,
        responsavel_cpf = p_responsavel_cpf, turno = p_turno
    WHERE cpf = p_cpf;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_aluno(p_cpf VARCHAR(11))
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Alunos WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'Aluno não encontrado.';
    END IF;
    DELETE FROM Alunos WHERE cpf = p_cpf;
END;
$$;

-- Procedures para Vans
CREATE OR REPLACE PROCEDURE inserir_van(
    p_placa VARCHAR(7),
    p_modelo VARCHAR(50),
    p_acessibilidade BOOLEAN,
    p_mensalidade DECIMAL(10, 2),
    p_foto_id INT,
    p_transportador_cnh VARCHAR(11),
    p_capacidade INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF EXISTS (SELECT 1 FROM Vans WHERE placa = p_placa) THEN
        RAISE EXCEPTION 'Placa já cadastrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Transportadores WHERE cnh = p_transportador_cnh) THEN
        RAISE EXCEPTION 'Transportador não encontrado.';
    END IF;
    INSERT INTO Vans (placa, modelo, acessibilidade, mensalidade, foto_id, transportador_cnh, capacidade)
    VALUES (p_placa, p_modelo, p_acessibilidade, p_mensalidade, p_foto_id, p_transportador_cnh, p_capacidade);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_van(
    p_placa VARCHAR(7),
    p_modelo VARCHAR(50),
    p_acessibilidade BOOLEAN,
    p_mensalidade DECIMAL(10, 2),
    p_foto_id INT,
    p_transportador_cnh VARCHAR(11),
    p_capacidade INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validações
    IF NOT EXISTS (SELECT 1 FROM Vans WHERE placa = p_placa) THEN
        RAISE EXCEPTION 'Van não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_foto_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Transportadores WHERE cnh = p_transportador_cnh) THEN
        RAISE EXCEPTION 'Transportador não encontrado.';
    END IF;
    UPDATE Vans
    SET modelo = p_modelo, acessibilidade = p_acessibilidade, mensalidade = p_mensalidade,
        foto_id = p_foto_id, transportador_cnh = p_transportador_cnh, capacidade = p_capacidade
    WHERE placa = p_placa;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_van(p_placa VARCHAR(7))
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Vans WHERE placa = p_placa) THEN
        RAISE EXCEPTION 'Van não encontrada.';
    END IF;
    DELETE FROM Vans WHERE placa = p_placa;
END;
$$;

-- Procedures para Endereços
CREATE OR REPLACE PROCEDURE inserir_endereco(
    p_cep VARCHAR(9),
    p_bairro VARCHAR(100),
    p_rua VARCHAR(100),
    p_numero VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Enderecos (cep, bairro, rua, numero)
    VALUES (p_cep, p_bairro, p_rua, p_numero);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_endereco(
    p_id INT,
    p_cep VARCHAR(9),
    p_bairro VARCHAR(100),
    p_rua VARCHAR(100),
    p_numero VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    UPDATE Enderecos
    SET cep = p_cep, bairro = p_bairro, rua = p_rua, numero = p_numero
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_endereco(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    DELETE FROM Enderecos WHERE id = p_id;
END;
$$;

-- Procedures para Telefones
CREATE OR REPLACE PROCEDURE inserir_telefone(
    p_numero VARCHAR(15),
    p_tipo VARCHAR(20)
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Telefones (numero, tipo)
    VALUES (p_numero, p_tipo);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_telefone(
    p_id INT,
    p_numero VARCHAR(15),
    p_tipo VARCHAR(20)
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    UPDATE Telefones
    SET numero = p_numero, tipo = p_tipo
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_telefone(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Telefones WHERE id = p_id) THEN
        RAISE EXCEPTION 'Telefone não encontrado.';
    END IF;
    DELETE FROM Telefones WHERE id = p_id;
END;
$$;

-- Procedures para Fotos
CREATE OR REPLACE PROCEDURE inserir_foto(p_url VARCHAR(255))
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Fotos (url) VALUES (p_url);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_foto(p_id INT, p_url VARCHAR(255))
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    UPDATE Fotos
    SET url = p_url
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_foto(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Fotos WHERE id = p_id) THEN
        RAISE EXCEPTION 'Foto não encontrada.';
    END IF;
    DELETE FROM Fotos WHERE id = p_id;
END;
$$;

-- Procedures para Escolas
CREATE OR REPLACE PROCEDURE inserir_escola(
    p_nome VARCHAR(100),
    p_endereco_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    INSERT INTO Escolas (nome, endereco_id)
    VALUES (p_nome, p_endereco_id);
END;
$$;

CREATE OR REPLACE PROCEDURE atualizar_escola(
    p_id INT,
    p_nome VARCHAR(100),
    p_endereco_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Escolas WHERE id = p_id) THEN
        RAISE EXCEPTION 'Escola não encontrada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Enderecos WHERE id = p_endereco_id) THEN
        RAISE EXCEPTION 'Endereço não encontrado.';
    END IF;
    UPDATE Escolas
    SET nome = p_nome, endereco_id = p_endereco_id
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE deletar_escola(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Escolas WHERE id = p_id) THEN
        RAISE EXCEPTION 'Escola não encontrada.';
    END IF;
    DELETE FROM Escolas WHERE id = p_id;
END;
$$;

-- ============================================
-- Índices para Otimização
-- ============================================

-- Índice na tabela Responsaveis para pesquisa por email
CREATE UNIQUE INDEX idx_responsaveis_email ON Responsaveis(email);

-- Índice na tabela Responsaveis para pesquisa por endereço
CREATE INDEX idx_responsaveis_endereco_id ON Responsaveis(endereco_id);

-- Índice na tabela Responsaveis para pesquisa por telefone
CREATE INDEX idx_responsaveis_telefone_id ON Responsaveis(telefone_id);

-- Índice na tabela Transportadores para pesquisa por email
CREATE UNIQUE INDEX idx_transportadores_email ON Transportadores(email);

-- Índice na tabela Transportadores para pesquisa por CPF
CREATE UNIQUE INDEX idx_transportadores_cpf ON Transportadores(cpf);

-- Índice na tabela Transportadores para pesquisa por telefone
CREATE INDEX idx_transportadores_telefone_id ON Transportadores(telefone_id);

-- Índice na tabela Alunos para pesquisa por escola
CREATE INDEX idx_alunos_escola_id ON Alunos(escola_id);

-- Índice na tabela Alunos para pesquisa por responsável
CREATE INDEX idx_alunos_responsavel_cpf ON Alunos(responsavel_cpf);

-- Índice na tabela Alunos para pesquisa por turno
CREATE INDEX idx_alunos_turno ON Alunos(turno);

-- Índice na tabela Vans para pesquisa por transportador
CREATE INDEX idx_vans_transportador_cnh ON Vans(transportador_cnh);

-- Índice na tabela Enderecos para pesquisa por CEP
CREATE INDEX idx_enderecos_cep ON Enderecos(cep);

-- Índice na tabela Telefones para pesquisa por número
CREATE INDEX idx_telefones_numero ON Telefones(numero);

-- Índice na tabela Escolas para pesquisa por nome
CREATE INDEX idx_escolas_nome ON Escolas(nome);

-- Índice na tabela Fotos para otimizar JOINs
CREATE INDEX idx_fotos_id ON Fotos(id);

-- ============================================
-- Inserts de Dados
-- ============================================

-- Inserts para a tabela Endereços
INSERT INTO Enderecos (cep, bairro, rua, numero) VALUES 
('52009-947', 'Conjunto Floramar', 'Via Gonçalves', '6284'),
('19324-555', 'Esplanada', 'Conjunto da Rosa', '9448'),
('99901-668', 'Vila Das Oliveiras', 'Avenida da Rocha', '5524'),
('86305-254', 'Jonas Veiga', 'Praia de da Mota', '9786'),
('59993-019', 'Califórnia', 'Passarela de Pereira', '6778'),
('01234-567', 'Centro', 'Rua das Flores', '123'),
('54321-098', 'Bela Vista', 'Avenida Brasil', '456'),
('12345-678', 'Jardim América', 'Rua dos Limoeiros', '789'),
('98765-432', 'Vila Nova', 'Avenida das Palmas', '321'),
('67890-123', 'Parque São Jorge', 'Rua dos Girassóis', '654');

-- Inserts para a tabela Fotos
INSERT INTO Fotos (url) VALUES 
('https://placekitten.com/400/300'),
('https://placeimg.com/400/300/any'),
('https://placeimg.com/400/300/any'),
('https://www.lorempixel.com/400/300'),
('https://dummyimage.com/400x300'),
('https://placekitten.com/400/300?image=1'),
('https://placekitten.com/400/300?image=2'),
('https://placekitten.com/400/300?image=3'),
('https://placekitten.com/400/300?image=4'),
('https://placekitten.com/400/300?image=5');

-- Inserts para a tabela Telefones
INSERT INTO Telefones (numero, tipo) VALUES 
('+55 3311-7385', 'Transportador'),
('+55 8454-7770', 'Transportador'),
('+55 8836-0461', 'Transportador'),
('+55 1039-1256', 'Transportador'),
('+55 4257-5766', 'Responsavel'),
('+55 9876-5432', 'Transportador'),
('+55 9876-5432', 'Transportador'),
('+55 1234-5678', 'Transportador'),
('+55 9888-7777', 'Responsavel'),
('+55 9999-8888', 'Responsavel');

-- Inserts para a tabela Responsaveis
INSERT INTO Responsaveis (cpf, nome, dt_nascimento, email, senha, foto_id, endereco_id, telefone_id) VALUES 
('98014362551', 'Kaique Vieira', '1956-09-13', 'lucasramos@bol.com.br', '(!Xm7L@m8O', 1, 1, 5),
('93421587655', 'Luiz Gustavo Sales', '1976-05-28', 'thiagodas-neves@da.com', 'OY+30IiQv#', 2, 2, 10),
('73406951252', 'Ana Luiza Nunes', '1949-03-03', 'caldeirapedro-miguel@hotmail.com', 'Hs1$HONx_M', 3, 3, 6),
('01397856203', 'Murilo da Mota', '1963-06-01', 'da-pazolivia@bol.com.br', 'd^P39mUeEJ', 4, 4, 8),
('80134269551', 'Sra. Emilly Porto', '2003-05-30', 'juliana64@yahoo.com.br', '+6FJqHA#CW', 5, 5, 9),
('12345678900', 'João da Silva', '1980-01-01', 'joao.silva@exemplo.com', 'senha123', 6, 6, 7),
('98765432100', 'Maria Oliveira', '1975-02-02', 'maria.oliveira@exemplo.com', 'senha456', 7, 7, 4),
('32165498700', 'Carlos Almeida', '1985-03-03', 'carlos.almeida@exemplo.com', 'senha789', 8, 8, 3),
('65412398700', 'Patrícia Lima', '1990-04-04', 'patricia.lima@exemplo.com', 'senha000', 9, 9, 2),
('98732165400', 'Fernando Sousa', '1978-05-05', 'fernando.sousa@exemplo.com', 'senha111', 10, 10, 1);

-- Inserts para a tabela Transportadores
INSERT INTO Transportadores (cnh, cpf, nome, dt_nascimento, email, senha, foto_id, telefone_id) VALUES 
('82605479374', '81094375675', 'Davi Luiz Costela', '1969-05-29', 'joao-vitor65@ribeiro.br', '@v8(Pz%uQb', 1, 1),
('91045862398', '79510284360', 'Isadora Pinto', '1971-10-06', 'fariasana-clara@da.br', 'h)fyN8lkcY', 2, 2),
('50783924160', '36810472940', 'Stephany Silva', '1986-08-07', 'ribeiroana-luiza@lopes.com', ')9TV3pUsDU', 3, 3),
('38670452162', '68312945024', 'Vitor Gabriel Gomes', '1968-10-30', 'henriqueda-mata@ig.com.br', '#D92QO5mh8', 4, 4),
('43872196022', '50819473693', 'Sabrina da Mota', '1955-04-12', 'ana-sophia93@fogaca.com', 'GSCUoNjY!2', 5, 5),
('14523657800', '36987415962', 'Roberto Carlos', '1980-07-10', 'roberto.carlos@exemplo.com', 'rc@2023!', 6, 6),
('85296374185', '25478912345', 'Sofia Lima', '1972-02-20', 'sofia.lima@exemplo.com', 'sofia123', 7, 7),
('14725836912', '95175346858', 'Bruno Silva', '1988-11-15', 'bruno.silva@exemplo.com', 'bruno2023', 8, 8),
('45678912345', '75315945689', 'Camila Almeida', '1995-12-25', 'camila.almeida@exemplo.com', 'camila2023', 9, 9),
('96385274158', '14725836912', 'Lucas Ribeiro', '1983-03-13', 'lucas.ribeiro@exemplo.com', 'lucas2023', 10, 10);

-- Inserts para a tabela Vans
INSERT INTO Vans (placa, modelo, acessibilidade, mensalidade, capacidade, foto_id, transportador_cnh) VALUES 
('ABC1D23', 'Furgão Ford', true, 1500.00, 3, 1, '82605479374'),
('BCD2E34', 'Van Mercedes', false, 2000.00, 7, 2, '91045862398'),
('CDE3F45', 'Furgão Volkswagen', true, 1800.00, 5, 3, '50783924160'),
('DEF4G56', 'Van Fiat', false, 2200.00, 10, 4, '38670452162'),
('EFG5H67', 'Furgão Chevrolet', true, 1600.00, 4, 5, '43872196022'),
('FGH6I78', 'Van Renault', false, 1700.00, 6, 6, '14523657800'),
('GHI7J89', 'Furgão Iveco', true, 1900.00, 8, 7, '85296374185'),
('HIJ8K90', 'Van Nissan', false, 2400.00, 12, 8, '14725836912'),
('JKL9L01', 'Furgão Citroen', true, 2300.00, 9, 9, '45678912345'),
('KLM0M12', 'Van Kia', false, 2500.00, 15, 10, '96385274158');

-- Inserts para a tabela Escolas
INSERT INTO Escolas (nome, endereco_id) VALUES 
('Escola ABC', 1),
('Escola do Futuro', 2),
('Escola da Vida', 3),
('Escola Nova', 4),
('Escola da Esperança', 5),
('Escola de Artes', 6),
('Escola Técnica', 7),
('Escola do Saber', 8),
('Escola Profissionalizante', 9),
('Escola Internacional', 10);

-- Inserts para a tabela Alunos
INSERT INTO Alunos (cpf, nome, dt_nascimento, escola_id, pcd, id_foto, endereco_id, responsavel_cpf, turno) VALUES 
('12345678900', 'Lucas Almeida', '2010-01-01', 1, false, 1, 1, '98014362551', 'Manha'),
('23456789001', 'Mariana Costa', '2009-02-02', 2, false, 2, 2, '93421587655', 'Tarde'),
('34567890102', 'Pedro Henrique', '2011-03-03', 3, true, 3, 3, '73406951252', 'Noite'),
('45678901203', 'Gabriel Oliveira', '2012-04-04', 4, false, 4, 4, '01397856203', 'Manha'),
('56789012304', 'Isabela Santos', '2013-05-05', 5, true, 5, 5, '80134269551', 'Tarde'),
('67890123405', 'Rafael Lima', '2014-06-06', 6, false, 6, 6, '12345678900', 'Noite'),
('78901234506', 'Ana Clara', '2015-07-07', 7, false, 7, 7, '98765432100', 'Manha'),
('89012345607', 'Maria Eduarda', '2016-08-08', 8, true, 8, 8, '32165498700', 'Tarde'),
('90123456708', 'Thiago Martins', '2017-09-09', 9, false, 9, 9, '65412398700', 'Noite'),
('01234567809', 'Bruna Pereira', '2018-10-10', 10, false, 10, 10, '98732165400', 'Manha');

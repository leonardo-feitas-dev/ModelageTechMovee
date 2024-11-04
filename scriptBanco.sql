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
    telefone_id INT REFERENCES Telefones(id)  -- Novo campo
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
    telefone_id INT REFERENCES Telefones(id)  -- Novo campo
);

-- Tabela de Vans
CREATE TABLE Vans (
    placa VARCHAR(7) PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    acessibilidade BOOLEAN NOT NULL,
    mensalidade DECIMAL(10, 2) NOT NULL,
    capacidade INT NOT NULL,  -- Novo campo
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

-- Inserts for Fotos
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

-- Inserts for Telefones
INSERT INTO Telefones (numero, tipo) VALUES 
('(071) 3311 7385', 'Transportador'),
('+55 (061) 8454-7770', 'Transportador'),
('(011) 8836-0461', 'Transportador'),
('+55 (031) 1039-1256', 'Transportador'),
('(041) 4257 5766', 'Responsavel'),
('(021) 99876-5432', 'Transportador'),
('(019) 98765-4321', 'Transportador'),
('(031) 12345-6789', 'Transportador'),
('(041) 99888-7777', 'Responsavel'),
('(051) 99999-8888', 'Responsavel');

-- Inserts for Responsaveis
INSERT INTO Responsaveis (cpf, nome, dt_nascimento, email, senha, foto_id, endereco_id, telefone_id) VALUES 
('980.143.625-51', 'Kaique Vieira', '1956-09-13', 'lucasramos@bol.com.br', '(!Xm7L@m8O', 1, 1, 5),
('934.215.876-55', 'Luiz Gustavo Sales', '1976-05-28', 'thiagodas-neves@da.com', 'OY+30IiQv#', 2, 2, 10),
('734.069.512-52', 'Ana Luiza Nunes', '1949-03-03', 'caldeirapedro-miguel@hotmail.com', 'Hs1$HONx_M', 3, 3, 6),
('013.978.562-03', 'Murilo da Mota', '1963-06-01', 'da-pazolivia@bol.com.br', 'd^P39mUeEJ', 4, 4, 8),
('801.342.695-51', 'Sra. Emilly Porto', '2003-05-30', 'juliana64@yahoo.com.br', '+6FJqHA#CW', 5, 5, 9),
('123.456.789-00', 'João da Silva', '1980-01-01', 'joao.silva@exemplo.com', 'senha123', 6, 6, 7),
('987.654.321-00', 'Maria Oliveira', '1975-02-02', 'maria.oliveira@exemplo.com', 'senha456', 7, 7, 4),
('321.654.987-00', 'Carlos Almeida', '1985-03-03', 'carlos.almeida@exemplo.com', 'senha789', 8, 8, 3),
('654.123.987-00', 'Patrícia Lima', '1990-04-04', 'patricia.lima@exemplo.com', 'senha000', 9, 9, 2),
('987.321.654-00', 'Fernando Sousa', '1978-05-05', 'fernando.sousa@exemplo.com', 'senha111', 10, 10, 1);

-- Inserts for Transportadores
INSERT INTO Transportadores (cnh, cpf, nome, dt_nascimento, email, senha, foto_id, telefone_id) VALUES 
('826.054.793-74', '810.943.756-75', 'Davi Luiz Costela', '1969-05-29', 'joao-vitor65@ribeiro.br', '@v8(Pz%uQb', 1, 1),
('910.458.623-98', '795.102.843-60', 'Isadora Pinto', '1971-10-06', 'fariasana-clara@da.br', 'h)fyN8lkcY', 2, 2),
('507.839.241-60', '368.104.729-40', 'Stephany Silva', '1986-08-07', 'ribeiroana-luiza@lopes.com', ')9TV3pUsDU', 3, 3),
('386.704.521-62', '683.129.450-24', 'Vitor Gabriel Gomes', '1968-10-30', 'henriqueda-mata@ig.com.br', '#D92QO5mh8', 4, 4),
('438.721.960-22', '508.194.736-93', 'Sabrina da Mota', '1955-04-12', 'ana-sophia93@fogaca.com', 'GSCUoNjY!2', 5, 5),
('145.236.578-00', '369.874.159-62', 'Roberto Carlos', '1980-07-10', 'roberto.carlos@exemplo.com', 'rc@2023!', 6, 6),
('852.963.741-85', '254.789.123-45', 'Sofia Lima', '1972-02-20', 'sofia.lima@exemplo.com', 'sofia123', 7, 7),
('147.258.369-12', '951.753.468-58', 'Bruno Silva', '1988-11-15', 'bruno.silva@exemplo.com', 'bruno2023', 8, 8),
('456.789.123-45', '753.159.456-89', 'Camila Almeida', '1995-12-25', 'camila.almeida@exemplo.com', 'camila2023', 9, 9),
('963.852.741-58', '147.258.369-12', 'Lucas Ribeiro', '1983-03-13', 'lucas.ribeiro@exemplo.com', 'lucas2023', 10, 10);

-- Inserts for Vans
INSERT INTO Vans (placa, modelo, acessibilidade, mensalidade, capacidade, foto_id, transportador_cnh) VALUES 
('ABC1D23', 'Furgão Ford', true, 1500.00, 3, 1, '826.054.793-74'),
('BCD2E34', 'Van Mercedes', false, 2000.00, 7, 2, '910.458.623-98'),
('CDE3F45', 'Furgão Volkswagen', true, 1800.00, 5, 3, '507.839.241-60'),
('DEF4G56', 'Van Fiat', false, 2200.00, 10, 4, '386.704.521-62'),
('EFG5H67', 'Furgão Chevrolet', true, 1600.00, 4, 5, '438.721.960-22'),
('FGH6I78', 'Van Renault', false, 1700.00, 6, 6, '145.236.578-00'),
('GHI7J89', 'Furgão Iveco', true, 1900.00, 8, 7, '852.963.741-85'),
('HIJ8K90', 'Van Nissan', false, 2400.00, 12, 8, '147.258.369-12'),
('JKL9L01', 'Furgão Citroen', true, 2300.00, 9, 9, '456.789.123-45'),
('KLM0M12', 'Van Kia', false, 2500.00, 15, 10, '963.852.741-58');

-- Inserts for Escolas
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

-- Inserts for Alunos
INSERT INTO Alunos (cpf, nome, dt_nascimento, escola_id, pcd, id_foto, endereco_id, responsavel_cpf) VALUES 
('123.456.789-00', 'Lucas Almeida', '2010-01-01', 1, false, 1, 1, '980.143.625-51'),
('234.567.890-01', 'Mariana Costa', '2009-02-02', 2, false, 2, 2, '934.215.876-55'),
('345.678.901-02', 'Pedro Henrique', '2011-03-03', 3, true, 3, 3, '734.069.512-52'),
('456.789.012-03', 'Gabriel Oliveira', '2012-04-04', 4, false, 4, 4, '013.978.562-03'),
('567.890.123-04', 'Isabela Santos', '2013-05-05', 5, true, 5, 5, '801.342.695-51'),
('678.901.234-05', 'Rafael Lima', '2014-06-06', 6, false, 6, 6, '123.456.789-00'),
('789.012.345-06', 'Ana Clara', '2015-07-07', 7, false, 7, 7, '987.654.321-00'),
('890.123.456-07', 'Maria Eduarda', '2016-08-08', 8, true, 8, 8, '321.654.987-00'),
('901.234.567-08', 'Thiago Martins', '2017-09-09', 9, false, 9, 9, '654.123.987-00'),
('012.345.678-09', 'Bruna Pereira', '2018-10-10', 10, false, 10, 10, '987.321.654-00');

-- Tabelas de Logs
CREATE TABLE LogResponsaveis (
    id SERIAL PRIMARY KEY,
    cpf VARCHAR(11),
    alteracao VARCHAR(255),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE LogTransportadores (
    id SERIAL PRIMARY KEY,
    cnh VARCHAR(11),
    alteracao VARCHAR(255),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE LogAlunos (
    id SERIAL PRIMARY KEY,
    cpf VARCHAR(11),
    alteracao VARCHAR(255),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE LogVans (
    id SERIAL PRIMARY KEY,
    placa VARCHAR(7),
    alteracao VARCHAR(255),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Log Geral para registrar todas as operações de inserção e atualização
CREATE TABLE LogGeral (
    id SERIAL PRIMARY KEY,
    tabela VARCHAR(50),
    chave_primaria VARCHAR(50),
    operacao VARCHAR(10),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Procedures para Inserção e Atualização

-- Inserção para Alunos
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
    INSERT INTO Alunos (cpf, nome, dt_nascimento, escola_id, pcd, id_foto, endereco_id, responsavel_cpf, turno)
    VALUES (p_cpf, p_nome, p_dt_nascimento, p_escola_id, p_pcd, p_id_foto, p_endereco_id, p_responsavel_cpf, p_turno);
END;
$$;

-- Inserção para Transportadores
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
    INSERT INTO Transportadores (cnh, cpf, nome, dt_nascimento, email, senha, foto_id, telefone_id)
    VALUES (p_cnh, p_cpf, p_nome, p_dt_nascimento, p_email, p_senha, p_foto_id, p_telefone_id);
END;
$$;

-- Inserção para Responsáveis
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
    INSERT INTO Responsaveis (cpf, nome, dt_nascimento, email, senha, foto_id, endereco_id, telefone_id)
    VALUES (p_cpf, p_nome, p_dt_nascimento, p_email, p_senha, p_foto_id, p_endereco_id, p_telefone_id);
END;
$$;

-- Inserção para Vans
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
    INSERT INTO Vans (placa, modelo, acessibilidade, mensalidade, foto_id, transportador_cnh, capacidade)
    VALUES (p_placa, p_modelo, p_acessibilidade, p_mensalidade, p_foto_id, p_transportador_cnh, p_capacidade);
END;
$$;

-- Procedures de Atualização

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
    UPDATE Responsaveis
    SET nome = p_nome, dt_nascimento = p_dt_nascimento, email = p_email, senha = p_senha,
        foto_id = p_foto_id, endereco_id = p_endereco_id, telefone_id = p_telefone_id
    WHERE cpf = p_cpf;
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
    UPDATE Transportadores
    SET cpf = p_cpf, nome = p_nome, dt_nascimento = p_dt_nascimento, email = p_email,
        senha = p_senha, foto_id = p_foto_id, telefone_id = p_telefone_id
    WHERE cnh = p_cnh;
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
    UPDATE Alunos
    SET nome = p_nome, dt_nascimento = p_dt_nascimento, escola_id = p_escola_id,
        pcd = p_pcd, id_foto = p_id_foto, endereco_id = p_endereco_id,
        responsavel_cpf = p_responsavel_cpf, turno = p_turno
    WHERE cpf = p_cpf;
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
    UPDATE Vans
    SET modelo = p_modelo, acessibilidade = p_acessibilidade, mensalidade = p_mensalidade,
        foto_id = p_foto_id, transportador_cnh = p_transportador_cnh, capacidade = p_capacidade
    WHERE placa = p_placa;
END;
$$;


-- Função para log de inserção
CREATE OR REPLACE FUNCTION log_insercao()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogGeral (tabela, chave_primaria, operacao)
    VALUES (TG_TABLE_NAME, NEW.cpf, 'Insercao');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para log de atualização
CREATE OR REPLACE FUNCTION log_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogGeral (tabela, chave_primaria, operacao)
    VALUES (TG_TABLE_NAME, NEW.cpf, 'Atualizacao');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Triggers de inserção e atualização para a tabela Alunos
CREATE TRIGGER log_aluno_insercao
AFTER INSERT ON Alunos
FOR EACH ROW
EXECUTE FUNCTION log_insercao();

CREATE TRIGGER log_aluno_atualizacao
AFTER UPDATE ON Alunos
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();

-- Triggers de inserção e atualização para a tabela Professores
CREATE TRIGGER log_professor_insercao
AFTER INSERT ON Professores
FOR EACH ROW
EXECUTE FUNCTION log_insercao();

CREATE TRIGGER log_professor_atualizacao
AFTER UPDATE ON Professores
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();

-- Triggers de inserção e atualização para a tabela Escolas
CREATE TRIGGER log_escola_insercao
AFTER INSERT ON Escolas
FOR EACH ROW
EXECUTE FUNCTION log_insercao();

CREATE TRIGGER log_escola_atualizacao
AFTER UPDATE ON Escolas
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();

-- Triggers de inserção e atualização para a tabela Responsaveis
CREATE TRIGGER log_responsavel_insercao
AFTER INSERT ON Responsaveis
FOR EACH ROW
EXECUTE FUNCTION log_insercao();

CREATE TRIGGER log_responsavel_atualizacao
AFTER UPDATE ON Responsaveis
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();

-- Triggers de inserção e atualização para a tabela Enderecos
CREATE TRIGGER log_endereco_insercao
AFTER INSERT ON Enderecos
FOR EACH ROW
EXECUTE FUNCTION log_insercao();

CREATE TRIGGER log_endereco_atualizacao
AFTER UPDATE ON Enderecos
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();
-- teste
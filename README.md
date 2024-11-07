# Documentação Completa do Banco de Dados

## Índice

1. [Introdução](#introdução)
2. [Processo de Normalização](#processo-de-normalização)
3. [Diagrama ER (Modelo Conceitual)](#diagrama-er-modelo-conceitual)
4. [Descrição das Tabelas](#descrição-das-tabelas)
   - [Tabela **Endereços**](#tabela-endereços)
   - [Tabela **Fotos**](#tabela-fotos)
   - [Tabela **Telefones**](#tabela-telefones)
   - [Tabela **Responsáveis**](#tabela-responsáveis)
   - [Tabela **Transportadores**](#tabela-transportadores)
   - [Tabela **Vans**](#tabela-vans)
   - [Tabela **Escolas**](#tabela-escolas)
   - [Tabela **Alunos**](#tabela-alunos)
5. [Tabelas de Logs](#tabelas-de-logs)
6. [Funções e Triggers para Logs](#funções-e-triggers-para-logs)
7. [Procedures para Inserção, Atualização e Deleção](#procedures-para-inserção-atualização-e-deleção)
8. [Índices para Otimização](#índices-para-otimização)
9. [Considerações sobre Otimização](#considerações-sobre-otimização)
10. [Inserção de Dados](#inserção-de-dados)
11. [Conclusão](#conclusão)

---

## Introdução

Este documento descreve detalhadamente a estrutura de um banco de dados relacional projetado para gerenciar informações relacionadas a transportes escolares, incluindo entidades como **Endereços**, **Fotos**, **Telefones**, **Responsáveis**, **Transportadores**, **Vans**, **Escolas** e **Alunos**. Além das tabelas principais, o banco também implementa tabelas de **Logs** para auditoria, **Triggers** para registrar alterações, **Procedures** para operações CRUD e **Índices** para otimização de consultas.

---

## Processo de Normalização

Antes do processo de normalização, o banco de dados não possuía as tabelas **Escolas** e **Telefones**. As informações relacionadas à escola de um aluno e aos telefones de responsáveis e transportadores eram armazenadas diretamente nas tabelas principais, o que levava a redundância de dados e dificultava a manutenção.

**Benefícios da Normalização:**

- **Eliminação de Redundâncias:** Com a criação das tabelas **Escolas** e **Telefones**, evitamos a duplicação de informações. Por exemplo, vários alunos que estudam na mesma escola referenciam um único registro na tabela **Escolas**.
- **Melhoria na Integridade dos Dados:** Garantimos que atualizações em informações como nome da escola ou número de telefone sejam refletidas em todas as entidades relacionadas.
- **Facilidade de Manutenção:** A separação dos dados em tabelas específicas simplifica operações de inserção, atualização e deleção.

---

## Diagrama ER (Modelo Conceitual)

O diagrama Entidade-Relacionamento (ER) a seguir representa o modelo conceitual do banco de dados, destacando as entidades principais e seus relacionamentos.

![Diagrama ER](Diagrama-ER.drawio.svg)


### Entidades e Relacionamentos:

- **Endereços** (`id`, `cep`, `bairro`, `rua`, `numero`)
  - Relacionamentos:
    - **Responsáveis** possuem um **Endereço**.
    - **Alunos** possuem um **Endereço**.
    - **Escolas** possuem um **Endereço**.

- **Fotos** (`id`, `url`)
  - Relacionamentos:
    - **Responsáveis** possuem uma **Foto**.
    - **Transportadores** possuem uma **Foto**.
    - **Vans** possuem uma **Foto**.
    - **Alunos** possuem uma **Foto**.

- **Telefones** (`id`, `numero`, `tipo`)
  - Relacionamentos:
    - **Responsáveis** possuem um **Telefone**.
    - **Transportadores** possuem um **Telefone**.

- **Responsáveis** (`cpf`, `nome`, `dt_nascimento`, `email`, `senha`, `foto_id`, `endereco_id`, `telefone_id`)
  - Relacionamentos:
    - **Alunos** possuem um **Responsável**.

- **Transportadores** (`cnh`, `cpf`, `nome`, `dt_nascimento`, `email`, `senha`, `foto_id`, `telefone_id`)
  - Relacionamentos:
    - **Vans** são operadas por um **Transportador**.

- **Vans** (`placa`, `modelo`, `acessibilidade`, `mensalidade`, `capacidade`, `foto_id`, `transportador_cnh`)

- **Escolas** (`id`, `nome`, `endereco_id`)
  - Relacionamentos:
    - **Alunos** estudam em uma **Escola**.

- **Alunos** (`cpf`, `nome`, `dt_nascimento`, `escola_id`, `pcd`, `id_foto`, `endereco_id`, `responsavel_cpf`, `turno`)

### Descrição dos Relacionamentos:

- **Responsáveis** e **Endereços**: Relacionamento de muitos-para-um; cada responsável reside em um endereço.
- **Transportadores** e **Telefones**: Relacionamento de muitos-para-um; cada transportador possui um telefone.
- **Alunos** e **Responsáveis**: Relacionamento de muitos-para-um; cada aluno tem um responsável.
- **Alunos** e **Escolas**: Relacionamento de muitos-para-um; cada aluno estuda em uma escola.
- **Vans** e **Transportadores**: Relacionamento de muitos-para-um; cada van é operada por um transportador.
- **Escolas**, **Responsáveis**, **Alunos** e **Transportadores** compartilham relacionamentos com **Fotos** e **Endereços** para evitar redundância de dados.

---

## Descrição das Tabelas

### Tabela **Endereços**

**Descrição:** Armazena informações de endereços que podem ser associados a diversas entidades como Responsáveis, Alunos e Escolas.

**Estrutura:**

- `id SERIAL PRIMARY KEY`: Identificador único do endereço.
- `cep VARCHAR(9) NOT NULL`: Código Postal.
- `bairro VARCHAR(100) NOT NULL`: Nome do bairro.
- `rua VARCHAR(100) NOT NULL`: Nome da rua.
- `numero VARCHAR(10) NOT NULL`: Número do endereço.

**Comentários:**

- Utiliza um campo `id` auto-incremental para identificação única.
- O CEP é armazenado como `VARCHAR(9)` para acomodar possíveis formatos com hífen.

---

### Tabela **Fotos**

**Descrição:** Armazena URLs de fotos associadas a entidades como Responsáveis, Transportadores, Vans e Alunos.

**Estrutura:**

- `id SERIAL PRIMARY KEY`: Identificador único da foto.
- `url VARCHAR(255) NOT NULL`: URL da foto.

---

### Tabela **Telefones**

**Descrição:** Criada durante a normalização para armazenar números de telefone associados a Responsáveis e Transportadores, evitando redundâncias.

**Estrutura:**

- `id SERIAL PRIMARY KEY`: Identificador único do telefone.
- `numero VARCHAR(15) NOT NULL`: Número de telefone.
- `tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Responsavel', 'Transportador'))`: Tipo de telefone.

**Comentários:**

- A criação desta tabela permite que um mesmo número de telefone seja associado a múltiplos registros, melhorando a integridade dos dados.
- A restrição `CHECK` garante que apenas tipos predefinidos sejam inseridos.

---

### Tabela **Responsáveis**

**Descrição:** Armazena informações dos responsáveis pelos alunos.

**Estrutura:**

- `cpf VARCHAR(11) PRIMARY KEY`: CPF do responsável, identificador único.
- `nome VARCHAR(100) NOT NULL`: Nome completo.
- `dt_nascimento DATE NOT NULL`: Data de nascimento.
- `email VARCHAR(100) NOT NULL UNIQUE`: Email único.
- `senha VARCHAR(100) NOT NULL`: Senha de acesso.
- `foto_id INT REFERENCES Fotos(id)`: Referência à tabela Fotos.
- `endereco_id INT REFERENCES Enderecos(id)`: Referência à tabela Endereços.
- `telefone_id INT REFERENCES Telefones(id)`: Referência à tabela Telefones.

**Comentários:**

- A inclusão da referência à tabela **Telefones**, criada durante a normalização, evita duplicação de dados de contato.
- O CPF é usado como chave primária.
- Restrições de unicidade em `cpf` e `email` para evitar duplicidades.

---

### Tabela **Transportadores**

**Descrição:** Armazena informações dos transportadores que operam as vans.

**Estrutura:**

- `cnh VARCHAR(11) PRIMARY KEY`: CNH do transportador, identificador único.
- `cpf VARCHAR(11) NOT NULL UNIQUE`: CPF único.
- `nome VARCHAR(100) NOT NULL`: Nome completo.
- `dt_nascimento DATE NOT NULL`: Data de nascimento.
- `email VARCHAR(100) NOT NULL UNIQUE`: Email único.
- `senha VARCHAR(100) NOT NULL`: Senha de acesso.
- `foto_id INT REFERENCES Fotos(id)`: Referência à tabela Fotos.
- `telefone_id INT REFERENCES Telefones(id)`: Referência à tabela Telefones.

**Comentários:**

- A referência à tabela **Telefones** permite melhor gerenciamento dos dados de contato.
- A CNH é usada como chave primária.
- Restrições de unicidade em `cpf` e `email`.

---

### Tabela **Vans**

**Descrição:** Armazena informações das vans utilizadas para o transporte.

**Estrutura:**

- `placa VARCHAR(7) PRIMARY KEY`: Placa do veículo, identificador único.
- `modelo VARCHAR(50) NOT NULL`: Modelo da van.
- `acessibilidade BOOLEAN NOT NULL`: Indica se a van é acessível.
- `mensalidade DECIMAL(10, 2) NOT NULL`: Valor da mensalidade.
- `capacidade INT NOT NULL`: Capacidade de passageiros.
- `foto_id INT REFERENCES Fotos(id)`: Referência à tabela Fotos.
- `transportador_cnh VARCHAR(11) REFERENCES Transportadores(cnh)`: Referência ao transportador.

**Comentários:**

- A placa é usada como chave primária.
- Relacionamentos com Fotos e Transportadores.

---

### Tabela **Escolas**

**Descrição:** Criada durante a normalização para armazenar informações das escolas, evitando redundância nos dados dos alunos.

**Estrutura:**

- `id SERIAL PRIMARY KEY`: Identificador único da escola.
- `nome VARCHAR(100) NOT NULL`: Nome da escola.
- `endereco_id INT REFERENCES Enderecos(id)`: Referência ao endereço da escola.

**Comentários:**

- Permite que vários alunos referenciem a mesma escola, facilitando atualizações e consultas.
- Relacionamento com a tabela **Endereços** para armazenar o local da escola.

---

### Tabela **Alunos**

**Descrição:** Armazena informações dos alunos que utilizam o serviço de transporte.

**Estrutura:**

- `cpf VARCHAR(11) PRIMARY KEY`: CPF do aluno, identificador único.
- `nome VARCHAR(100) NOT NULL`: Nome completo.
- `dt_nascimento DATE NOT NULL`: Data de nascimento.
- `escola_id INT REFERENCES Escolas(id)`: Referência à escola do aluno.
- `pcd BOOLEAN NOT NULL`: Indica se o aluno é PCD (Pessoa com Deficiência).
- `id_foto INT REFERENCES Fotos(id)`: Referência à foto do aluno.
- `endereco_id INT REFERENCES Enderecos(id)`: Referência ao endereço do aluno.
- `responsavel_cpf VARCHAR(11) REFERENCES Responsaveis(cpf)`: Referência ao responsável.
- `turno VARCHAR(10) NOT NULL CHECK (turno IN ('Manha', 'Tarde', 'Noite'))`: Turno escolar.

**Comentários:**

- A inclusão da referência à tabela **Escolas** evita redundância de informações sobre a instituição de ensino.
- A restrição `CHECK` no campo `turno` garante a consistência dos dados inseridos.

---

## Tabelas de Logs

**Descrição:** Cada tabela principal possui uma tabela de log associada para registrar operações de inserção, atualização e deleção, auxiliando na auditoria e rastreabilidade das ações no banco de dados.

**Estrutura Geral das Tabelas de Log:**

- `id SERIAL PRIMARY KEY`: Identificador único do log.
- `<entidade>_id`: Campo que referencia o identificador da entidade original.
- `operacao VARCHAR(10)`: Tipo de operação realizada ('INSERT', 'UPDATE', 'DELETE').
- `alteracao TEXT`: Descrição detalhada da alteração.
- `data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP`: Momento em que a operação foi registrada.

**Comentários:**

- Permitem rastrear mudanças e manter um histórico das operações realizadas.
- Importantes para auditoria e conformidade com políticas de segurança.

---

## Funções e Triggers para Logs

### Função **log_detalhado**

**Descrição:** Função genérica em PL/pgSQL que registra detalhes das operações de INSERT, UPDATE e DELETE nas tabelas de log correspondentes.

**Parâmetros:**

- `TG_ARGV[0]`: Nome do campo identificador na tabela principal (e.g., 'id', 'cpf').
- `TG_ARGV[1]`: Nome da tabela de log correspondente.

**Lógica da Função:**

- Verifica o tipo de operação (TG_OP).
  - **INSERT**: Registra o novo registro inserido.
  - **UPDATE**: Registra a alteração do estado antigo para o novo.
  - **DELETE**: Registra o registro excluído.
- Utiliza `row_to_json` para converter as tuplas OLD e NEW em formato JSON para melhor legibilidade.
- Insere um novo registro na tabela de log com as informações coletadas.

### Triggers Associados

**Descrição:** Para cada tabela principal, há um trigger que invoca a função `log_detalhado` após operações de INSERT, UPDATE ou DELETE.

**Exemplo de Trigger:**

```sql
CREATE TRIGGER trg_log_enderecos
AFTER INSERT OR UPDATE OR DELETE ON Enderecos
FOR EACH ROW EXECUTE PROCEDURE log_detalhado('id', 'LogEnderecos');
```

**Comentários:**

- Garantem que qualquer alteração nas tabelas principais seja automaticamente registrada nos logs.
- Simplificam a manutenção e evitam duplicação de código.

---

## Procedures para Inserção, Atualização e Deleção

**Descrição:** Procedures (procedimentos armazenados) foram criadas para encapsular as operações de inserção, atualização e deleção nas tabelas principais, incluindo validações e tratamento de erros.

### Estrutura Geral das Procedures:

- **Validações Prévias:** Antes de executar a operação, as procedures verificam:
  - Existência ou não existência de registros (para evitar duplicidades ou garantir que o registro exista).
  - Integridade referencial (verificando se chaves estrangeiras apontam para registros válidos).
- **Operação Principal:** Execução do comando INSERT, UPDATE ou DELETE conforme o caso.
- **Tratamento de Erros:** Uso de `RAISE EXCEPTION` para informar problemas encontrados durante as validações.

### Exemplos de Procedures:

#### Inserir Responsável

```sql
CREATE OR REPLACE PROCEDURE inserir_responsavel(
    p_cpf VARCHAR(11),
    p_nome VARCHAR(100),
    ...
)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Responsaveis WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'CPF já cadastrado.';
    END IF;
    ...
    INSERT INTO Responsaveis (cpf, nome, ...)
    VALUES (p_cpf, p_nome, ...);
END;
$$;
```

#### Atualizar Van

```sql
CREATE OR REPLACE PROCEDURE atualizar_van(
    p_placa VARCHAR(7),
    p_modelo VARCHAR(50),
    ...
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Vans WHERE placa = p_placa) THEN
        RAISE EXCEPTION 'Van não encontrada.';
    END IF;
    ...
    UPDATE Vans
    SET modelo = p_modelo, ...
    WHERE placa = p_placa;
END;
$$;
```

**Comentários:**

- Centralizam a lógica de negócios e as regras de validação.
- Facilitam a manutenção e promovem a integridade dos dados.

---

## Índices para Otimização

**Descrição:** Índices foram criados nas tabelas principais para melhorar o desempenho das consultas, especialmente aquelas que filtram ou ordenam dados com base em campos específicos.

### Índices Criados:

- **Tabela Responsaveis:**
  - `idx_responsaveis_email` (UNIQUE): Otimiza buscas por email.
  - `idx_responsaveis_endereco_id`: Otimiza joins ou buscas por endereço.
  - `idx_responsaveis_telefone_id`: Otimiza joins ou buscas por telefone.

- **Tabela Transportadores:**
  - `idx_transportadores_email` (UNIQUE): Otimiza buscas por email.
  - `idx_transportadores_cpf` (UNIQUE): Otimiza buscas por CPF.
  - `idx_transportadores_telefone_id`: Otimiza joins ou buscas por telefone.

- **Tabela Alunos:**
  - `idx_alunos_escola_id`: Otimiza buscas por escola.
  - `idx_alunos_responsavel_cpf`: Otimiza buscas por responsável.
  - `idx_alunos_turno`: Otimiza buscas por turno.

- **Tabela Vans:**
  - `idx_vans_transportador_cnh`: Otimiza buscas por transportador.

- **Outros Índices:**
  - `idx_enderecos_cep`: Otimiza buscas por CEP na tabela Endereços.
  - `idx_telefones_numero`: Otimiza buscas por número na tabela Telefones.
  - `idx_escolas_nome`: Otimiza buscas por nome na tabela Escolas.
  - `idx_fotos_id`: Otimiza joins envolvendo a tabela Fotos.

**Comentários:**

- Índices UNIQUE garantem unicidade e melhoram o desempenho em buscas e validações.
- Índices em chaves estrangeiras melhoram o desempenho de joins entre tabelas relacionadas.
- A escolha dos campos para indexação foi baseada na frequência esperada de consultas e operações de filtragem.

---

## Considerações sobre Otimização

- **Normalização dos Dados:** O banco foi normalizado até a terceira forma normal, eliminando redundâncias e garantindo integridade referencial. A criação das tabelas **Escolas** e **Telefones** foi essencial nesse processo.
- **Índices:** A criação estratégica de índices melhora significativamente o desempenho em operações de leitura, especialmente em tabelas com grande volume de dados.
- **Procedures e Triggers:** Ao encapsular lógica de negócios em procedures e utilizar triggers para logs, o banco garante integridade e facilita auditorias sem sacrificar desempenho.
- **Validações:** As procedures implementam validações robustas que evitam inconsistências e erros comuns.
- **Uso de CHECK Constraints:** As restrições CHECK nos campos `tipo` (Tabela Telefones) e `turno` (Tabela Alunos) garantem que apenas valores permitidos sejam inseridos.

---

## Inserção de Dados

**Descrição:** Foram inseridos dados de exemplo em todas as tabelas principais para ilustrar o funcionamento do banco e permitir testes iniciais.

### Exemplos de Dados Inseridos:

- **Endereços:** 10 registros com CEPs, bairros, ruas e números variados.
- **Fotos:** 10 registros com URLs de imagens simuladas.
- **Telefones:** 10 registros com números e tipos (Transportador ou Responsavel).
- **Responsáveis:** 10 registros com CPFs, nomes, emails, etc., associados a endereços, fotos e telefones.
- **Transportadores:** 10 registros com CNHs, CPFs, nomes, emails, etc.
- **Vans:** 10 registros com placas, modelos, acessibilidade, mensalidade, capacidade, associadas a transportadores.
- **Escolas:** 10 registros com nomes e endereços.
- **Alunos:** 10 registros com CPFs, nomes, datas de nascimento, escolas, se são PCD, fotos, endereços, responsáveis e turnos.

**Comentários:**

- Os dados inseridos permitem testar as relações entre as tabelas e verificar a funcionalidade das procedures e triggers.
- Os exemplos incluem casos com PCDs, diferentes turnos e associações variadas.

---

## Conclusão

Este documento apresentou uma descrição detalhada do banco de dados projetado para gerenciar informações relacionadas a transportes escolares. Foi destacado que, antes da normalização, o banco não possuía as tabelas **Escolas** e **Telefones**, o que causava redundância de dados e dificultava a manutenção.

A inclusão do Diagrama ER (Modelo Conceitual) proporciona uma visão clara das entidades e relacionamentos, facilitando o entendimento da estrutura e do fluxo de dados no sistema.

A normalização permitiu melhorar a estrutura do banco, eliminando redundâncias e promovendo a integridade dos dados. A criação das tabelas **Escolas** e **Telefones** foi fundamental nesse processo, permitindo uma melhor organização e facilitando a manutenção futura.

A implementação considera boas práticas de modelagem de dados, garantindo integridade referencial, consistência e desempenho adequado. As validações incorporadas nas procedures e as restrições definidas nas tabelas asseguram que os dados mantidos no banco estejam sempre em um estado válido e coerente.

Este banco de dados serve como uma base sólida para aplicações que necessitam gerenciar informações complexas relacionadas a transportes escolares, podendo ser expandido ou adaptado conforme as necessidades específicas do negócio.

---

-- ==========================
-- BANCO DE DADOS CYBERBEEF -
-- ==========================

CREATE DATABASE cyberbeef;
USE cyberbeef;


CREATE TABLE contato (
    idContato INT PRIMARY KEY AUTO_INCREMENT,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(255) NOT NULL,
    assunto VARCHAR(45) NOT NULL,
    descricao VARCHAR(255)
);


CREATE TABLE empresa (
    tokenEmpresa INT PRIMARY KEY,
    razaoSocial VARCHAR(255) NOT NULL,
    nomeFantasia VARCHAR(255) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    cep CHAR(8) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    contato INT NOT NULL,
    CONSTRAINT fkContatoEmpresa FOREIGN KEY (contato) REFERENCES contato(idContato)
);


CREATE TABLE permissaoUsuario (
    idPermissaoUsuario INT PRIMARY KEY AUTO_INCREMENT,
    cargo VARCHAR(45) NOT NULL,
    nivelPermissao INT NOT NULL
);


CREATE TABLE usuario (
    idUsuario INT PRIMARY KEY AUTO_INCREMENT,
    tokenEmpresa INT NOT NULL,
    permissaoUsuario INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    CONSTRAINT fkEmpresaUsuario FOREIGN KEY (tokenEmpresa) REFERENCES empresa(tokenEmpresa),
    CONSTRAINT fkPermissaoUsuario FOREIGN KEY (permissaoUsuario) REFERENCES permissaoUsuario(idPermissaoUsuario)
);


CREATE TABLE setor (
    idSetor INT PRIMARY KEY AUTO_INCREMENT,
    tokenEmpresa INT NOT NULL,
    nomeSetor VARCHAR(45) NOT NULL,
    descricao VARCHAR(255),
    CONSTRAINT fkSetorEmpresa FOREIGN KEY (tokenEmpresa) REFERENCES empresa(tokenEmpresa)
);


CREATE TABLE maquina (
    idMaquina INT PRIMARY KEY AUTO_INCREMENT,
    macAddress VARCHAR(45) NOT NULL,
    ip VARCHAR(45) NOT NULL,
    hostname VARCHAR(255) NOT NULL,
    sistemaOperacional VARCHAR(45) NOT NULL,
    dthRegistro DATETIME NOT NULL
);


CREATE TABLE setorMaquina (
    idSetor INT NOT NULL,
    tokenEmpresa INT NOT NULL,
    idMaquina INT NOT NULL,
    status VARCHAR(10) NOT NULL,
    responsavel VARCHAR(45),
    dthVinculacao DATETIME NOT NULL,
    CONSTRAINT fkSetorMaquina FOREIGN KEY (idSetor) REFERENCES setor(idSetor),
    FOREIGN KEY (tokenEmpresa) REFERENCES empresa(tokenEmpresa),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina),
    PRIMARY KEY (idSetor, tokenEmpresa, idMaquina)
);


CREATE TABLE componente (
    idComponente INT PRIMARY KEY AUTO_INCREMENT,
    idMaquina INT NOT NULL,
    tipoComponente ENUM('CPU','MEMORIA','DISCO','REDE') NOT NULL,
    unidadeMedida VARCHAR(45) NOT NULL,
    CONSTRAINT fkComponenteMaquina FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina),
    UNIQUE (idMaquina, tipoComponente)
);


CREATE TABLE nucleoCpu (
    idNucleo INT PRIMARY KEY AUTO_INCREMENT,
    idComponente INT NOT NULL,
    idMaquina INT NOT NULL,
    CONSTRAINT fkNucleoComponente FOREIGN KEY (idComponente) REFERENCES componente(idComponente),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina)
);


CREATE TABLE leitura (
    idLeitura INT PRIMARY KEY AUTO_INCREMENT,
    idComponente INT NOT NULL,
    idMaquina INT NOT NULL,
    dado FLOAT NOT NULL,
    dthCaptura DATETIME NOT NULL,
    idNucleo INT,
    CONSTRAINT fkLeituraComponente FOREIGN KEY (idComponente) REFERENCES componente(idComponente),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina),
    FOREIGN KEY (idNucleo) REFERENCES nucleoCpu(idNucleo)
);


CREATE TABLE rede (
    idRede INT PRIMARY KEY AUTO_INCREMENT,
    idMaquina INT NOT NULL,
    idComponente INT NOT NULL,
    download FLOAT NOT NULL,
    upload FLOAT NOT NULL,
    packetLoss FLOAT NOT NULL,
    dthCaptura DATETIME NOT NULL,
    CONSTRAINT fkRedeMaquina FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina),
    CONSTRAINT fkRedeComponente FOREIGN KEY (idComponente) REFERENCES componente(idComponente)
);


CREATE TABLE parametro (
    idParametro INT PRIMARY KEY AUTO_INCREMENT,
    idComponente INT NOT NULL,
    idMaquina INT NOT NULL,
    nivel VARCHAR(45) NOT NULL,
    min FLOAT NOT NULL,
    max FLOAT NOT NULL,
    CONSTRAINT fkParametroComponente FOREIGN KEY (idComponente) REFERENCES componente(idComponente),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina)
);


CREATE TABLE alerta (
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    idLeitura INT NOT NULL,
    idComponente INT NOT NULL,
    idMaquina INT NOT NULL,
    idParametro INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    CONSTRAINT fkAlertaLeitura FOREIGN KEY (idLeitura) REFERENCES leitura(idLeitura),
    FOREIGN KEY (idComponente) REFERENCES componente(idComponente),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina),
    FOREIGN KEY (idParametro) REFERENCES parametro(idParametro)
);


INSERT INTO contato (telefone, email, assunto, descricao) VALUES 
('11999999999', 'contato@cyberbeef.com', 'Suporte', 'Contato principal da empresa');

INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, cep, numero, contato) VALUES
(1001, 'CyberBeef Ltda', 'CyberBeef', '12345678000199', '04567000', '123', 1);

INSERT INTO permissaoUsuario (cargo, nivelPermissao) VALUES 
('Administrador', 2),
('Analista', 1);

INSERT INTO usuario (tokenEmpresa, permissaoUsuario, email, senha, nome) VALUES 
(1001, 1, 'admin@cyberbeef.com', 'admin123', 'Admin Rafael'),
(1001, 2, 'analista@cyberbeef.com', 'tech123', 'Analista Pedro');

INSERT INTO setor (tokenEmpresa, nomeSetor, descricao) VALUES 
(1001, 'Produção de Alimentos', 'Esteira de produção alimentício');

INSERT INTO maquina (macAddress, ip, hostname, sistemaOperacional, dthRegistro) VALUES 
('00:11:22:33:44:55', '192.168.0.10', 'Servidor SCADA', 'Ubuntu', NOW());

INSERT INTO setorMaquina (idSetor, tokenEmpresa, idMaquina, status, responsavel, dthVinculacao) VALUES 
(1, 1001, 1, 'Ativa', 'Rafael', NOW());

INSERT INTO componente (idMaquina, tipoComponente, unidadeMedida) VALUES 
(1, 'REDE', 'Mbps'),
(1, 'MEMORIA', 'GB'),
(1, 'DISCO', 'GB'),
(1, 'CPU', '%');


-- Dados de Rede
SELECT r.idRede, m.idMaquina, c.tipoComponente,
 r.download, r.upload, r.packetLoss, 
 r.dthCaptura
FROM rede r 
JOIN maquina m ON m.idMaquina = r.idMaquina 
JOIN componente c ON c.idComponente = r.idComponente 
ORDER BY r.dthCaptura DESC;

-- Usuários e permissões
SELECT 
    u.idUsuario,
    u.nome AS nomeUsuario,
    u.email AS emailUsuario,
    p.cargo AS cargoUsuario,
    p.nivelPermissao,
    e.nomeFantasia AS empresa
FROM usuario u
JOIN permissaoUsuario p ON u.permissaoUsuario = p.idPermissaoUsuario
JOIN empresa e ON u.tokenEmpresa = e.tokenEmpresa;

-- Setores e máquinas
SELECT 
    s.idSetor,
    s.nomeSetor,
    s.descricao AS descricaoSetor,
    m.idMaquina,
    m.hostname,
    sm.status,
    sm.responsavel,
    sm.dataVinculacao
FROM setor s
JOIN setorMaquina sm ON s.idSetor = sm.idSetor
JOIN maquina m ON sm.idMaquina = m.idMaquina
WHERE sm.tokenEmpresa = s.tokenEmpresa;

-- Componentes
SELECT 
    c.idComponente,
    m.idMaquina,
    m.hostname,
    c.tipoComponente,
    c.unidadeMedida
FROM componente c
JOIN maquina m ON c.idMaquina = m.idMaquina;

-- Leituras gerais
SELECT 
    l.idLeitura,
    m.hostname,
    c.tipoComponente as "Componente",
    l.dado as "Dados",
    l.dthCaptura
FROM leitura l
JOIN componente c ON l.idComponente = c.idComponente
JOIN maquina m ON l.idMaquina = m.idMaquina
ORDER BY l.dthCaptura DESC;

-- Leituras específicas de rede
SELECT 
    r.idRede,
    m.hostname,
    c.tipoComponente as "Componente",
    r.download as "Download (Mbps)",
    r.upload as "Upload (Mbps)",
    r.packetLoss as "Packet Loss (%)",
    r.dthCaptura
FROM rede r
JOIN maquina m ON r.idMaquina = m.idMaquina
JOIN componente c ON c.idComponente = r.idComponente
ORDER BY r.dthCaptura DESC;

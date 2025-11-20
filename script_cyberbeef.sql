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
    numero VARCHAR(10) NOT NULL
);

ALTER TABLE empresa
DROP COLUMN cep,
DROP COLUMN numero;

ALTER TABLE empresa
ADD COLUMN dataCadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM empresa;

CREATE TABLE endereco (
    idEndereco INT PRIMARY KEY AUTO_INCREMENT,
    tokenEmpresa INT NOT NULL UNIQUE,  -- relação 1:1 com empresa
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep CHAR(8),
    CONSTRAINT fk_endereco_empresa FOREIGN KEY (tokenEmpresa) REFERENCES empresa(tokenEmpresa)
);


SELECT * FROM endereco;



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

CREATE TABLE loginHistorico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fkUsuario INT NULL,
    email VARCHAR(255),
    dataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    sucesso BOOLEAN,
    FOREIGN KEY (fkUsuario) REFERENCES usuario(idUsuario)
);

select * from loginHistorico;
SELECT idUsuario, email, senha, tokenEmpresa, permissaoUsuario
FROM usuario;

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


CREATE TABLE leitura (
    idLeitura INT PRIMARY KEY AUTO_INCREMENT,
    idComponente INT NOT NULL,
    idMaquina INT NOT NULL,
    dado FLOAT NOT NULL,
    dthCaptura DATETIME NOT NULL,
    CONSTRAINT fkLeituraComponente FOREIGN KEY (idComponente) REFERENCES componente(idComponente),
    FOREIGN KEY (idMaquina) REFERENCES maquina(idMaquina)
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

CREATE TABLE IF NOT EXISTS log (
    idLog INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    tipo ENUM("WARNING", "ERROR", "INFO") NOT NULL,              -- WARNING, ERROR, INFO
    mensagem TEXT NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_maquina) REFERENCES maquina(idMaquina)
);

INSERT INTO contato (telefone, email, assunto, descricao) VALUES 
('11999999999', 'contato@cyberbeef.com', 'Suporte', 'Contato principal da empresa');

INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj) VALUES
(1001, 'CyberBeef Ltda', 'CyberBeef', '12345678000199');

INSERT INTO permissaoUsuario (cargo, nivelPermissao) VALUES 
('Administrador', 2),
('Analista', 1);

INSERT INTO usuario (tokenEmpresa, permissaoUsuario, email, senha, nome) VALUES 
(1001, 1, 'admin@cyberbeef.com', 'admin123', 'Admin Rafael'),
(1001, 2, 'cyber@cyber.com', '1212', 'Cyberbeef'),
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
SELECT 
    r.idRede, 
    m.idMaquina, 
    c.tipoComponente,
    r.download, 
    r.upload, 
    r.packetLoss, 
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
    sm.dthVinculacao
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
    c.tipoComponente AS "Componente",
    l.dado AS "Dados",
    l.dthCaptura
FROM leitura l
JOIN componente c ON l.idComponente = c.idComponente
JOIN maquina m ON l.idMaquina = m.idMaquina
ORDER BY l.dthCaptura DESC;

-- Leituras específicas de rede
SELECT 
    r.idRede,
    m.hostname,
    c.tipoComponente AS "Componente",
    r.download AS "Download (Mbps)",
    r.upload AS "Upload (Mbps)",
    r.packetLoss AS "Packet Loss (%)",
    r.dthCaptura
FROM rede r
JOIN maquina m ON r.idMaquina = m.idMaquina
JOIN componente c ON c.idComponente = r.idComponente
ORDER BY r.dthCaptura DESC;

DELIMITER $$
CREATE PROCEDURE descKpiTodas(IN token INT)
BEGIN
	SELECT m.hostname as Máquina
		FROM setor s
		JOIN setorMaquina sm ON s.idSetor = sm.idSetor
		JOIN maquina m ON sm.idMaquina = m.idMaquina
		WHERE sm.tokenEmpresa = s.tokenEmpresa AND sm.tokenEmpresa = token;

	SELECT m.hostname as Máquina, c.tipoComponente as Componete, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token
		ORDER BY l.dthCaptura DESC;
        
    SELECT m.hostname as Máquina, c.tipoComponente as Componete, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		AND sm.tokenEmpresa = token
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
        
	SELECT m.hostname as Máquina, c.tipoComponente as Componete, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = (
		SELECT m.hostname
			FROM alerta a 
			JOIN maquina m ON m.idmaquina = a.idmaquina
			JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
			WHERE sm.tokenEmpresa = token
			GROUP BY m.hostname
			ORDER BY COUNT(*) DESC
			LIMIT 1)
		ORDER BY l.dthCaptura DESC;
    
END $$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE descKpiGeral(IN token INT, IN maquina VARCHAR(100))
BEGIN
	SELECT DISTINCT s.nomeSetor as Setor
		FROM setor s
		JOIN setorMaquina sm ON s.idSetor = sm.idSetor
		JOIN maquina m ON sm.idMaquina = m.idMaquina
		WHERE sm.tokenEmpresa = token AND m.hostname = maquina;

	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina
		ORDER BY l.dthCaptura DESC;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		AND sm.tokenEmpresa = token AND m.hostname = maquina
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = 
		(SELECT c.tipoComponente
			FROM alerta a 
			JOIN maquina m ON m.idmaquina = a.idmaquina
			JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
			JOIN componente c ON c.idComponente = a.idComponente
			WHERE sm.tokenEmpresa = token AND m.hostname = maquina
			GROUP BY c.tipoComponente
			ORDER BY COUNT(*) DESC
			LIMIT 1)    
		ORDER BY l.dthCaptura DESC;

END $$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE descKpiCRD(IN token INT, IN maquina VARCHAR(100), IN componente VARCHAR(100))
BEGIN
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM leitura l 
		JOIN maquina m ON l.idMaquina = m.idMaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		JOIN componente c ON l.idComponente = c.idComponente
		WHERE sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, ROUND(STDDEV_SAMP(l.dado),0) as DesvioPadrão, ROUND(AVG(l.dado),0) as Média
		FROM leitura l 
		JOIN maquina m ON l.idMaquina = m.idMaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		JOIN componente c ON l.idComponente = c.idComponente
		WHERE sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		GROUP BY m.hostname, c.tipoComponente
		LIMIT 1;
END $$

DELIMITER ;



DELIMITER $$
CREATE PROCEDURE descKpiRede(IN token INT, IN maquina VARCHAR(100), IN componente VARCHAR(100))
BEGIN
	SELECT m.hostname as Máquina, "REDE" as Componente, r.upload as Upload, DATE_FORMAT(r.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM rede r
		JOIN maquina m ON r.idMaquina = m.idMaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		AND sm.tokenEmpresa  = token AND m.hostname = maquina
		ORDER BY r.dthCaptura DESC
		LIMIT 1;

	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC;
		
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
		
	SELECT "REDE" as Componente, r.upload as Upload, r.download as Download, DATE_FORMAT(r.dthCaptura, '%d/%m/%y %H:%i') as DataHora
		FROM rede r
		JOIN maquina m ON r.idMaquina = m.idMaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE r.dthCaptura >= NOW() - INTERVAL 7 DAY 
        AND sm.tokenEmpresa = token AND m.hostname = maquina
		ORDER BY r.dthCaptura DESC
		LIMIT 1;
	END $$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE graficosTodas(IN token INT)
BEGIN
	SELECT COUNT(*) as numAlertas, DATE_FORMAT(l.dthCaptura, '%d/%m') as Dia 
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token 
		GROUP BY Dia
		ORDER BY Dia ASC;
		
	SELECT COUNT(*) as numAlertas, m.hostname as Maquina
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token
		GROUP BY Maquina
        ORDER BY numAlertas DESC
        LIMIT 3;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE graficosGeral(IN token INT, IN maquina VARCHAR(100))
BEGIN
	SELECT COUNT(*) as numAlertas, DATE_FORMAT(l.dthCaptura, '%d/%m') as Dia 
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina
		GROUP BY Dia
		ORDER BY Dia ASC;
		
	SELECT COUNT(*) as numAlertas, c.tipoComponente as Componente
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
        JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina
		GROUP BY Componente
		ORDER BY numAlertas DESC
        LIMIT 3;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE graficosCRD(IN token INT, IN maquina VARCHAR(100), IN componente VARCHAR(100))
BEGIN
	SELECT COUNT(*) as numAlertas, DATE_FORMAT(l.dthCaptura, '%d/%m') as Dia 
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
        JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		GROUP BY Dia
		ORDER BY Dia ASC;
		
	SELECT l.dado as dado
		FROM leitura l 
		JOIN maquina m ON m.idmaquina = l.idmaquina
        JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		ORDER BY l.dthCaptura DESC;
END $$
DELIMITER;

DELIMITER $$
CREATE PROCEDURE graficosRede(IN token INT, IN maquina VARCHAR(100), IN componente VARCHAR(100))
BEGIN
	SELECT COUNT(*) as numAlertas, DATE_FORMAT(l.dthCaptura, '%d/%m') as Dia 
		FROM alerta a
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN maquina m ON m.idmaquina = a.idmaquina
        JOIN componente c ON l.idComponente = c.idComponente
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token AND m.hostname = maquina AND c.tipoComponente = componente
		GROUP BY Dia
		ORDER BY Dia ASC;
		
	SELECT r.packetLoss as dado
		FROM rede r
		JOIN maquina m ON r.idMaquina = m.idMaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		AND sm.tokenEmpresa = token AND m.hostname = maquina
		WHERE r.dthCaptura >= NOW() - INTERVAL 7 DAY 
        AND sm.tokenEmpresa = token AND m.hostname = maquina 
		ORDER BY r.dthCaptura DESC;
END $$
DELIMITER ;

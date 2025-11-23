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
ADD COLUMN statusEmpresa BOOLEAN DEFAULT 1;


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
    tipoComponente ENUM('CPU','RAM','DISCO','REDE') NOT NULL,
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

INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa) VALUES
(1001, 'CyberBeef Ltda', 'CyberBeef', '12345678000199', 1);



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
(1, 'REDE', '%'),
(1, 'RAM', '%'),
(1, 'DISCO', '%'),
(1, 'CPU', '%');

INSERT INTO parametro (idComponente, idMaquina, nivel, min, max) VALUES
(4, 1, 'CPU', 0, 85),          
(2, 1, 'RAM', 0, 85),       
(3, 1, 'DISCO', 0, 85),       
(1, 1, 'REDE', 0, 2.5);

INSERT INTO leitura (idComponente, idMaquina, dado, dthCaptura) VALUES
(4,1,72,'2025-11-18 10:00:00'),
(4,1,65,'2025-11-18 14:00:00'),
(4,1,90,'2025-11-18 18:00:00'),  -- ALERTA

(4,1,55,'2025-11-19 10:00:00'),
(4,1,68,'2025-11-19 14:00:00'),
(4,1,88,'2025-11-19 18:00:00'),  -- ALERTA

(4,1,60,'2025-11-20 10:00:00'),
(4,1,82,'2025-11-20 14:00:00'),
(4,1,92,'2025-11-20 18:00:00'),  -- ALERTA

(4,1,70,'2025-11-21 10:00:00'),
(4,1,84,'2025-11-21 14:00:00'),
(4,1,93,'2025-11-21 18:00:00'); -- ALERTA



INSERT INTO leitura (idComponente, idMaquina, dado, dthCaptura) VALUES
(2,1,80,'2025-11-18 10:10:00'),
(2,1,82,'2025-11-18 14:10:00'),
(2,1,88,'2025-11-18 18:10:00'), -- ALERTA

(2,1,80,'2025-11-19 10:10:00'),
(2,1,83,'2025-11-19 14:10:00'),
(2,1,91,'2025-11-19 18:10:00'), -- ALERTA

(2,1,84,'2025-11-20 10:10:00'),
(2,1,81,'2025-11-20 14:10:00'),
(2,1,90,'2025-11-20 18:10:00'), -- ALERTA

(2,1,80,'2025-11-21 10:10:00'),
(2,1,80,'2025-11-21 14:10:00'),
(2,1,90,'2025-11-21 18:10:00'); -- ALERTA


INSERT INTO leitura (idComponente, idMaquina, dado, dthCaptura) VALUES
(3,1,70,'2025-11-18 11:00:00'),
(3,1,80,'2025-11-18 15:00:00'),
(3,1,94,'2025-11-18 19:00:00'), -- ALERTA

(3,1,71,'2025-11-19 11:00:00'),
(3,1,79,'2025-11-19 15:00:00'),
(3,1,93,'2025-11-19 19:00:00'), -- ALERTA

(3,1,81,'2025-11-20 11:00:00'),
(3,1,82,'2025-11-20 15:00:00'),
(3,1,99,'2025-11-20 19:00:00'), -- ALERTA

(3,1,82,'2025-11-21 11:00:00'),
(3,1,80,'2025-11-21 15:00:00'),
(3,1,91,'2025-11-21 19:00:00'); -- ALERTA


INSERT INTO rede (idMaquina, idComponente, download, upload, packetLoss, dthCaptura) VALUES
(1,1,120,18,0.5,'2025-11-18 12:00:00'),
(1,1,115,17,1.0,'2025-11-18 16:00:00'),
(1,1,110,15,3.5,'2025-11-18 20:00:00'), -- ALERTA

(1,1,130,20,0.8,'2025-11-19 12:00:00'),
(1,1,125,18,1.5,'2025-11-19 16:00:00'),
(1,1,118,17,4.1,'2025-11-19 20:00:00'), -- ALERTA

(1,1,128,19,1.2,'2025-11-20 12:00:00'),
(1,1,123,18,1.8,'2025-11-20 16:00:00'),
(1,1,119,16,3.7,'2025-11-20 20:00:00'), -- ALERTA

(1,1,135,20,1.0,'2025-11-21 12:00:00'),
(1,1,129,19,1.7,'2025-11-21 16:00:00'),
(1,1,121,17,4.3,'2025-11-21 20:00:00'); -- ALERTA


INSERT INTO alerta (idLeitura, idComponente, idMaquina, idParametro, descricao) VALUES
-- CPU
(3,4,1,1,'Crítico'),
(6,4,1,1,'Crítico'),
(9,4,1,1,'Crítico'),
(12,4,1,1,'Crítico'),

-- MEMÓRIA
(15,2,1,2,'Crítico'),
(18,2,1,2,'Crítico'),
(21,2,1,2,'Crítico'),
(24,2,1,2,'Crítico'),

-- DISCO
(27,3,1,3,'Crítico'),
(30,3,1,3,'Crítico'),
(33,3,1,3,'Crítico'),
(36,3,1,3,'Crítico');  

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

	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		WHERE l.dthCaptura >= NOW() - INTERVAL 7 DAY 
		AND sm.tokenEmpresa = token
		ORDER BY l.dthCaptura DESC;
        
    SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
		JOIN leitura l ON l.idLeitura = a.idLeitura
		JOIN componente c ON c.idComponente = a.idComponente
		JOIN maquina m ON m.idmaquina = a.idmaquina
		JOIN setorMaquina sm ON sm.idMaquina = m.idMaquina
		AND sm.tokenEmpresa = token
		ORDER BY l.dthCaptura DESC
		LIMIT 1;
        
	SELECT m.hostname as Máquina, c.tipoComponente as Componente, l.dado as Dado, DATE_FORMAT(l.dthCaptura, '%d/%m/%y %H:%i') as DataHora FROM alerta a 
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



-- Empresa 2001
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2001, 'Frigorífico Santa Bovina Ltda', 'Santa Bovina', '12234567000191', 1, '2025-06-05 09:12:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2001, 'Rua do Açougue', '120', 'Industrial', 'Cascavel', 'PR', '85810100');

-- Empresa 2002
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2002, 'Cortes Premium do Sul S/A', 'Premium Beef', '22987654000140', 1, '2025-07-18 14:35:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2002, 'Av. das Indústrias', '455', 'Distrito 4', 'Passo Fundo', 'RS', '99010000');

-- Empresa 2003
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2003, 'FrigoVale Alimentos Ltda', 'FrigoVale', '33222111000109', 1, '2025-08-02 11:05:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2003, 'Rua da Produção', '89', 'Centro', 'Uberlândia', 'MG', '38400100');

-- Empresa 2004
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2004, 'Carnes Mineiras S/A', 'Minas Beef', '44111222000155', 1, '2025-09-10 16:20:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2004, 'Rua das Fazendas', '77', 'Distrito Industrial', 'Belo Horizonte', 'MG', '30140000');

-- Empresa 2005
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2005, 'Frigorífico Paulista LTDA', 'Paulista Meats', '55123456000100', 1, '2025-06-28 08:45:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2005, 'Av. Água Branca', '210', 'Vila Industrial', 'Campinas', 'SP', '13010000');

-- Empresa 2006
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2006, 'NorteCarnes Comércio Ltda', 'NorteCarnes', '66123456000188', 1, '2025-10-03 13:10:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2006, 'Rua do Porto', '34', 'Centro', 'Fortaleza', 'CE', '60000000');

-- Empresa 2007
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2007, 'Frigorífico Atlântico S/A', 'Atlântico Beef', '77123456000177', 1, '2025-05-30 10:00:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2007, 'Av. Marítima', '500', 'Zona Industrial', 'Salvador', 'BA', '40000000');

-- Empresa 2008
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2008, 'Cortes da Serra Ltda', 'Serra Carnes', '88123456000166', 1, '2025-07-29 17:25:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2008, 'Rua dos Criadores', '98', 'Bairro Agro', 'Londrina', 'PR', '86000000');

-- Empresa 2009
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2009, 'Frigorífico do Litoral Ltda', 'Litoral Meats', '99123456000155', 1, '2025-09-22 12:40:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2009, 'Av. Oceânica', '777', 'Portuário', 'Porto Alegre', 'RS', '90000000');

-- Empresa 2010
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2010, 'Carnes do Planalto S/A', 'Planalto Beef', '10123456000144', 1, '2025-08-15 09:55:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2010, 'Rua do Frigorífico', '22', 'Distrito Agro', 'Goiânia', 'GO', '74000000');

-- Empresa 2011
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2011, 'Frigosul Distribuição Ltda', 'Frigosul', '11123456000133', 1, '2025-11-05 15:05:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2011, 'Av. Central', '310', 'Industrial', 'Pelotas', 'RS', '96000000');

-- Empresa 2012
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2012, 'Carnes do Norte Ltda', 'Norte Frigo', '12123456000122', 1, '2025-10-19 08:30:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2012, 'Rua dos Pescadores', '140', 'Centro', 'Belém', 'PA', '66000000');

-- Empresa 2013
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2013, 'Carnes da Serra LTDA', 'SerraFrios', '13123456000111', 1, '2025-06-12 11:50:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2013, 'Estrada Rural', '5', 'Zona Rural', 'Florianópolis', 'SC', '88000000');

-- Empresa 2014
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2014, 'Frigorífico Centro Oeste Ltda', 'CentroOeste Meats', '14123456000100', 1, '2025-05-25 10:15:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2014, 'Av. Agro', '999', 'Distrito Agro', 'Anápolis', 'GO', '75000000');

-- Empresa 2015
INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2015, 'Cortes do Nordeste S/A', 'Nordeste Carnes', '15123456000189', 1, '2025-11-12 13:20:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2015, 'Rua do Abate', '56', 'Distrito Industrial', 'Recife', 'PE', '50000000');

INSERT INTO empresa (tokenEmpresa, razaoSocial, nomeFantasia, cnpj, statusEmpresa, dataCadastro)
VALUES (2016, 'Frigorífico Central S/A', 'Central Carnes', '16234567000198', 1, '2025-05-22 10:30:00');

INSERT INTO endereco (tokenEmpresa, logradouro, numero, bairro, cidade, estado, cep)
VALUES (2016, 'Avenida do Comércio', '120', 'Bairro Central', 'Recife', 'PE', '50010000');

Select * from empresa;
select * from endereco;
UPDATE empresa
SET statusEmpresa = 1
WHERE tokenEmpresa = 2016;







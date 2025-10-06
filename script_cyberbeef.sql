create database cyberbeef;
use cyberbeef;

create table contato (
    idContato int primary key auto_increment,
    telefone varchar(15),
    email varchar(255),
    assunto varchar(45),
    descricao varchar(255)
);

create table empresa (
    tokenEmpresa int primary key,
    razaoSocial varchar(255),
    nomeFantasia varchar(255),
    cnpj char(14),
    cep char(8),
    numero varchar(10),
    contato int,
    constraint fkContatoEmpresa foreign key (contato) references contato(idContato)
);

create table permissaoUsuario (
    idPermissaoUsuario int primary key auto_increment,
    cargo varchar(45),
    nivelPermissao int
);

create table usuario (
    idUsuario int primary key auto_increment,
    tokenEmpresa int,
    permissaoUsuario int,
    email varchar(255),
    senha varchar(255),
    nome varchar(255),
    constraint fkEmpresaUsuario foreign key (tokenEmpresa) references empresa(tokenEmpresa),
    constraint fkPermissaoUsuario foreign key (permissaoUsuario) references permissaoUsuario(idPermissaoUsuario)
);

create table setor (
    idSetor int primary key auto_increment,
    tokenEmpresa int,
    nomeSetor varchar(45),
    descricao varchar(255),
    constraint fkSetorEmpresa foreign key (tokenEmpresa) references empresa(tokenEmpresa)
);

create table maquina (
    idMaquina int primary key auto_increment,
    macAddress varchar(45),
    ip varchar(45),
    hostname varchar(255),
    sistemaOperacional varchar(45),
    dthRegistro datetime
);

create table setorMaquina (
    idSetor int,
    tokenEmpresa int,
    idMaquina int,
    status varchar(10),
    responsavel varchar(45),
    dataVinculacao datetime,
    constraint fkSetorMaquina foreign key (idSetor) references setor(idSetor),
    foreign key (tokenEmpresa) references empresa(tokenEmpresa),
    foreign key (idMaquina) references maquina(idMaquina),
    primary key (idSetor, tokenEmpresa, idMaquina)
);

create table componente (
    idComponente int primary key auto_increment,
    idMaquina int,
    tipoComponente enum('CPU','MEMORIA','DISCO','REDE'),
    unidadeMedida varchar(45),
    constraint fkComponenteMaquina foreign key (idMaquina) references maquina(idMaquina)
);

create table nucleoCpu (
    idNucleo int primary key auto_increment,
    idComponente int,
    idMaquina int,
    constraint fkNucleoComponente foreign key (idComponente) references componente(idComponente),
    foreign key (idMaquina) references maquina(idMaquina)
);

create table leitura (
    idLeitura int primary key auto_increment,
    idComponente int,
    idMaquina int,
    dado float,
    dthCaptura datetime,
    idNucleo int,
    constraint fkLeituraComponente foreign key (idComponente) references componente(idComponente),
    foreign key (idMaquina) references maquina(idMaquina),
    foreign key (idNucleo) references nucleoCpu(idNucleo)
);

create table rede (
    idRede int primary key auto_increment,
    idMaquina int,
    idComponente int,
    download float,
    upload float,
    packetLoss float,
    dthCaptura datetime,
    constraint fkRedeMaquina foreign key (idMaquina) references maquina(idMaquina),
    constraint fkRedeComponente foreign key (idComponente) references componente(idComponente)
);

create table parametro (
    idParametro int primary key auto_increment,
    idComponente int,
    idMaquina int,
    nivel varchar(45),
    min float,
    max float,
    constraint fkParametroComponente foreign key (idComponente) references componente(idComponente),
    foreign key (idMaquina) references maquina(idMaquina)
);

create table alerta (
    idAlerta int primary key auto_increment,
    idLeitura int,
    idComponente int,
    idMaquina int,
    idParametro int,
    descricao varchar(255),
    constraint fkAlertaLeitura foreign key (idLeitura) references leitura(idLeitura),
    foreign key (idComponente) references componente(idComponente),
    foreign key (idMaquina) references maquina(idMaquina),
    foreign key (idParametro) references parametro(idParametro)
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
('00:11:22:33:44:55', '192.168.0.10', 'Servidor SCADA', 'Ubuntu', now());

INSERT INTO setorMaquina (idSetor, tokenEmpresa, idMaquina, status, responsavel, dataVinculacao) VALUES 
(1, 1001, 1, 'Ativa', 'Rafael', NOW());

INSERT INTO componente (idMaquina, tipoComponente, unidadeMedida) VALUES 
(1, 'REDE', 'Mbps'),
(1, 'MEMORIA', 'GB'),
(1, 'DISCO', 'GB'),
(1, 'CPU', '%');


select r.idRede, m.idMaquina, r.download, r.upload, r.packetLoss, r.dthCaptura from rede r join maquina m on m.idMaquina = r.idMaquina order by r.dthCaptura desc;

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
    c.tipoComponente,
    l.dado,
    l.dthCaptura
FROM leitura l
JOIN componente c ON l.idComponente = c.idComponente
JOIN maquina m ON l.idMaquina = m.idMaquina
ORDER BY l.dthCaptura DESC;

-- Leituras específicas de rede
SELECT 
    r.idRede,
    m.hostname,
    r.download,
    r.upload,
    r.packetLoss,
    r.dthCaptura
FROM rede r
JOIN maquina m ON r.idMaquina = m.idMaquina
ORDER BY r.dthCaptura DESC;



select * from leitura join componente;

SELECT
    r.idRede,
    c.tipoComponente AS tipoComponenteRede,
    r.download,
    r.upload,
    r.packetLoss,
    c.unidadeMedida AS unidadeRede,
    r.dthCaptura AS dataRede,
    c.idComponente AS idComponenteRede,
    l.idLeitura,
    l.idComponente AS idComponenteLeitura,
    lc.tipoComponente AS tipoComponenteLeitura,
    lc.unidadeMedida AS unidadeLeitura,
    l.dado AS valorLeitura,
    l.dthCaptura AS dataLeitura
FROM rede r
JOIN componente c 
    ON r.idComponente = c.idComponente
LEFT JOIN leitura l
    ON l.idMaquina = r.idMaquina
LEFT JOIN componente lc
    ON lc.idComponente = l.idComponente
ORDER BY r.dthCaptura DESC, l.dthCaptura DESC;




SELECT 
    e.tokenEmpresa,
    e.nomeFantasia,
    e.razaoSocial,
    e.cnpj,
    e.cep,
    e.numero,
    c.telefone,
    c.email,
    c.assunto
FROM empresa e
JOIN contato c ON e.contato = c.idContato;


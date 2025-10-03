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
rua varchar(255),
numero varchar(10),
contato int,
constraint fkContatoEmpresa
foreign key (contato) references contato(idContato)
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
constraint fkEmpresaUsuario
foreign key (tokenEmpresa) references empresa(tokenEmpresa),
constraint fkPermissaoUsuario
foreign key (permissaoUsuario) references permissaoUsuario(idPermissaoUsuario)
);

create table setor (
idSetor int primary key auto_increment,
tokenEmpresa int,
nomeSetor varchar(45),
descricao varchar(255),
constraint fkSetorEmpresa
foreign key (tokenEmpresa) references empresa(tokenEmpresa)
);

create table maquina (
idMaquina int primary key auto_increment,
macAddress varchar(45),
ip varchar(45),
hostname varchar(255),
sistemaOperacional varchar(45)
);

create table setorMaquina (
idSetor int,
tokenEmpresa int,
idMaquina int,
status tinyint,
responsavel varchar(45),
dataVinculacao datetime,
constraint fkSetorMaquina
foreign key (idSetor) references setor(idSetor),
foreign key (tokenEmpresa) references empresa(tokenEmpresa),
foreign key (idMaquina) references maquina(idMaquina),
primary key (idSetor, tokenEmpresa, idMaquina)
);

create table componente (
idComponente int primary key auto_increment,
idMaquina int,
nomeComponente varchar(45),
unidadeMedida varchar(45),
constraint fkComponenteMaquina
foreign key (idMaquina) references maquina(idMaquina)
);

create table nucleoCpu (
idNucleo int primary key auto_increment,
idComponente int,
idMaquina int,
constraint fkNucleoComponente
foreign key (idComponente) references componente(idComponente),
foreign key (idMaquina) references maquina(idMaquina)
);

create table Leitura (
idLeitura int primary key auto_increment,
idComponente int,
idMaquina int,
dado float,
dthCaptura datetime,
idNucleo int,
constraint fkLeituraComponente
foreign key (idComponente) references componente(idComponente),
foreign key (idMaquina) references maquina(idMaquina),
foreign key (idNucleo) references nucleoCpu(idNucleo)
);

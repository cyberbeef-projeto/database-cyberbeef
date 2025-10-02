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

select * from usuario;
select * from permissaoUsuario;
select * from empresa;
select * from contato;

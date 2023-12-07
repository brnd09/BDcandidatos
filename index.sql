create schema eleicao;
use eleicao;

create table if not exists partidos(
numero int auto_increment unique primary key not null,
nome varchar(55) not null
);

create table if not exists cargos(
id_cargo int auto_increment unique primary key not null,
nome_cargo varchar(55) not null
);

create table if not exists zonas_secoes(
id_zona int auto_increment unique primary key not null,
numero_secao int not null,
nome_zona varchar(55) not null,
qtde_eleitores int not null
);

create table if not exists candidatos(
id_partido int auto_increment unique primary key not null,
numero int,
constraint numero foreign key (numero) references partidos(numero),
nome int,
constraint nome foreign key (nome) references partidos(nome),
id_cargo int,
constraint id_cargo foreign key (id_cargo) references cargos(id_cargo)
);

create table if not exists votacoes(
id_candidato int auto_increment unique primary key not null,
id_zona int,
constraint id_zona foreign key (id_zona) references zonas_secoes(id_zona),
numero_secao int,
constraint numero_secao foreign key (numero_secao) references zonas_secoes(numero_secao),
quantidade int not null
);

-- altere a quantidade de votos multiplicando por 2, para os candidatos a governador (código do cargo = 1) e do partido democrático (código de partido = 5) --
UPDATE votacoes
SET quantidade = quantidade * 2
WHERE id_candidato IN (
SELECT id_partido FROM candidatos WHERE id_cargo = 1 AND id_partido = 5
);

-- crie uma instrução em linguagem SQL para apagar todos os cargos que não possuem candidatos --
DELETE FROM cargos
WHERE id_cargo NOT IN (SELECT DISTINCT id_cargo FROM candidatos);

-- crie uma instrução de consulta que retorne como resultado o número do partido, nome do partido, nome do candidato e a média de votos obtidos, apenas para os cinco mais votados --
SELECT
    numero_partido,
    nome_partido,
    nome_candidato,
    AVG(quantidade_votos) AS media_votos
FROM (
    SELECT
        p.numero AS numero_partido,
        p.nome AS nome_partido,
        c.nome AS nome_candidato,
        v.quantidade AS quantidade_votos,
        DENSE_RANK() OVER (PARTITION BY p.numero ORDER BY SUM(v.quantidade) DESC) AS ranking
    FROM
        partidos p
    JOIN candidatos c ON p.numero = c.numero
    JOIN votacoes v ON c.id_partido = v.id_candidato
    GROUP BY
        p.numero,
        p.nome,
        c.nome,
        v.quantidade
) AS ranked_votes
WHERE
    ranking <= 5
GROUP BY
    numero_partido,
    nome_partido,
    nome_candidato
ORDER BY
    numero_partido,
    media_votos DESC;













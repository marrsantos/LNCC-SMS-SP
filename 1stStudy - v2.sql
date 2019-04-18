/*################################################################## */
/* PROCEDIMENTO PRINCIPAL */
/* Author: Marcelo Santos */

/* Release temporary tables */
Discard temporary;

/* Criando tabela temporária apenas com atendimentos relacionados aos CIDs relevantes */
Select codigocns, datacompleta, tipoestabelecimentoexecutante, nomeestabelecimentoexecutante, numerocep,
       codigocboexecutante, nomecboexecutante, codigocid, nomecid, h2nomenivel2a
       into temporary tbatcid
	   from at54a where substring(codigocid,1,1)='O' and substring(codigocid,2,2)<'98'
	   and codigocns not like '%-%' and codigocboexecutante not like '%-%';
	   
/* Criando tabela temporária com todos atendimentos (procedimentos) de pacientes com CIDs relevantes (join tbatcid on datacompleta, codigocns e cboexecutante) */
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.numerocep, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, b1.codigocid, b1.nomecid, a1.h2nomenivel2a
	   into temporary tbatcidproc
	   from at54b a1 left outer join tbatcid b1 using (codigocns, datacompleta, codigocboexecutante)
	   where a1.codigocns in (select codigocns from tbatcid group by codigocns)
	   and a1.codigoprocedimento not like '%-%' and a1.codigocns not like '%-%' and a1.codigocboexecutante not like '%-%'
	   and ((a1.nomeprocedimento like '%Natal%' or a1.nomeprocedimento like '%Obste%' or a1.nomeprocedimento like '%Gravid%' or a1.nomeprocedimento like '%Puer%' 
			or a1.nomeprocedimento like '%Parto%' or a1.nomeprocedimento like '%Gestan%' or a1.nomeprocedimento like '%Fet%' or a1.nomeprocedimento like '%Vagin%')
	   or a1.nomeespecialidade in (
		   	'Ginecologia/Obstetricia - Pré-Natal Alto Risco (R)',
			'Anestesiologia',
			'Ginecologia (Desativado)',
			'Parteira (Desativado)',
			'Enfermeira Obstetra (L)',
			'Cirurgia Geral Ginecologica (R)',
		   	'Cirurgia Geral (R)',
			'Ginecologia/Obstetricia (R) (L)',
			'Cirurgia Ginecologica  - Laqueadura (R)',
			'Ginecologia/Obstetricia - Climatério (L)',
			'Pediatria (L)',
		    'Enfermeira Obstetra (L)',
		    'Ginecologia (Desativado)',
		    'Ginecologia/Obstetricia - Climatério (L)',
		    'Ginecologia/Obstetricia - Pré-Natal Alto Risco (R)',
		    'Ginecologia/Obstetricia (R) (L)',
			'Nutrição (R) (L)'
	   ) or (a1.nomecboexecutante like '%Gineco%' or a1.nomecboexecutante like '%Obst%' or a1.nomecboexecutante like '%Pediatra%')
	   ) order by a1.codigocns, a1.datacompleta, a1.nomeestabelecimentoexecutante, a1.codigocboexecutante;

/* Criando tabela temporária com todos atendimentos (procedimentos) de pacientes sem CIDs relevantes */ 
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.numerocep, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, a1.h2nomenivel2a
       into temporary tbatcidproc2
	   from at54b a1 
	   where a1.codigocns not in (select codigocns from tbatcid group by codigocns)
	   and a1.codigoprocedimento not like '%-%' and a1.codigocns not like '%-%' and a1.codigocboexecutante not like '%-%'
	   and (a1.nomeprocedimento like '%Natal%' or a1.nomeprocedimento like '%Obste%' or a1.nomeprocedimento like '%Gravid%' or a1.nomeprocedimento like '%Puer%' 
			or a1.nomeprocedimento like '%Parto%' or a1.nomeprocedimento like '%Gestan%' or a1.nomeprocedimento like '%Fet%' or a1.nomeprocedimento like '%Vagin%')
	   order by a1.codigocns, a1.datacompleta, a1.nomeestabelecimentoexecutante, a1.codigocboexecutante;

/* Unificando todos os procedimentos (tbatcidproc + tbatcidproc2) em uma tabela única */
insert into tbatcidproc(codigocns, datacompleta, tipoestabelecimentoexecutante, nomeestabelecimentoexecutante, numerocep, cepcompleto, 
						nomeespecialidade, codigocboexecutante, nomecboexecutante, codigoprocedimento, nomeprocedimento, h2nomenivel2a) 
						select * from tbatcidproc2;
/* Inserindo os registros da tabela de atendimentos com CID */						
insert into tbatcidproc(codigocns, datacompleta, tipoestabelecimentoexecutante, nomeestabelecimentoexecutante, numerocep, 
						codigocboexecutante, nomecboexecutante, codigocid, nomecid, h2nomenivel2a) 
						select * from tbatcid;

/* FLUXO DE PACIENTES - Pré-natal/Parto/Puerpério (exclusao final de possíveis registros repetidos)*/		      
select codigocns,datacompleta,tipoestabelecimentoexecutante,nomeestabelecimentoexecutante,numerocep,cepcompleto,nomeespecialidade,codigocid,nomecid,codigoprocedimento,nomeprocedimento,codigocboexecutante,nomecboexecutante,h2nomenivel2a,count(*) 
       into teste1
	   from tbatcidproc group by codigocns,datacompleta,tipoestabelecimentoexecutante,nomeestabelecimentoexecutante,numerocep,cepcompleto,nomeespecialidade,codigocid,nomecid,codigoprocedimento,nomeprocedimento,codigocboexecutante,nomecboexecutante,h2nomenivel2a
       order by codigocns,datacompleta,tipoestabelecimentoexecutante,nomeestabelecimentoexecutante,numerocep,cepcompleto,nomeespecialidade,codigocid,nomecid,codigoprocedimento,nomeprocedimento,codigocboexecutante,nomecboexecutante,h2nomenivel2a;   

/* Marcar o select abaixo e apertar o botão correspondente para exportar o CSV */
/* EXPORTAÇÃO APENAS FUNCIONANDO PARA TABELAS NÃO TEMPORÁRIAS */
select * from teste1;


/*#####################################################################*/
/*################################################################## */
/* ANÁLISE DOS DADOS Desenvolvimento */
/*#############################################*/

/* SELECT 2 */
Select  codigocns,  datacompleta, tipoestabelecimentoexecutante, nomeestabelecimentoexecutante, 
       codigocboexecutante, nomecboexecutante, codigocid, nomecid, h2nomenivel2a
	    into temporary tbatcid_teste1
		from at54a where substring(codigocid,1,1)='O' and substring(codigocid,2,2)<'98'
	   and codigocns='201163524630006'
	   order by datacompleta;

/* SELECT 1 */
Todos procedimentos de pacientes com CID (incluindo lançamentos com CID e sem CID)
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, b1.codigocid, b1.nomecid, a1.h2nomenivel2a
	   from at54b a1 left outer join tbatcid b1 using (codigocns, datacompleta, codigocboexecutante)
	   where a1.codigocns='201163524630006'

/* SELECT 3 */
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, b1.codigocid, b1.nomecid, a1.h2nomenivel2a
	   from at54b a1 left outer join tbatcid b1 using (codigocns, datacompleta, codigocboexecutante)
	   where (a1.nomeprocedimento like '%Natal%' or a1.nomeprocedimento like '%Obste%' or a1.nomeprocedimento like '%Gravid%' or a1.nomeprocedimento like '%Puer%' 
			or a1.nomeprocedimento like '%Parto%' or a1.nomeprocedimento like '%Gestan%' or a1.nomeprocedimento like '%Fet%' or a1.nomeprocedimento like '%Vagin%')
	   	  and a1.codigocns='201163524630006'

/* SELECT 4 */
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, b1.codigocid, b1.nomecid, a1.h2nomenivel2a
	   into temporary tbatcidproc_teste1
	   from at54b a1 left outer join tbatcid b1 using (codigocns, datacompleta, codigocboexecutante)
	   where a1.codigocns in (select codigocns from tbatcid group by codigocns)
	   and a1.codigoprocedimento not like '%-%' and a1.codigocns not like '%-%' and a1.codigocboexecutante not like '%-%'
	   and ((a1.nomeprocedimento like '%Natal%' or a1.nomeprocedimento like '%Obste%' or a1.nomeprocedimento like '%Gravid%' or a1.nomeprocedimento like '%Puer%' 
			or a1.nomeprocedimento like '%Parto%' or a1.nomeprocedimento like '%Gestan%' or a1.nomeprocedimento like '%Fet%' or a1.nomeprocedimento like '%Vagin%')
	   or a1.nomeespecialidade in (
		   	'Ginecologia/Obstetricia - Pré-Natal Alto Risco (R)',
			'Anestesiologia',
			'Ginecologia (Desativado)',
			'Parteira (Desativado)',
			'Enfermeira Obstetra (L)',
			'Cirurgia Geral Ginecologica (R)',
		   	'Cirurgia Geral (R)',
			'Ginecologia/Obstetricia (R) (L)',
			'Cirurgia Ginecologica  - Laqueadura (R)',
			'Ginecologia/Obstetricia - Climatério (L)',
			'Pediatria (L)',
		    'Enfermeira Obstetra (L)',
		    'Ginecologia (Desativado)',
		    'Ginecologia/Obstetricia - Climatério (L)',
		    'Ginecologia/Obstetricia - Pré-Natal Alto Risco (R)',
		    'Ginecologia/Obstetricia (R) (L)',
			'Nutrição (R) (L)'
	   ) or (a1.nomecboexecutante like '%Gineco%' or a1.nomecboexecutante like '%Obst%'or a1.nomecboexecutante like '%Pediatra%'))
	   	  and a1.codigocns='201163524630006'
	   
/* SELECT 5 */
Select a1.codigocns, a1.datacompleta, a1.tipoestabelecimentoexecutante, a1.nomeestabelecimentoexecutante, a1.cepcompleto, a1.nomeespecialidade, 
       a1.codigocboexecutante, a1.nomecboexecutante, a1.codigoprocedimento, a1.nomeprocedimento, a1.h2nomenivel2a
	   from at54b a1 
	   where a1.codigocns not in (select codigocns from tbatcid group by codigocns)
	   and a1.codigoprocedimento not like '%-%' and a1.codigocns not like '%-%' and a1.codigocboexecutante not like '%-%'
	   and (a1.nomeprocedimento like '%Natal%' or a1.nomeprocedimento like '%Obste%' or a1.nomeprocedimento like '%Gravid%' or a1.nomeprocedimento like '%Puer%' 
			or a1.nomeprocedimento like '%Parto%' or a1.nomeprocedimento like '%Gestan%' or a1.nomeprocedimento like '%Fet%' or a1.nomeprocedimento like '%Vagin%')
            and a1.codigocns='201163524630006'

/* SELECT 6 */
select codigocns,datacompleta,tipoestabelecimentoexecutante,nomeestabelecimentoexecutante,cepcompleto,nomeespecialidade,codigocid,nomecid,codigoprocedimento,nomeprocedimento,codigocboexecutante,nomecboexecutante,h2nomenivel2a,count(*) 
	   from tbatcidproc where codigocns='201163524630006'
			 group by codigocns,datacompleta,tipoestabelecimentoexecutante,nomeestabelecimentoexecutante,cepcompleto,nomeespecialidade,codigocid,nomecid,codigoprocedimento,nomeprocedimento,codigocboexecutante,nomecboexecutante,h2nomenivel2a

			 
select count(*) from tbatcid where codigocns='201163524630006'		
select count(*) from tbatcidproc where codigocns='201163524630006'
			 /* APARENTEMENTE O INSERT NÃO ESTÁ INSERINDO OS REGISTROS COM CID - VERIFICAR*/

select count(*) from tbatcid where codigocns='201163524630006'
6520 21
select count(*) from tbatcidproc where codigocns='201163524630006'
19984 8			 
select * from tbatcidproc
			 
select count(*) from tbatcid_teste1 
select count(*) from tbatcidproc_teste1 where codigocns='201163524630006'
			 
insert into tbatcidproc_teste1(codigocns, datacompleta, tipoestabelecimentoexecutante, nomeestabelecimentoexecutante, codigocboexecutante, nomecboexecutante, 
						 codigocid, nomecid, h2nomenivel2a) select * from tbatcid_teste1;			 
select * from tbatcidproc_teste	order by datacompleta	
			 
select * from at54b limit 10			 
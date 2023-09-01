--OS's
select
	convert(int,tos.n_os) as 'OS',
	tos.titulo as 'T�tulo',
	toi.plano_contas as 'Segmento',
	tor.cod_cliente as 'C�d. Cliente',
	tor.cliente as 'Cliente',
	-- Retorna o menor valor de data do apontamento
	min(convert(date,tapont.data)) as 'Primeiro Apontamento'
from
	(select * from tctrl_ph where cod_empresa = 1) as tapont

-- Relacionamento com a tabela de processos produtivos, apenas da empresa 1
inner join (select * from tpro_pro where cod_empresa = 1) as tpp
	on tapont.cod_barr = tpp.codigo
		-- Relacionamento com a tabela de ordens de servi�o (OS's). Apenas da empresa 1 e n�o considerando OS's de estrutura
		inner join (select * from tos where cod_empresa = 1 and n_os not like 'e%') as tos
			on tpp.cod_os = tos.codigo
				-- Relacionamento com as tabelas de or�amento. Considera-se apenas a empresa 1 e desconsidera materiais de cliente (erros de digita��o)
				inner join (select * from torcamento_itens where cod_empresa = 1 and plano_contas <> 'MATERIAL DE CLIENTE') as toi
					on tos.guid_orcamento = toi.guid_linha
						inner join (select * from torcamento where cod_empresa = 1) as tor
							on toi.cod_orcamento = tor.codigo

group by 
	-- Agrupando as informa��es do apontamento por OS's e suas informa��es or�ament�rias
	convert(int,tos.n_os), tos.titulo, toi.plano_contas, tor.cod_cliente, tor.cliente

order by 
	-- Ordenando por OS's de maneira decrescente
	convert(int,tos.n_os) desc
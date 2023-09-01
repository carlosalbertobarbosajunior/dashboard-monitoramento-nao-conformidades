--Notas Fiscais
select
	tnf.numero as 'NF',
	convert(date,tnf.dt_emissao) as 'Data Emissão',
	tnf.cancelada as 'Cancelada',
	tnf.nfe_desc_status as 'Status',
	tnf.cfop as 'CFOP',
	tnf.entrada as 'Entrada',
	tnf.saida as 'Saída',
	tnfi.codigo as 'Cod Interno',
	-- Identifica o número do serviço (OS), caso não haja, procura pelo código interno do material
	isnull(tos.n_os,(select top 1 n_os from tos where cod_empresa=1 and n_os not like 'e%'and cod_pecas=tnfi.codigo)) as 'OS',
	tnfi.produto as 'Produto',
	tnfi.qtde as 'Qtd da NF',
	tnfi.unidade as 'Un',
	tnfi.vl_total + tnfi.vl_ipi as 'Valor',
	-- Identifica a ordem de faturamento da NF
	(select top 1 codigo from tordem_fat where cod_empresa = 1 and status=1 and numero_nf = tnf.numero) as 'OF',
	-- Identifica a quantidade faturada pelo orçamento, ou pelo código interno do material
	isnull(toi.qtde_faturada,(select top 1 qtde_faturada from torcamento_itens where cod_empresa=1 and cod_interno = tnfi.codigo)) as 'Qtd Total Faturada (Orçamento)',
	-- Identifica a quantidade pelo orçamento, ou pelo ´código interno do material
	isnull(toi.qtde,(select top 1 qtde from torcamento_itens where cod_empresa=1 and cod_interno=tnfi.codigo)) as 'Qtd Total (Orçamento)',
	-- Quantidade solicitada subtraída da quantidade já faturada. Retorna 0 caso encontre valor negativo
	case
		when isnull(toi.qtde,(select top 1 qtde from torcamento_itens where cod_empresa=1 and cod_interno=tnfi.codigo))-isnull(toi.qtde_faturada,(select top 1 qtde_faturada from torcamento_itens where cod_empresa=1 and cod_interno = tnfi.codigo)) < 0 then 0
		else isnull(toi.qtde,(select top 1 qtde from torcamento_itens where cod_empresa=1 and cod_interno=tnfi.codigo))-isnull(toi.qtde_faturada,(select top 1 qtde_faturada from torcamento_itens where cod_empresa=1 and cod_interno = tnfi.codigo))
	end as 'Qtd Não Faturada (Orçamento)'
from
	(select * from tnota_fiscal_item where cod_empresa=1) as tnfi

-- Relacionamento com a tabela principal de notas fiscais. Apenas notas da empresa 1, com condição de pagamento existente e notas fiscais não devolvidas
inner join (select * from tnota_fiscal where cod_empresa=1 and condicao_pagamento is not null and condicao_pagamento <> '' and numero not in (select distinct nfref_numero_nf from tnota_fiscal_nfref where cod_empresa =1)) as tnf
	on tnfi.numero_nf = tnf.numero

-- Relacionamento com as tabelas de orçamento. Apenas orçamentos da empresa 1, que foram ganhos na versão atual
left join (select * from torcamento_itens where cod_empresa=1) as toi
	on tnfi.guid_orcamento = toi.guid_linha 
		left join (select * from torcamento where cod_empresa = 1 and estagio_orc = 'GANHOU' and status=1) as tor
			on toi.cod_orcamento = tor.codigo

-- Relacionamento com a tabela de serviços. Apenas OSs que não são de estrutura
left join (select * from tos where cod_empresa=1 and n_os not like 'e%') as tos
	on tnfi.guid_orcamento = tos.guid_orcamento

where
	-- Considerar apenas NFs cujo material foi produzido pela empresa 1
	tnfi.codigo in (select distinct cod_pecas from tos where cod_empresa=1)
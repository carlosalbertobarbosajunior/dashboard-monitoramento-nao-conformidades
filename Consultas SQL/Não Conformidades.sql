--Não Conformidades
select 
	tnc.codigo as 'N',
	toi.plano_contas as 'Segmento',
	tor.cod_cliente as 'Cód. Cliente',
	tor.cliente as 'Cliente',
	familia_n_conforme as 'Família',
	cod_os_completo as 'OS',
	fase as 'Setor/Fase',
	convert(date,data) as 'Data de Abertura',
	-- Verifica se a não conformidade possui data de eficácia e data de conclusão para classificá-la como concluída
	case
		when 
			case
				when dt_efetiva_eficacia >= dt_conclusao then convert(date,dt_efetiva_eficacia)
				else convert(date,dt_conclusao)
			end is not null then 1
		else 0
	end as 'Concluído',
	-- Define o maior entre data de conclusão e data de eficácia e o chama de data de fechamento
	case
		when dt_efetiva_eficacia >= dt_conclusao then convert(date,dt_efetiva_eficacia)
		else convert(date,dt_conclusao)
	end as 'Data de Fechamento',
	-- Calcula o tempo em dias para a resolução da NC
	(case
		when dt_efetiva_eficacia >= dt_conclusao then convert(int,dt_efetiva_eficacia)
		else convert(int,dt_conclusao)
	end - convert(int,data)) as 'Tempo (Dias)',
	-- Define a metodologia utilizada através da data
	case
		when data < '2023-06-01' then 'PFMEA'
		else 'GUT'
	end as 'GUT/PFMEA',
	valor_campo_adicional5 as 'Nota1',
	valor_campo_adicional6 as 'Nota2',
	valor_campo_adicional7 as 'Nota3',
	-- Multiplica as três notas da metodologia e obtém o valor final
	(convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) as 'Nota Final',
	-- Define o IR baseado na metodologia utilizada e seus valores de nota final
	case
		when data < '2023-06-01' then 
			case
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 100 then 'Baixo'
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 500 then 'Moderado'
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 1000 then 'Alto'
			end
		else 
			case
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 50 then 'Baixo'
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 100 then 'Moderado'
				when (convert(int,valor_campo_adicional5)*convert(int,valor_campo_adicional6)*convert(int,valor_campo_adicional7)) <= 125 then 'Alto'
			end
	end as 'Índice de Risco',
	-- Converte o texto de custo em valor
	convert(float,replace(replace(valor_campo_adicional2,'.',''),',','.')) as 'Custo'
from 
	tn_conformidade as tnc

-- Relacionamento com a tabela de ordens de serviço, considerando apenas a empresa 1
left join (select codigo, guid_orcamento from tos where cod_empresa = 1) as tos
	on tnc.cod_os = tos.codigo
		-- Relacionamento com as tabelas de orçamento, considerando apenas a empresa 1
		left join (select guid_linha, cod_orcamento, plano_contas from torcamento_itens where cod_empresa = 1) as toi
			on tos.guid_orcamento = toi.guid_linha
				left join (select codigo, cod_cliente, cliente from torcamento where cod_empresa = 1) as tor
					on toi.cod_orcamento = tor.codigo

where
	cod_empresa = 1 and 
	-- Desconsiderando orçamentos de material de cliente (erro de digitação)
    toi.plano_contas <> 'MATERIAL DE CLIENTE'
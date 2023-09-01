# dashboard-monitoramento-nao-conformidades
Dashboard para acompanhamento das não conformidades da HKM Indústria e Comércio

## Consultas ao banco de dados

O arquivo .sql de cada script foi disponibilizado na pasta **Consultas SQL**. 
<pre>
  ```sql
  --Segmentos
select 
	codigo, 
	nome 
from 
	ttp_movi
where 
	-- Apenas segmentos da empresa 1
	cod_empresa = 1 and 
	-- Apenas segmentos presentes nos orçamentos já criados na empresa 1 (exceto material de cliente)
	nome in (select distinct plano_contas from torcamento_itens where cod_empresa = 1 and plano_contas <> 'MATERIAL DE CLIENTE')
  ```
</pre>

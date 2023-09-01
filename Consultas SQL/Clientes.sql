--Clientes
select distinct 
	codigo as 'ID', 
	nome as 'Cliente' 
from 
	tcliente 
where 
	-- Considerando apenas a empresa 1
	cod_empresa = 1
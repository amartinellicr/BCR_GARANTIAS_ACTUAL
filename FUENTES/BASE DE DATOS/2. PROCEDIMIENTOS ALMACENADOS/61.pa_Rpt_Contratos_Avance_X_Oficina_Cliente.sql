SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Rpt_Contratos_Avance_X_Oficina_Cliente', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Contratos_Avance_X_Oficina_Cliente;
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Contratos_Avance_X_Oficina_Cliente] AS

/******************************************************************
<Nombre>pa_Rpt_Contratos_Avance_X_Oficina_Cliente</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite actualizar las estructuras de las cuales se obtienen los datos estadísiticos sobre el 
             avance en la manipulación de los contratos por cada oficina cliente.
</Descripción>
<Entradas></Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/


if exists(select 1 from RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = convert(varchar(10),getdate(),103)) begin
	delete RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE where fecha_corte = convert(varchar(10),getdate(),103)
end

select 
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	c.cod_operacion,
	d.cod_garantia_fiduciaria,
	d.cod_tipo_documento_legal

into #temp_fiduciarias

from 
	GAR_DEUDOR a
	inner join GAR_SICC_BSMPC b
	on a.cedula_deudor = convert(varchar(30),b.bsmpc_sco_ident)
	inner join GAR_OPERACION c
	on a.cedula_deudor = c.cedula_deudor
	inner join GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION d
	on c.cod_operacion = d.cod_operacion
	inner join bcr_oficinas e
	on convert(smallint,b.bsmpc_dco_ofici) = e.cod_oficina
	left outer join dbo.GAR_SICC_PRMCA f
	on c.cod_contabilidad = f.prmca_pco_conta
	and c.cod_oficina = f.prmca_pco_ofici
	and c.cod_moneda = f.prmca_pco_moned
	and c.cod_producto = f.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),f.prmca_pnu_contr)

where 
f.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),f.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1

order by
	b.bsmpc_dco_ofici 


--Inserta las Garantias Fiduciarias por oficina cliente
insert into RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
(fecha_corte, cod_oficina, des_oficina, total_garantias_fiduciarias, total_garantias_fiduciarias_completas, total_garantias_fiduciarias_pendientes)
select distinct 
	convert(varchar(10),getdate(),103) as fecha_corte,
	a.cod_oficina_cliente as cod_oficina,
	a.des_oficina_cliente as des_oficina,
	(select count(*) from #temp_fiduciarias where cod_oficina_cliente = a.cod_oficina_cliente) as total_garantias_fiduciarias,	
	(select count(*) from #temp_fiduciarias where cod_oficina_cliente = a.cod_oficina_cliente and cod_tipo_documento_legal is not null) as total_garantias_fiduciarias_completas,
	(select count(*) from #temp_fiduciarias where cod_oficina_cliente = a.cod_oficina_cliente and cod_tipo_documento_legal is null) as total_garantias_fiduciarias_pendientes
from    
	#temp_fiduciarias a
order by
	a.cod_oficina_cliente 


drop table #temp_fiduciarias

--Selecciona las garantias reales por oficina cliente
select 
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	c.cod_operacion,
	d.cod_garantia_real,
	d.cod_tipo_documento_legal

into #temp_reales

from 
	GAR_DEUDOR a
	inner join GAR_SICC_BSMPC b
	on a.cedula_deudor = convert(varchar(30),b.bsmpc_sco_ident)
	inner join GAR_OPERACION c
	on a.cedula_deudor = c.cedula_deudor
	inner join GAR_GARANTIAS_REALES_X_OPERACION d
	on c.cod_operacion = d.cod_operacion
	inner join bcr_oficinas e
	on convert(smallint,b.bsmpc_dco_ofici) = e.cod_oficina
	left outer join dbo.GAR_SICC_PRMCA f
	on c.cod_contabilidad = f.prmca_pco_conta
	and c.cod_oficina = f.prmca_pco_ofici
	and c.cod_moneda = f.prmca_pco_moned
	and c.cod_producto = f.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),f.prmca_pnu_contr)

where 
f.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),f.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1

order by
	b.bsmpc_dco_ofici



--Actualiza las Garantias Reales por oficina cliente
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias_reales = (select count(*) from #temp_reales where cod_oficina_cliente = b.cod_oficina_cliente), 
	total_garantias_reales_completas = (select count(*) from #temp_reales where cod_oficina_cliente = b.cod_oficina_cliente and cod_tipo_documento_legal is not null), 
	total_garantias_reales_pendientes = (select count(*) from #temp_reales where cod_oficina_cliente = b.cod_oficina_cliente and cod_tipo_documento_legal is null)
from    
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE a
	inner join #temp_reales b
	on a.cod_oficina = b.cod_oficina_cliente
	and a.fecha_corte = convert(varchar(10),getdate(),103)


drop table #temp_reales

--Selecciona las garantias de valor por oficina cliente
select 
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	c.cod_operacion,
	d.cod_garantia_valor,
	d.cod_tipo_documento_legal

into #temp_valor

from 
	GAR_DEUDOR a
	inner join GAR_SICC_BSMPC b
	on a.cedula_deudor = convert(varchar(30),b.bsmpc_sco_ident)
	inner join GAR_OPERACION c
	on a.cedula_deudor = c.cedula_deudor
	inner join GAR_GARANTIAS_VALOR_X_OPERACION d
	on c.cod_operacion = d.cod_operacion
	inner join bcr_oficinas e
	on convert(smallint,b.bsmpc_dco_ofici) = e.cod_oficina
	left outer join dbo.GAR_SICC_PRMCA f
	on c.cod_contabilidad = f.prmca_pco_conta
	and c.cod_oficina = f.prmca_pco_ofici
	and c.cod_moneda = f.prmca_pco_moned
	and c.cod_producto = f.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),f.prmca_pnu_contr)
	inner join GAR_GARANTIA_VALOR g
	on d.cod_garantia_valor = g.cod_garantia_valor

where 
f.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),f.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1
and ((g.cod_clase_garantia = 20 and g.cod_tenencia <> 6) or 
     (g.cod_clase_garantia <> 20 and g.cod_tenencia = 6) or
     (g.cod_clase_garantia <> 20 and g.cod_tenencia <> 6))

order by
	b.bsmpc_dco_ofici 


--Actualiza las Garantias de Valor por oficina cliente
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias_valor = (select count(*) from #temp_valor where cod_oficina_cliente = b.cod_oficina_cliente), 
	total_garantias_valor_completas = (select count(*) from #temp_valor where cod_oficina_cliente = b.cod_oficina_cliente and cod_tipo_documento_legal is not null), 
	total_garantias_valor_pendientes = (select count(*) from #temp_valor where cod_oficina_cliente = b.cod_oficina_cliente and cod_tipo_documento_legal is null)
from    
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE a
	inner join #temp_valor b
	on a.cod_oficina = b.cod_oficina_cliente
	and a.fecha_corte = convert(varchar(10),getdate(),103)

drop table #temp_valor


--Actualiza valores en null para garantias fiduciarias
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias_fiduciarias = 0,
	total_garantias_fiduciarias_completas = 0,
	total_garantias_fiduciarias_pendientes = 0
where
	total_garantias_fiduciarias is null


--Actualiza valores en null para garantias reales
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias_reales = 0,
	total_garantias_reales_completas = 0,
	total_garantias_reales_pendientes = 0
where
	total_garantias_reales is null


--Actualiza valores en null para garantias de valor
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias_valor = 0,
	total_garantias_valor_completas = 0,
	total_garantias_valor_pendientes = 0
where
	total_garantias_valor is null


--Calcula los totales y los porcentajes
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	total_garantias	= total_garantias_fiduciarias + total_garantias_reales + total_garantias_valor,
	total_garantias_completas = total_garantias_fiduciarias_completas + total_garantias_reales_completas + total_garantias_valor_completas,
	total_garantias_pendientes = total_garantias_fiduciarias_pendientes + total_garantias_reales_pendientes + total_garantias_valor_pendientes,
	porcentaje_total_garantias_fiduciarias_completas = case when total_garantias_fiduciarias = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_fiduciarias_completas / total_garantias_fiduciarias) end,
	porcentaje_total_garantias_fiduciarias_pendientes = case when total_garantias_fiduciarias = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_fiduciarias_pendientes / total_garantias_fiduciarias) end,
	porcentaje_total_garantias_reales_completas = case when total_garantias_reales = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_reales_completas / total_garantias_reales) end,
	porcentaje_total_garantias_reales_pendientes = case when total_garantias_reales = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_reales_pendientes / total_garantias_reales) end,
	porcentaje_total_garantias_valor_completas = case when total_garantias_valor = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_valor_completas / total_garantias_valor) end,
	porcentaje_total_garantias_valor_pendientes = case when total_garantias_valor = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_valor_pendientes / total_garantias_valor) end
where
	fecha_corte = convert(varchar(10),getdate(),103)


--Calcular los porcentajes
update 
	RPT_CONTRATOS_AVANCE_X_OFICINA_CLIENTE
set 
	porcentaje_total_garantias_completas = case when total_garantias = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_completas / total_garantias) end,
	porcentaje_total_garantias_pendientes = case when total_garantias = 0 then 0 else convert(decimal(5,2),100.00 * total_garantias_pendientes / total_garantias) end	
where
	fecha_corte = convert(varchar(10),getdate(),103)

RETURN 0

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Rpt_Avance_Contrato_X_Oficina_Cliente', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Avance_Contrato_X_Oficina_Cliente;
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Avance_Contrato_X_Oficina_Cliente]
AS

/******************************************************************
<Nombre>pa_Rpt_Avance_Contrato_X_Oficina_Cliente</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener información estadística sobre el avance en la manipulación de los contratos, 
             esto por oficina cliente. Se indica la cantidad de contratos completos e incompletos.
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


select distinct
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	c.cod_operacion,

	(select count(*) 
 	from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
	where cod_operacion = c.cod_operacion AND cod_estado=1) as cantidad_garantias_fiduciarias,

	(select count(*) 
 	from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
	where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) as cantidad_garantias_fiduciarias_completas,

	(select count(*) 
 	from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
	where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) as cantidad_garantias_fiduciarias_pendientes,

	(select count(*) 
 	from GAR_GARANTIAS_REALES_X_OPERACION 
	where cod_operacion = c.cod_operacion AND cod_estado=1) as cantidad_garantias_reales,

	(select count(*) 
 	from GAR_GARANTIAS_REALES_X_OPERACION 
	where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) as cantidad_garantias_reales_completas,

	(select count(*) 
 	from GAR_GARANTIAS_REALES_X_OPERACION 
	where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) as cantidad_garantias_reales_pendientes,

	(select count(*) 
 	from GAR_GARANTIAS_VALOR_X_OPERACION x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = c.cod_operacion AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as cantidad_garantias_valor,

	(select count(*) 
 	from GAR_GARANTIAS_VALOR_X_OPERACION  x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = c.cod_operacion and x.cod_tipo_documento_legal is not null AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as cantidad_garantias_valor_completas,

	(select count(*) 
 	from GAR_GARANTIAS_VALOR_X_OPERACION x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = c.cod_operacion and x.cod_tipo_documento_legal is null AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as cantidad_garantias_valor_pendientes,

	case when (select count(*) 
	 	   from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
		   where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) > 0 OR 
		  (select count(*) 
 		  from GAR_GARANTIAS_REALES_X_OPERACION 
		  where cod_operacion = c.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) > 0 OR
		  (select count(*) 
 		  from GAR_GARANTIAS_VALOR_X_OPERACION x
		  inner join GAR_GARANTIA_VALOR y
		  on x.cod_garantia_valor = y.cod_garantia_valor
		  where x.cod_operacion = c.cod_operacion and x.cod_tipo_documento_legal is null AND x.cod_estado=1
			and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
		     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
		             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) > 0 then 'SI'
	    else 'NO'
	end as pendiente
		
into #temp

from 
	GAR_DEUDOR a
	inner join GAR_SICC_BSMPC b
	on a.cedula_deudor = convert(varchar(30),b.bsmpc_sco_ident)
	inner join GAR_OPERACION c
	on a.cedula_deudor = c.cedula_deudor
	inner join bcr_oficinas e
	on convert(smallint,b.bsmpc_dco_ofici) = e.cod_oficina
	left outer join dbo.GAR_SICC_PRMCA d
	on c.cod_contabilidad = d.prmca_pco_conta
	and c.cod_oficina = d.prmca_pco_ofici
	and c.cod_moneda = d.prmca_pco_moned
	and c.cod_producto = d.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),d.prmca_pnu_contr)

where 
d.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),d.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 

order by
	b.bsmpc_dco_ofici 


insert into RPT_AVANCE_CONTRATOS_X_OFICINA_CLIENTE
(fecha_corte, cod_oficina, des_oficina, total_contratos, total_contratos_completos, total_contratos_pendientes, porcentaje_total_contratos_completos, porcentaje_total_contratos_pendientes)
select distinct
	convert(varchar(10), getdate(),103) as fecha_corte,
	a.cod_oficina_cliente, 
	a.des_oficina_cliente, 
	(select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente) as total_contratos,
	(select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente and pendiente = 'NO') as total_contratos_completos,
	(select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente and pendiente = 'SI') as total_contratos_pendientes,
	convert(decimal(5,2),100.00 * (select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente and pendiente = 'NO') / 
	(select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente)) as '% Avance',
	convert(decimal(5,2),100.00 * (select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente and pendiente = 'SI') / 
	(select count(*) from #temp where cod_oficina_cliente = a.cod_oficina_cliente)) as '% Pendiente'
from
	#temp a
order by 1

RETURN 0

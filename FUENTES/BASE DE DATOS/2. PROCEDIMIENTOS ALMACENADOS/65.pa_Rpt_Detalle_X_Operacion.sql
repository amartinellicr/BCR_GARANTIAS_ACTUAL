SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[pa_Rpt_Detalle_X_Operacion] AS

/******************************************************************
<Nombre>pa_Rpt_Detalle_X_Operacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite actualizar las estructuras de las cuales se obtiene la información del avance detallado 
			 por tipo de garantía, esto por cada oficina cliente y sólo para operaciones directas.
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

delete RPT_DETALLE_X_OPERACION

select distinct
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	c.cod_operacion,
	c.cod_contabilidad,
	c.cod_oficina,
	c.cod_moneda,
	c.cod_producto,
	c.num_operacion,
	c.num_contrato,
	a.nombre_deudor,
	f.prmoc_psa_actual,
	f.prmoc_pfe_const,
	f.prmoc_pfe_conta,

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
 	from GAR_GARANTIAS_VALOR_X_OPERACION x
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
	left outer join dbo.GAR_SICC_PRMOC f
	on c.cod_contabilidad = f.prmoc_pco_conta
	and c.cod_oficina = f.prmoc_dco_ofici
	and c.cod_moneda = f.prmoc_pco_moned
	and c.cod_producto = f.prmoc_pco_produ
	and c.num_operacion = convert(decimal(7),f.prmoc_pnu_oper)
	and c.num_contrato = convert(decimal(7),f.prmoc_pnu_contr)

where f.prmoc_pcoctamay <> 815  and f.prmoc_pse_proces = 1  and f.prmoc_estado = 'A' and f.prmoc_psa_actual <> 0
and ((c.num_operacion > 0 and c.num_contrato = 0) or (c.num_operacion is null and c.num_contrato > 0))
and c.cod_estado = 1

order by
	b.bsmpc_dco_ofici 




insert into RPT_DETALLE_X_OPERACION
select 
	cod_oficina_cliente,
	des_oficina_cliente,
	convert(varchar(3),cod_oficina_cliente) + ' - ' + des_oficina_cliente as oficina,
	cod_contabilidad,
	cod_oficina,
	cod_moneda,
	cod_producto,
	num_operacion,
	num_contrato,
	prmoc_psa_actual,
	prmoc_pfe_const,
	prmoc_pfe_conta,
	pendiente
from
	#temp 
order by 1

RETURN 0

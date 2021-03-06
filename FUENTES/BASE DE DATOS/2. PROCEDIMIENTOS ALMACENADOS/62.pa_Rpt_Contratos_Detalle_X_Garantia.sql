SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('pa_Rpt_Contratos_Detalle_X_Garantia', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Contratos_Detalle_X_Garantia;
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Contratos_Detalle_X_Garantia] AS

/******************************************************************
<Nombre>pa_Rpt_Contratos_Detalle_X_Garantia</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite actualizar las estructuras de las cuales se obtiene la información sobre el detalle de 
             avance por cada oficina cliente.
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


delete RPT_CONTRATOS_DETALLE_X_GARANTIA

select distinct
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	convert(varchar(3), b.bsmpc_dco_ofici) + ' - ' + e.des_oficina as oficina,
	convert(varchar(1), c.cod_contabilidad) + '-' + 
	convert(varchar(3), c.cod_oficina) + '-' + 
	convert(varchar(1), c.cod_moneda) + 
	case when c.num_operacion is null then '' else '-' + convert(varchar(1), c.cod_producto) end +
	case when c.num_operacion is null then '' else '-' + convert(varchar(15), c.num_operacion) end +
	case when c.num_operacion is null then '-' + convert(varchar(15), c.num_contrato) else '' end as contrato,
	'GARANTIA FIDUCIARIA' as tipo_garantia,
	f.cedula_fiador + ' - ' + f.nombre_fiador as garantia,
	case when d.cod_tipo_documento_legal is null then 'SI' else 'NO' end as pendiente

into #temp

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
	inner join GAR_GARANTIA_FIDUCIARIA f
	on d.cod_garantia_fiduciaria = f.cod_garantia_fiduciaria
	left outer join dbo.GAR_SICC_PRMCA g
	on c.cod_contabilidad = g.prmca_pco_conta
	and c.cod_oficina = g.prmca_pco_ofici
	and c.cod_moneda = g.prmca_pco_moned
	and c.cod_producto = g.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),g.prmca_pnu_contr)

where 
g.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),g.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1

UNION ALL

select distinct
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	convert(varchar(3), b.bsmpc_dco_ofici) + ' - ' + e.des_oficina as oficina,
	convert(varchar(1), c.cod_contabilidad) + '-' + 
	convert(varchar(3), c.cod_oficina) + '-' + 
	convert(varchar(1), c.cod_moneda) + 
	case when c.num_operacion is null then '' else '-' + convert(varchar(1), c.cod_producto) end +
	case when c.num_operacion is null then '' else '-' + convert(varchar(15), c.num_operacion) end +
	case when c.num_operacion is null then '-' + convert(varchar(15), c.num_contrato) else '' end as contrato,
	'GARANTIA REAL' as tipo_garantia,
	case f.cod_tipo_garantia_real 
		when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), f.cod_partido),'') + ' - Finca: ' + ISNULL(f.numero_finca,'') 
		when 2 then '[Cedula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), f.cod_partido),'') + ' - Finca: ' + ISNULL(f.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), f.cod_grado),'') + ' - Cedula Hipotecaria: ' + ISNULL(convert(varchar(2), f.cedula_hipotecaria),'') 
		when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), f.cod_clase_bien),'') + ' - Placa: ' + ISNULL(f.num_placa_bien,'') 
	end as garantia,
	case when d.cod_tipo_documento_legal is null then 'SI' else 'NO' end as pendiente

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
	inner join GAR_GARANTIA_REAL f
	on d.cod_garantia_real = f.cod_garantia_real
	left outer join dbo.GAR_SICC_PRMCA g
	on c.cod_contabilidad = g.prmca_pco_conta
	and c.cod_oficina = g.prmca_pco_ofici
	and c.cod_moneda = g.prmca_pco_moned
	and c.cod_producto = g.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),g.prmca_pnu_contr)

where 
g.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),g.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1

UNION ALL

select distinct
	b.bsmpc_dco_ofici as cod_oficina_cliente,
	e.des_oficina as des_oficina_cliente,
	convert(varchar(3), b.bsmpc_dco_ofici) + ' - ' + e.des_oficina as oficina,
	convert(varchar(1), c.cod_contabilidad) + '-' + 
	convert(varchar(3), c.cod_oficina) + '-' + 
	convert(varchar(1), c.cod_moneda) + 
	case when c.num_operacion is null then '' else '-' + convert(varchar(1), c.cod_producto) end +
	case when c.num_operacion is null then '' else '-' + convert(varchar(15), c.num_operacion) end +
	case when c.num_operacion is null then '-' + convert(varchar(15), c.num_contrato) else '' end as contrato,
	'GARANTIA VALOR' as tipo_garantia,
	f.numero_seguridad as garantia,
	case when d.cod_tipo_documento_legal is null then 'SI' else 'NO' end as pendiente
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
	inner join GAR_GARANTIA_VALOR f
	on d.cod_garantia_valor = f.cod_garantia_valor
	left outer join dbo.GAR_SICC_PRMCA g
	on c.cod_contabilidad = g.prmca_pco_conta
	and c.cod_oficina = g.prmca_pco_ofici
	and c.cod_moneda = g.prmca_pco_moned
	and c.cod_producto = g.prmca_pco_produc
	and c.num_operacion is null
	and c.num_contrato = convert(decimal(7),g.prmca_pnu_contr)

where 
g.prmca_estado = 'A' 
and convert(datetime, convert(varchar(10),g.prmca_pfe_defin),111) >= convert(datetime, convert(varchar(10),getdate(),111))
and c.num_operacion is null 
and c.num_contrato > 0
and c.cod_estado = 1 and d.cod_estado = 1
and ((f.cod_clase_garantia = 20 and cod_tenencia <> 6) or 
     (f.cod_clase_garantia <> 20 and cod_tenencia = 6) or
     (f.cod_clase_garantia <> 20 and cod_tenencia <> 6))

order by
	b.bsmpc_dco_ofici 


INSERT INTO RPT_CONTRATOS_DETALLE_X_GARANTIA
SELECT * FROM #temp

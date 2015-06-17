SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Sumatoria_Montos_X_Operacion] 
	@nContabilidad tinyint = null,
	@nOficina smallint = null,
	@nMoneda smallint = null,
	@nProducto smallint = null,
	@nOperacion decimal(7,0) = null
AS

/******************************************************************
<Nombre>pa_Rpt_Sumatoria_Montos_X_Operacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la sumatoria de monto mitigador de cada garantía asociada a una operación 
             especificada por el usuario.
</Descripción>
<Entradas>
	@Contabilidad	= Código de la contabilidad de la operación.
	@Oficina		= Código de la oficina de la operación.
	@Moneda			= Código de la moneda de la operación.
	@Producto		= Código del producto de la operación. En caso de no suministrase se le indica al sistema que se trata de un contrato.
	@Operacion		= Número de la operación.
</Entradas>
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

select 
	a.cod_contabilidad,
	a.cod_oficina,
	a.cod_moneda,
	a.cod_producto,
	a.num_operacion,
	a.num_contrato,
	convert(varchar(1), a.cod_contabilidad) + '-' + 
	convert(varchar(3), a.cod_oficina) + '-' + 
	convert(varchar(1), a.cod_moneda) + 
	case when a.num_operacion is null then '' else '-' + convert(varchar(1), a.cod_producto) end +
	case when a.num_operacion is null then '' else '-' + convert(varchar(15), a.num_operacion) end +
	case when a.num_operacion is null then '-' + convert(varchar(15), a.num_contrato) else '' end as llave_operacion,
	b.cedula_deudor,
	b.nombre_deudor,
	'[Fiador] ' + ISNULL(d.cedula_fiador,'') + ' - ' + ISNULL(d.nombre_fiador,'') as garantia,
	c.cod_tipo_mitigador,
	isnull(c.monto_mitigador,0) as monto_mitigador,
	c.porcentaje_responsabilidad as porcentaje_aceptacion
from 
	GAR_OPERACION a
	inner join GAR_DEUDOR b
	on a.cedula_deudor = b.cedula_deudor
	inner join GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION c
	on a.cod_operacion = c.cod_operacion
	inner join GAR_GARANTIA_FIDUCIARIA d
	on c.cod_garantia_fiduciaria = d.cod_garantia_fiduciaria
where 
	a.cod_estado = 1 and c.cod_estado = 1
	and a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina
	and a.cod_moneda = @nMoneda
	and a.cod_producto = @nProducto
	and a.num_operacion = @nOperacion


UNION ALL

select 
	a.cod_contabilidad,
	a.cod_oficina,
	a.cod_moneda,
	a.cod_producto,
	a.num_operacion,
	a.num_contrato,
	convert(varchar(1), a.cod_contabilidad) + '-' + 
	convert(varchar(3), a.cod_oficina) + '-' + 
	convert(varchar(1), a.cod_moneda) + 
	case when a.num_operacion is null then '' else '-' + convert(varchar(1), a.cod_producto) end +
	case when a.num_operacion is null then '' else '-' + convert(varchar(15), a.num_operacion) end +
	case when a.num_operacion is null then '-' + convert(varchar(15), a.num_contrato) else '' end as llave_operacion,
	b.cedula_deudor,
	b.nombre_deudor,
	case d.cod_tipo_garantia_real 
		when 1 then '[Hipoteca] Partido: ' + ISNULL(convert(varchar(1), d.cod_partido),'') + ' - Finca: ' + ISNULL(d.numero_finca,'') 
		when 2 then '[Cédula Hipotecaria] Partido: ' + ISNULL(convert(varchar(1), d.cod_partido),'') + ' - Finca: ' + ISNULL(d.numero_finca,'') + ' - Grado: ' + ISNULL(convert(varchar(2), d.cod_grado),'') + ' - Cédula Hipotecaria: ' + ISNULL(convert(varchar(2), d.cedula_hipotecaria),'') 
		when 3 then '[Prenda] Clase Bien: ' + ISNULL(convert(varchar(3), d.cod_clase_bien),'') + ' - Placa: ' + ISNULL(d.num_placa_bien,'') 
	end as garantia,
	c.cod_tipo_mitigador,
	isnull(c.monto_mitigador,0) as monto_mitigador,
	c.porcentaje_responsabilidad as porcentaje_aceptacion
from 
	GAR_OPERACION a
	inner join GAR_DEUDOR b
	on a.cedula_deudor = b.cedula_deudor
	inner join GAR_GARANTIAS_REALES_X_OPERACION c
	on a.cod_operacion = c.cod_operacion
	inner join GAR_GARANTIA_REAL d
	on c.cod_garantia_real = d.cod_garantia_real
where 
	a.cod_estado = 1 and c.cod_estado = 1
	and a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina
	and a.cod_moneda = @nMoneda
	and a.cod_producto = @nProducto
	and a.num_operacion = @nOperacion


UNION ALL

select 
	a.cod_contabilidad,
	a.cod_oficina,
	a.cod_moneda,
	a.cod_producto,
	a.num_operacion,
	a.num_contrato,
	convert(varchar(1), a.cod_contabilidad) + '-' + 
	convert(varchar(3), a.cod_oficina) + '-' + 
	convert(varchar(1), a.cod_moneda) + 
	case when a.num_operacion is null then '' else '-' + convert(varchar(1), a.cod_producto) end +
	case when a.num_operacion is null then '' else '-' + convert(varchar(15), a.num_operacion) end +
	case when a.num_operacion is null then '-' + convert(varchar(15), a.num_contrato) else '' end as llave_operacion,
	b.cedula_deudor,
	b.nombre_deudor,
	'[Seguridad] ' + d.numero_seguridad as garantia,
	c.cod_tipo_mitigador,
	isnull(c.monto_mitigador,0) as monto_mitigador,
	c.porcentaje_responsabilidad as porcentaje_aceptacion
from 
	GAR_OPERACION a
	inner join GAR_DEUDOR b
	on a.cedula_deudor = b.cedula_deudor
	inner join GAR_GARANTIAS_VALOR_X_OPERACION c
	on a.cod_operacion = c.cod_operacion
	inner join GAR_GARANTIA_VALOR d
	on c.cod_garantia_valor = d.cod_garantia_valor
where 
	a.cod_estado = 1 and c.cod_estado = 1 
	and ((d.cod_clase_garantia = 20 and d.cod_tenencia <> 6) or 
	     (d.cod_clase_garantia <> 20 and d.cod_tenencia = 6) or
	     (d.cod_clase_garantia <> 20 and d.cod_tenencia <> 6))
	and a.cod_contabilidad = @nContabilidad
	and a.cod_oficina = @nOficina
	and a.cod_moneda = @nMoneda
	and a.cod_producto = @nProducto
	and a.num_operacion = @nOperacion



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('pa_Rpt_Indicadores_X_Operacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Indicadores_X_Operacion;
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Indicadores_X_Operacion]
	@nContabilidad tinyint = null,
	@nOficina smallint = null,
	@nMoneda smallint = null,
	@nProducto smallint = null,
	@nOperacion decimal(7,0) = null,
	@nContrato decimal(7,0) = null,  
	@strUsuario varchar(30) = null,
	@dFechaInicio datetime = null,
	@dFechaFin datetime = null
 AS

/******************************************************************
<Nombre>pa_Rpt_Indicadores_X_Operacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener información sobre los indicadores por operación.</Descripción>
<Entradas>
	@Contabilidad	= Código de la contabilidad de la operación.
	@Oficina		= Código de la oficina de la operación.
	@Moneda			= Código de la moneda de la operación.
	@Producto		= Código del producto de la operación. En caso de no suministrase se le indica al sistema que se trata de un contrato.
	@Operacion		= Número de la operación.
	@nContrato		= Número del contrato.
	@strUsuario		= Usuario que realizó manipulaciones en la información.
	@dFechaInicio	= Fecha de inicio del rango en el que se espera encontrar la información manipulada por el usuario.
	@dFechaFin		= Fecha de fin del rango en el que se espera encontrar la información manipulada por el usuario.
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

--Obtiene la información de los indicadores por operación
SELECT DISTINCT
	b.cod_usuario,
	c.des_usuario,
	b.fecha_hora,
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
	d.cedula_deudor,
	d.nombre_deudor,
	(select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) as total_garantias_fiduciarias,
	(select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) as total_garantias_fiduciarias_completas,
	(select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) as total_garantias_fiduciarias_pendientes,
	(select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) as total_garantias_reales,
	(select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) as total_garantias_reales_completas,
	(select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is null AND cod_estado=1) as total_garantias_reales_pendientes,
	
	(select count(*) 
	from GAR_GARANTIAS_VALOR_X_OPERACION x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = a.cod_operacion AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as total_garantias_valor,

	(select count(*) 
	from GAR_GARANTIAS_VALOR_X_OPERACION x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = a.cod_operacion and x.cod_tipo_documento_legal is not null AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as total_garantias_valor_completas,

	(select count(*) 
	from GAR_GARANTIAS_VALOR_X_OPERACION x
	inner join GAR_GARANTIA_VALOR y
	on x.cod_garantia_valor = y.cod_garantia_valor
	where x.cod_operacion = a.cod_operacion and x.cod_tipo_documento_legal is null AND x.cod_estado=1
	and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) as total_garantias_valor_pendientes,

	case when (select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) > 0
		then
			case when 
				(select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) = 
				(select count(*) from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) 
			     then 1
			     else 2
			end
		else 3
	end as ind_garantias_fiduciarias,

	case when (select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) > 0
		then
			case when 
				(select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) = 
				(select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion and cod_tipo_documento_legal is not null AND cod_estado=1) 
			     then 1
			     else 2
			end
		else 3
	end as ind_garantias_reales,
	
	case when (select count(*) from GAR_GARANTIAS_VALOR_X_OPERACION x
		  inner join GAR_GARANTIA_VALOR y
		  on x.cod_garantia_valor = y.cod_garantia_valor
		  where x.cod_operacion = a.cod_operacion and x.cod_tipo_documento_legal is null AND x.cod_estado=1
			and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
		     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
		             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) > 0
		then
			case when 
				(select count(*) 
				from GAR_GARANTIAS_VALOR_X_OPERACION x
				inner join GAR_GARANTIA_VALOR y
				on x.cod_garantia_valor = y.cod_garantia_valor
				where x.cod_operacion = a.cod_operacion and x.cod_tipo_documento_legal is null AND x.cod_estado=1
					and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
				     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
				             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) = 
				(select count(*) 
				from GAR_GARANTIAS_VALOR_X_OPERACION x
				  inner join GAR_GARANTIA_VALOR y
				  on x.cod_garantia_valor = y.cod_garantia_valor
				  where x.cod_operacion = a.cod_operacion and x.cod_tipo_documento_legal is not null AND x.cod_estado=1
					and ((y.cod_clase_garantia = 20 and y.cod_tenencia <> 6) or 
				     	     (y.cod_clase_garantia <> 20 and y.cod_tenencia = 6) or
				             (y.cod_clase_garantia <> 20 and y.cod_tenencia <> 6))) 
			     then 1
			     else 2
			end
		else 3
	end as ind_garantias_valor,

	case when d.cod_generador_divisas is null then 2 else 1 end as ind_deudor,

	case when (select count(*) from GAR_GARANTIAS_REALES_X_OPERACION where cod_operacion = a.cod_operacion AND cod_estado=1) > 0
		then
			case when (select count(*) 
				  from GAR_GARANTIAS_REALES_X_OPERACION x
				  inner join GAR_VALUACIONES_REALES y
				  on x.cod_operacion = a.cod_operacion
				  and x.cod_garantia_real = y.cod_garantia_real
				  AND x.cod_estado=1) =
				  (select count(*) 
				  from GAR_GARANTIAS_REALES_X_OPERACION x
				  inner join GAR_VALUACIONES_REALES y
				  on x.cod_operacion = a.cod_operacion
				  and x.cod_garantia_real = y.cod_garantia_real
				  where y.monto_tasacion_actualizada_terreno is not null
				  AND x.cod_estado=1) 
			     then 1
			     else 2
			end
		else 3
	end as ind_valuaciones_reales,

	case when (select count(*) 
		  from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION 
		  where cod_operacion = a.cod_operacion and monto_mitigador > 0 AND cod_estado=1) > 0 
	     then
		case when 
		 	  (select count(*) 
			  from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION x
			  inner join GAR_VALUACIONES_FIADOR y
			  on x.cod_operacion = a.cod_operacion
			  and x.cod_garantia_fiduciaria = y.cod_garantia_fiduciaria
			  where x.monto_mitigador > 0 AND x.cod_estado=1) =
			  (select count(*) 
			  from GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION x
			  inner join GAR_VALUACIONES_FIADOR y
			  on x.cod_operacion = a.cod_operacion
			  and x.cod_garantia_fiduciaria = y.cod_garantia_fiduciaria
			  where y.ingreso_neto is not null
			  and x.monto_mitigador > 0 AND x.cod_estado=1) 
		     then 1
		     else 2
		end
	    else 3
	end as ind_valuaciones_fiador

--INTO #temp

FROM
	GAR_OPERACION a
	inner join GAR_BITACORA b
	on a.cod_operacion = b.cod_operacion_crediticia
	inner join SEG_USUARIO c
	on b.cod_usuario = c.cod_usuario COLLATE SQL_Latin1_General_CP1_CI_AS
	inner join GAR_DEUDOR d
	on a.cedula_deudor = d.cedula_deudor
WHERE
	b.cod_usuario = isnull(@strUsuario, b.cod_usuario)
	AND convert(varchar(10),b.fecha_hora,111) >= convert(varchar(10),isnull(@dFechaInicio, b.fecha_hora),111) 
	AND convert(varchar(10),b.fecha_hora,111) <= convert(varchar(10),isnull(@dFechaFin, b.fecha_hora),111)
	AND a.cod_contabilidad = isnull(@nContabilidad, a.cod_contabilidad)
	AND a.cod_oficina = isnull(@nOficina, a.cod_oficina)
	AND a.cod_moneda = isnull(@nMoneda, a.cod_moneda)
	AND a.cod_producto = isnull(@nProducto, a.cod_producto)
	AND isnull(a.num_operacion,0) = isnull(@nOperacion, isnull(a.num_operacion, 0))
	AND a.num_contrato = isnull(@nContrato, a.num_contrato)
	AND a.cod_estado=1

ORDER BY
	b.fecha_hora DESC,
	c.des_usuario,
	a.cod_contabilidad,
	a.cod_oficina,
	a.cod_moneda,
	a.cod_producto,
	a.num_operacion,
	a.num_contrato


USE [GARANTIAS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF OBJECT_ID ('pa_Rpt_Sumatoria_Montos_X_Operacion', 'P') IS NOT NULL
	DROP PROCEDURE dbo.pa_Rpt_Sumatoria_Montos_X_Operacion;
GO

CREATE PROCEDURE [dbo].[pa_Rpt_Sumatoria_Montos_X_Operacion] 
	@piContabilidad TINYINT = NULL,
	@piOficina SMALLINT = NULL,
	@piMoneda SMALLINT = NULL,
	@piProducto SMALLINT = NULL,
	@pdOperacion DECIMAL(7,0) = NULL
AS

/******************************************************************
<Nombre>pa_Rpt_Sumatoria_Montos_X_Operacion</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Permite obtener la sumatoria de monto mitigador de cada garantía asociada a una operación 
             especificada por el usuario.
</Descripción>
<Entradas>
	@piContabilidad	= Código de la contabilidad de la operación.
	@piOficina		= Código de la oficina de la operación.
	@piMoneda		= Código de la moneda de la operación.
	@piProducto		= Código del producto de la operación. En caso de no suministrase se le indica al sistema que se trata de un contrato.
	@pdOperacion	= Número de la operación.
</Entradas>
<Salidas></Salidas>
<Autor>Javier Chaves</Autor>
<Fecha>Antes del 01/08/2007</Fecha>
<Requerimiento>N/A</Requerimiento>
<Versión>1.0</Versión>
<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Marín, GrupoMas</Autor>
		<Requerimiento>RQ_MANT_2015111010495738_00610 Creación nuevo campo en mantenimiento de garantías</Requerimiento>
		<Fecha>09/12/2015</Fecha>
		<Descripción>
			El cambio es referente a la implementación del campo porcentaje de responsabilidad, mismo que ya existe, por lo que se debe
			crear el campo referente al porcentaje de aceptación, este campo reemplazará al camp oporcentaje de responsabilidad dentro de 
			cualquier lógica existente. 
		</Descripción>
	</Cambio>
	<Cambio>
		<Autor></Autor>
		<Requerimiento></Requerimiento>
		<Fecha></Fecha>
		<Descripción></Descripción>
	</Cambio>
</Historial>
******************************************************************/

SELECT 
		GO1.cod_contabilidad,
		GO1.cod_oficina,
		GO1.cod_moneda,
		GO1.cod_producto,
		GO1.num_operacion,
		GO1.num_contrato,
		CONVERT(VARCHAR(1), GO1.cod_contabilidad) + '-' + 
		CONVERT(VARCHAR(3), GO1.cod_oficina) + '-' + 
		CONVERT(VARCHAR(1), GO1.cod_moneda) + 
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(1), GO1.cod_producto) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(15), GO1.num_operacion) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '-' + CONVERT(VARCHAR(15), GO1.num_contrato) ELSE '' END AS llave_operacion,
		GD1.cedula_deudor,
		GD1.nombre_deudor,
		'[Fiador] ' + COALESCE(GGF.cedula_fiador,'') + ' - ' + COALESCE(GGF.nombre_fiador,'') AS garantia,
		GFO.cod_tipo_mitigador,
		COALESCE(GFO.monto_mitigador,0) AS monto_mitigador,
		GFO.Porcentaje_Aceptacion AS porcentaje_aceptacion --RQ_MANT_2015111010495738_00610: Se ajusta este campo.
FROM	GAR_OPERACION GO1
	INNER JOIN GAR_DEUDOR GD1
	ON GO1.cedula_deudor = GD1.cedula_deudor
	INNER JOIN GAR_GARANTIAS_FIDUCIARIAS_X_OPERACION GFO
	ON GO1.cod_operacion = GFO.cod_operacion
	INNER JOIN GAR_GARANTIA_FIDUCIARIA GGF
	ON GFO.cod_garantia_fiduciaria = GGF.cod_garantia_fiduciaria
WHERE	GO1.cod_estado = 1 
	AND GFO.cod_estado = 1
	AND GO1.cod_contabilidad = @piContabilidad
	AND GO1.cod_oficina = @piOficina
	AND GO1.cod_moneda = @piMoneda
	AND GO1.cod_producto = @piProducto
	AND GO1.num_operacion = @pdOperacion


UNION ALL

SELECT 
		GO1.cod_contabilidad,
		GO1.cod_oficina,
		GO1.cod_moneda,
		GO1.cod_producto,
		GO1.num_operacion,
		GO1.num_contrato,
		CONVERT(VARCHAR(1), GO1.cod_contabilidad) + '-' + 
		CONVERT(VARCHAR(3), GO1.cod_oficina) + '-' + 
		CONVERT(VARCHAR(1), GO1.cod_moneda) + 
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(1), GO1.cod_producto) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(15), GO1.num_operacion) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '-' + CONVERT(VARCHAR(15), GO1.num_contrato) ELSE '' END AS llave_operacion,
		GD1.cedula_deudor,
		GD1.nombre_deudor,
		CASE GGR.cod_tipo_garantia_real 
			WHEN 1 THEN '[Hipoteca] Partido: ' + COALESCE(CONVERT(VARCHAR(1), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(GGR.numero_finca,'') 
			WHEN 2 THEN '[Cédula Hipotecaria] Partido: ' + COALESCE(CONVERT(VARCHAR(1), GGR.cod_partido),'') + ' - Finca: ' + COALESCE(GGR.numero_finca,'') + ' - Grado: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cod_grado),'') + ' - Cédula Hipotecaria: ' + COALESCE(CONVERT(VARCHAR(2), GGR.cedula_hipotecaria),'') 
			WHEN 3 THEN '[Prenda] Clase Bien: ' + COALESCE(CONVERT(VARCHAR(3), GGR.cod_clase_bien),'') + ' - Placa: ' + COALESCE(GGR.num_placa_bien,'') 
		END AS garantia,
		GRO.cod_tipo_mitigador,
		COALESCE(GRO.monto_mitigador,0) AS monto_mitigador,
		GRO.Porcentaje_Aceptacion AS porcentaje_aceptacion --RQ_MANT_2015111010495738_00610: Se ajusta este campo.
FROM	GAR_OPERACION GO1
	INNER JOIN GAR_DEUDOR GD1
	ON GO1.cedula_deudor = GD1.cedula_deudor
	INNER JOIN GAR_GARANTIAS_REALES_X_OPERACION GRO
	ON GO1.cod_operacion = GRO.cod_operacion
	INNER JOIN GAR_GARANTIA_REAL GGR
	ON GRO.cod_garantia_real = GGR.cod_garantia_real
WHERE	GO1.cod_estado = 1 
	AND GRO.cod_estado = 1
	AND GO1.cod_contabilidad = @piContabilidad
	AND GO1.cod_oficina = @piOficina
	AND GO1.cod_moneda = @piMoneda
	AND GO1.cod_producto = @piProducto
	AND GO1.num_operacion = @pdOperacion


UNION ALL

SELECT 
		GO1.cod_contabilidad,
		GO1.cod_oficina,
		GO1.cod_moneda,
		GO1.cod_producto,
		GO1.num_operacion,
		GO1.num_contrato,
		CONVERT(VARCHAR(1), GO1.cod_contabilidad) + '-' + 
		CONVERT(VARCHAR(3), GO1.cod_oficina) + '-' + 
		CONVERT(VARCHAR(1), GO1.cod_moneda) + 
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(1), GO1.cod_producto) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '' ELSE '-' + CONVERT(VARCHAR(15), GO1.num_operacion) END +
		CASE WHEN GO1.num_operacion IS NULL THEN '-' + CONVERT(VARCHAR(15), GO1.num_contrato) ELSE '' END AS llave_operacion,
		GD1.cedula_deudor,
		GD1.nombre_deudor,
		'[Seguridad] ' + GGV.numero_seguridad AS garantia,
		GVO.cod_tipo_mitigador,
		COALESCE(GVO.monto_mitigador,0) AS monto_mitigador,
		GVO.Porcentaje_Aceptacion AS porcentaje_aceptacion --RQ_MANT_2015111010495738_00610: Se ajusta este campo.
FROM	GAR_OPERACION GO1
	INNER JOIN GAR_DEUDOR GD1
	ON GO1.cedula_deudor = GD1.cedula_deudor
	INNER JOIN GAR_GARANTIAS_VALOR_X_OPERACION GVO
	ON GO1.cod_operacion = GVO.cod_operacion
	INNER JOIN GAR_GARANTIA_VALOR GGV
	ON GVO.cod_garantia_valor = GGV.cod_garantia_valor
WHERE	GO1.cod_estado = 1 
	AND GVO.cod_estado = 1 
	AND ((GGV.cod_clase_garantia = 20 AND GGV.cod_tenencia <> 6) OR 
	     (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia = 6) OR
	     (GGV.cod_clase_garantia <> 20 AND GGV.cod_tenencia <> 6))
	AND GO1.cod_contabilidad = @piContabilidad
	AND GO1.cod_oficina = @piOficina
	AND GO1.cod_moneda = @piMoneda
	AND GO1.cod_producto = @piProducto
	AND GO1.num_operacion = @pdOperacion



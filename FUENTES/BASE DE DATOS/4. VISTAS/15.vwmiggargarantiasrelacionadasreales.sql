USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggargarantiasrelacionadasreales]
AS

/******************************************************************
<Nombre>vwmiggargarantiasrelacionadasreales</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de las relaciones entre las garantías reales y las operaciones que serán migradas</Descripción>
<Autor>Norberto Mesén López, Lidersoft Internacional S.A.</Autor>
<Fecha>28/08/2009</Fecha>
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

SELECT
	o.OperacionesGarantias_cod_idoperacion,
	GR.Garantias_cod_garantia,
	GR.TiposInternosGarantias_cod_tipo_garantia,
	2 AS TiposGarantias_cod_tipo_garantia,
	CASE ISNULL(f.cod_inscripcion, 0) 
		WHEN 0 THEN
			0
		WHEN -1 THEN
			0
		ELSE
			ISNULL(f.cod_inscripcion, 0)
	END AS TiposIndicadoresInscripcion_cod_tipo_indicador,
	ISNULL(
		CASE f.cod_tipo_mitigador
			WHEN -1 THEN
				0
			ELSE
				f.cod_tipo_mitigador
		END
		, 1) AS TiposMitigadoresRiesgos_cod_tipo_mitigador,

	ISNULL(
		CASE f.cod_tipo_documento_legal
			WHEN -1 THEN
				0
			ELSE 
				cod_tipo_documento_legal
		END, 0) AS TiposDocumentosLegales_cod_tipo_documento,

	CASE f.cod_moneda 
		WHEN 0 THEN
			1
		ELSE 
			f.cod_moneda
	END AS TiposMonedas_cod_tipo_moneda,
	f.fecha_presentacion AS GarantiasRelacionadas_fec_presentacion_inscripcion,
	ISNULL(f.monto_mitigador, 0) AS GarantiasRelacionadas_mon_mitigador,
	f.porcentaje_responsabilidad AS GarantiasRelacionadas_por_responsabilidad,
	f.fecha_constitucion AS GarantiasRelacionadas_fec_constitucion,
	ISNULL(f.fecha_vencimiento, '19000101') AS GarantiasRelacionadas_fec_Vencimiento,
	ISNULL(CASE 
		WHEN f.cod_grado_gravamen  = 0 THEN
			1
		WHEN f.cod_grado_gravamen > 4 THEN
			4
		ELSE
			f.cod_grado_gravamen 
		END, 1) AS TiposGrados_cod_tipo_grado,
	f.cod_tipo_acreedor AS TiposPersonas_cod_tipo_persona,
	f.cedula_acreedor AS Gravamenes_cod_idacreedor,
	1 AS GarantiasRelacionadas_ind_calculo_automatico,
	1 AS GarantiasRelacionadas_ind_garantia_participa_calculo,
	80 AS GarantiasRelacionadas_por_aceptacion,
	0 AS GarantiasRelacionadas_mon_responsabilidad,
	CASE f.cod_tipo_documento_legal
		WHEN 23 THEN
			1
		WHEN 24 THEN
			1
		WHEN 25 THEN
			1
		WHEN 26 THEN
			1
		ELSE
			0
	END AS GarantiasRelacionadas_ind_garantia_fideicometida,
	
	ISNULL(
		(SELECT ISNULL(monto_ultima_tasacion_terreno, 0) + ISNULL(monto_ultima_tasacion_no_terreno, 0)
		FROM GAR_VALUACIONES_REALES VR
		WHERE VR.cod_garantia_real = f.cod_garantia_real
		AND fecha_valuacion = (
			SELECT fecha_valuacion
			FROM vwvwmiggarmaxvaluacionesreales MVR
			WHERE MVR.cod_garantia_real = VR.cod_garantia_real))
		, 0) AS GarantiasRelacionadas_mon_valor_mercado
FROM GAR_GARANTIAS_REALES_X_OPERACION f
INNER JOIN vwmiggaroperacionesactivas o ON o.cod_operacion = f.cod_operacion
	AND o.cod_garantia = f.cod_garantia_real
INNER JOIN vwmiggarantiareal GR ON GR.cod_garantia_real = f.cod_garantia_real
WHERE NOT f.cedula_acreedor IS NULL


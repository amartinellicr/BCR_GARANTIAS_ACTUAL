USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggarvaluacionesreales]
AS

/******************************************************************
<Nombre>vwmiggarvaluacionesreales</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de los avalúos de las garantías reales que serán migradas</Descripción>
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

SELECT t.*, P.TiposPersonas_cod_tipo_persona AS TiposPersonas_cod_tipo_persona_perito, 
	P.Peritos_num_idperito,
	E.Empresas_num_idempresa,
	E.TiposPersonas_cod_tipo_persona AS TiposPersonas_cod_tipo_persona_empresa,

	ISNULL(
	CASE TiposLiquidez_cod_tipo_liquidezTemp
		WHEN 0 THEN
			1
		WHEN -1 THEN
			1
		ELSE
			TiposLiquidez_cod_tipo_liquidezTemp
	END, 2) AS TiposLiquidez_cod_tipo_liquidez
FROM (
SELECT 
GR.Garantias_cod_garantia,
CONVERT(VARCHAR(30), V.cedula_perito) AS Peritos_num_idperitoControl,
(
	SELECT TOP 1 
			GXO.cod_liquidez
	FROM GAR_GARANTIAS_REALES_X_OPERACION GXO
	WHERE GXO.cod_garantia_real = V.cod_garantia_real
	AND GXO.cod_estado = 1
	) AS TiposLiquidez_cod_tipo_liquidezTemp,

	ISNULL(
		(SELECT MAX(GXO.fecha_vencimiento)
			FROM GAR_GARANTIAS_REALES_X_OPERACION GXO
			WHERE GXO.cod_garantia_real = V.cod_garantia_real
			AND GXO.cod_estado = 1
		), '19000101') AS ValuacionesReales_fec_vencimiento,
CONVERT(NUMERIC(20, 2), ISNULL(V.monto_ultima_tasacion_terreno, 0)) AS ValuacionesReales_mon_ultima_tasacion_terreno,
CONVERT(NUMERIC(20, 2), ISNULL(V.monto_ultima_tasacion_no_terreno, 0)) AS ValuacionesReales_mon_ultima_tasacion_no_terreno,
CONVERT(NUMERIC(20, 2), ISNULL(V.monto_tasacion_actualizada_terreno, 0)) AS ValuacionesReales_mon_tasacion_actualizada_terreno,
CONVERT(NUMERIC(20, 2), ISNULL(V.monto_tasacion_actualizada_no_terreno, 0)) AS ValuacionesReales_mon_tasacion_actualizada_no_terreno,
ISNULL(V.fecha_ultimo_seguimiento, '19000101') AS ValuacionesReales_fec_ultimo_seguimiento,
ISNULL(V.fecha_construccion, '19000101') AS ValuacionesReales_fec_construccion_o_fabricacion,
ISNULL(CONVERT(NUMERIC(1), V.cod_recomendacion_perito), 1) AS ValuacionesReales_ind_recomendacion_perito,
ISNULL(V.fecha_valuacion, '19000101') AS ValuacionesReales_fec_ultima_tasacion,
V.cod_garantia_real,
V.cedula_empresa
FROM GAR_VALUACIONES_REALES V
INNER JOIN vwmiggarantiareal GR ON GR.cod_garantia_real = V.cod_garantia_real) t
INNER JOIN vwvwmiggarperitos P ON P.cedula_relacion = T. Peritos_num_idperitoControl
LEFT OUTER JOIN vwvwmiggarempresas E ON E.cedula_relacion = t.cedula_empresa

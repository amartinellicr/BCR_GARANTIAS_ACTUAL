USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwmiggardeudorcodeudor]
AS

/******************************************************************
<Nombre>vwmiggardeudorcodeudor</Nombre>
<Sistema>BCRGARANTIAS</Sistema>
<Descripción>Obtiene información de los deudores que serán migrados</Descripción>
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


SELECT D.*,
	CASE D.TiposPersonas_cod_tipo_persona
		WHEN 4 THEN 2
		WHEN 6 THEN 2
		ELSE 0
	END AS TiposAsignacionesCalificaciones_cod_tipo_asignacion
FROM (
SELECT
	D.cedula_deudor AS cedulaRelacion,
	D.cedula_deudor_sugef,
	D.ind_actualizo_cedulasugef,
	ISNULL(D.cedula_deudor_sugef, D.cedula_deudor) AS DeudorCodeudor_cod_iddeudor,
	ISNULL(D.tipo_id_sugef, 
	ISNULL(
	CASE
		WHEN D.cod_tipo_deudor = 0 THEN
			1
		ELSE
			D.cod_tipo_deudor
	END, 1)) AS TiposPersonas_cod_tipo_persona,
	D.nombre_deudor AS DeudoresCodeudores_nombre,
	ISNULL(D.cod_condicion_especial, 5) AS TiposCondicionesEspecialesDeudor_cod_tipo_condicion,
	ISNULL(D.cod_generador_divisas, 4) AS IndicadoresGeneradoresDivisas_cod_indicador_generador,
	CASE 
		WHEN D.cod_vinculado_entidad = 1 THEN
			'S'
		WHEN D.cod_vinculado_entidad = 2 THEN
			'N'
		ELSE
			'N'
	END AS DeudoresCodeudores_cod_vinculado_entidad,

	ISNULL(CP.fecha_capacidad_pago, '19000101') AS DeudoresCodeudores_fec_certificacion_ingresos,
	ISNULL(CP.cod_capacidad_pago, NULL) AS TiposCapacidadesPagos_cod_tipo_capacidad,
	ISNULL(CP.sensibilidad_tipo_cambio, 100) AS DeudoresCodeudores_por_sensibilidad_tipo_cambio,

	102 AS SectoresEconomicos_cod_sector,
	2 AS GruposRiesgoDeudor_cod_grupo,
	1 AS TiposIngresos_cod_tipo_ingreso,
	1 AS TiposComportamientosPagos_cod_tipo_comportamiento,
	'N' AS DeudoresCodeudores_cod_vinculado_grupo_financiero,
	0 AS DeudoresCodeudores_mon_ingresos,
	CONVERT(DATETIME, CONVERT(VARCHAR(10), dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(day, getdate())+1, getdate()))), 112)) AS
		DeudoresCodeudores_fec_calificacion_riesgo			

FROM  GAR_DEUDOR D
LEFT OUTER JOIN vwvwmiggarmaxcapacidadpago MCP ON MCP.DeudorCodeudor_cod_iddeudor = D.cedula_deudor
LEFT OUTER JOIN GAR_CAPACIDAD_PAGO CP ON CP.cedula_deudor = MCP.DeudorCodeudor_cod_iddeudor
	AND CP.fecha_capacidad_pago = MCP.DeudoresCodeudores_fec_certificacion_ingresos) D


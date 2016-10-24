USE [GARANTIAS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('[VALUACIONES_GARANTIAS_REALES_VW]', 'V') IS NOT NULL
	DROP VIEW [VALUACIONES_GARANTIAS_REALES_VW];
GO


CREATE VIEW [dbo].[VALUACIONES_GARANTIAS_REALES_VW]
AS

/******************************************************************
	<Nombre>VALUACIONES_GARANTIAS_REALES_VW</Nombre>
	<Sistema>BCRGarant�as</Sistema>
	<Descripci�n>Vista que obtiene el aval�o m�s reciente que posee cada una de las garant�as reales
	</Descripci�n>
	<Entradas>
	</Entradas>
	<Salidas>
	</Salidas>
	<Autor>Arnoldo Martinelli Mar�n, Lidersoft Internacional S.A.</Autor>
	<Fecha>19/07/2012</Fecha>
	<Requerimiento>Validaciones Indicador Inscripci�n, Siebel No. 1-21317176</Requerimiento>
	<Versi�n>1.0</Versi�n>
	<Historial>
	<Cambio>
		<Autor>Arnoldo Martinelli Mar�n, GrupoMas</Autor>
		<Requerimiento>PBI 13977: Mantenimientos Garant�as Reales</Requerimiento>
		<Fecha>Octubre - 2016</Fecha>
		<Descripci�n>Se agregra el campo referente al monto total del aval�o colonizado.</Descripci�n>
	</Cambio>
		<Cambio>
			<Autor></Autor>
			<Requerimiento></Requerimiento>
			<Fecha></Fecha>
			<Descripci�n></Descripci�n>
		</Cambio>
	</Historial>
******************************************************************/

	SELECT DISTINCT TOP 100 PERCENT
		GV2.cod_garantia_real, 
		GV2.fecha_valuacion, 
		GV2.cedula_empresa, 
		GV2.cedula_perito, 
		GV2.monto_ultima_tasacion_terreno, 
		GV2.monto_ultima_tasacion_no_terreno, 
        GV2.monto_tasacion_actualizada_terreno, 
		GV2.monto_tasacion_actualizada_no_terreno, 
		GV2.fecha_ultimo_seguimiento, 
		GV2.monto_total_avaluo, 
        GV2.cod_recomendacion_perito, 
		GV2.cod_inspeccion_menor_tres_meses, 
		GV2.fecha_construccion,
		GV2.Tipo_Moneda_Tasacion, --PBI 13977: Se agrega este campo
		GV2.Monto_Total_Avaluo_Colonizado --PBI 13977: Se agrega este campo

	FROM
		(
		  SELECT cod_garantia_real, fecha_valuacion = MAX([fecha_valuacion])
		  FROM dbo.GAR_VALUACIONES_REALES
		  GROUP BY cod_garantia_real
		) AS GV1
		INNER JOIN dbo.GAR_VALUACIONES_REALES GV2 
		ON GV2.cod_garantia_real = GV1.cod_garantia_real
		AND GV2.fecha_valuacion = GV1.fecha_valuacion
		WHERE EXISTS (SELECT 1
					  FROM dbo.GAR_GARANTIA_REAL GGR
					  WHERE GGR.cod_garantia_real = GV2.cod_garantia_real)

	ORDER BY GV2.cod_garantia_real
